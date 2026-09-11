#!/usr/bin/env bats

# Reproduces the field case and verifies the fix resolves it.
#
# Starting state, the one an affected exposer has today:
#   /web/api/ping -> d-100000001-200000001  (fossil: its Service is long gone)
#   /web          -> current backend        (live link)
#
# The refresh triggered by the live link's deploy must update its own rule and
# also sweep the fossil.

load helpers

setup() {
  setup_exposer_env
  load_ingress_fixture ingress-two-paths.yaml

  # kubectl returns the exposer ingress, both by name and by label
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

@test "the live link's refresh also sweeps the fossil rule" {
  export RULE_PATH="/web"
  export SCOPE_RULE='{"blue_green_annotation": null, "service": {"name": "d-100000001-200000009", "port": {"number": 8080}}}'
  export NP_LINKS_JSON="$(links_json /web)"

  run bash -c "source '$SERVICE_PATH/scripts/build_ingress_with_rule'"
  [ "$status" -eq 0 ]

  # before pruning both rules coexist: the updated one and the fossil
  run result_paths
  [[ "$output" == *"/web/api/ping"* ]]

  run_prune
  [ "$status" -eq 0 ]

  run result_paths
  [[ "$output" == *"/web"* ]]
  [[ "$output" != *"/web/api/ping"* ]]

  # and the live rule now points at the new deployment's Service
  run bash -c "yq '.spec.rules[0].http.paths[0].backend.service.name' '$(ingress_file)'"
  [ "$output" = "d-100000001-200000009" ]
}

@test "without the fix, the fossil rule survives the refresh" {
  export RULE_PATH="/web"
  export SCOPE_RULE='{"blue_green_annotation": null, "service": {"name": "d-100000001-200000009", "port": {"number": 8080}}}'

  run bash -c "source '$SERVICE_PATH/scripts/build_ingress_with_rule'"
  [ "$status" -eq 0 ]

  run result_paths
  [[ "$output" == *"/web/api/ping"* ]]
}
