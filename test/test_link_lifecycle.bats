#!/usr/bin/env bats

# The two defects this repo actually had, and their fixes.
#
#   update: the workflow was empty, so a rename moved nothing. The platform
#           stored the new path while the ingress kept serving the old one.
#   unlink: the removal is keyed on the link's current path, so after a rename
#           it deletes nothing and the old rule keeps serving.

load helpers

setup() {
  setup_exposer_env
  load_ingress_fixture ingress-two-paths.yaml
  export LINK_ID="link-1"

  cat > "$TEST_TEMP_DIR/bin/kubectl" <<STUB
#!/bin/sh
case "\$*" in
  *jsonpath*) echo "k-8-s-exposer-aaaa1111-public" ;;
  *) cat "$OUTPUT_DIR/ingress-$SERVICE_ID-$SCOPE_ID-public.yaml" ;;
esac
STUB
  chmod +x "$TEST_TEMP_DIR/bin/kubectl"
}

teardown() { teardown_exposer_env; }

# Renames /web/api/ping to /moved. CONTEXT decides whether the platform had
# already persisted the new path when the action started.
rename_to_moved() {
  local stored="$1"
  export CONTEXT="{\"parameters\":{\"path\":\"/moved\"},\"link\":{\"attributes\":{\"path\":\"$stored\"}}}"
  export SCOPE_RULE='{"blue_green_annotation": null, "service": {"name": "d-100000001-200000009", "port": {"number": 8080}}}'

  run bash -c "
    source '$SERVICE_PATH/scripts/resolve_update_context'
    source '$SERVICE_PATH/scripts/build_ingress_with_rule'
    source '$SERVICE_PATH/scripts/prune_orphan_rules'
  "
}

@test "update: the rename moves the routing, old path gone and new one serving" {
  # API still reports the old path: the rename was not persisted yet
  export NP_LINKS_JSON="$(links_json /web/api/ping)"

  rename_to_moved "/web/api/ping"
  [ "$status" -eq 0 ]

  run result_paths
  [[ "$output" == *"/moved"* ]]
  [[ "$output" != *"/web/api/ping"* ]]
}

@test "update: same outcome when the platform persisted the rename first" {
  # API already reports the new path, and the link's attributes match it, so the
  # previous path is unknowable. The ingress must converge all the same.
  export NP_LINKS_JSON="$(links_json /moved)"

  rename_to_moved "/moved"
  [ "$status" -eq 0 ]

  run result_paths
  [[ "$output" == *"/moved"* ]]
  [[ "$output" != *"/web/api/ping"* ]]
}

@test "unlink: removes the rule by link even when the path was renamed" {
  # The link now claims /web, but its rule in the ingress is still /web/api/ping
  # from before the rename. build_ingress_without_rule alone is a no-op here.
  export RULE_PATH="/web"
  export NP_LINKS_JSON="$(links_json /web/api/ping)"

  run bash -c "source '$SERVICE_PATH/scripts/build_ingress_without_rule'"
  [ "$status" -eq 0 ]

  run result_paths
  [[ "$output" == *"/web/api/ping"* ]]   # still there: this is the bug

  export EXCLUDE_LINK_ID="link-1"
  run_prune
  [ "$status" -eq 0 ]

  run result_paths
  [[ "$output" != *"/web/api/ping"* ]]
}

@test "unlink: deleting the last link leaves the 404 placeholder, not an empty ingress" {
  # The guard must not confuse this with the API answering nothing: excluding
  # the only link legitimately empties the ingress.
  load_ingress_fixture ingress-only-orphan.yaml
  export RULE_PATH="/old"
  export NP_LINKS_JSON="$(links_json /old)"
  export EXCLUDE_LINK_ID="link-1"

  run_prune
  [ "$status" -eq 0 ]

  run bash -c "yq '.spec.rules[0].http.paths | length' '$(ingress_file)'"
  [ "$output" = "1" ]

  run bash -c "yq '.spec.rules[0].http.paths[0].backend.service.name' '$(ingress_file)'"
  [ "$output" = "response-404" ]
}
