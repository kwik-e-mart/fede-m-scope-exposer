#!/usr/bin/env bats

load helpers

setup()    { setup_exposer_env; }
teardown() { teardown_exposer_env; }

@test "prunes the rule whose path no longer has an active link" {
  load_ingress_fixture ingress-two-paths.yaml
  export NP_LINKS_JSON="$(links_json /web)"

  run_prune
  [ "$status" -eq 0 ]

  run result_paths
  [[ "$output" == *"/web"* ]]
  [[ "$output" != *"/web/api/ping"* ]]
}

@test "keeps every path that does have an active link" {
  load_ingress_fixture ingress-two-paths.yaml
  export NP_LINKS_JSON="$(links_json /web /web/api/ping)"

  run_prune
  [ "$status" -eq 0 ]

  run result_paths
  [[ "$output" == *"/web/api/ping"* ]]
  [[ "$output" == *"/web"* ]]
}

@test "never prunes the response-404 placeholder" {
  load_ingress_fixture ingress-with-placeholder.yaml
  export NP_LINKS_JSON="$(links_json /other)"

  run_prune
  [ "$status" -eq 0 ]

  run result_paths
  [[ "$output" == *"/"* ]]
  [[ "$output" != *"/old"* ]]
}

@test "reinserts the 404 placeholder when pruning empties the ingress" {
  load_ingress_fixture ingress-only-orphan.yaml
  export NP_LINKS_JSON="$(links_json /other)"

  run_prune
  [ "$status" -eq 0 ]

  run bash -c "yq '.spec.rules[0].http.paths | length' '$(ingress_file)'"
  [ "$output" = "1" ]

  run bash -c "yq '.spec.rules[0].http.paths[0].backend.service.name' '$(ingress_file)'"
  [ "$output" = "response-404" ]
}

@test "GUARD: prunes nothing when the CLI call fails" {
  load_ingress_fixture ingress-two-paths.yaml
  export NP_EXIT_CODE=1
  export NP_LINKS_JSON=""

  run_prune
  [ "$status" -eq 0 ]
  [[ "$output" == *"Could not list links"* ]]

  run result_paths
  [[ "$output" == *"/web/api/ping"* ]]
  [[ "$output" == *"/web"* ]]
}

@test "GUARD: prunes nothing when the link list comes back empty" {
  load_ingress_fixture ingress-two-paths.yaml
  export NP_LINKS_JSON='{"results":[]}'

  run_prune
  [ "$status" -eq 0 ]
  [[ "$output" == *"No active links reported"* ]]

  run result_paths
  [[ "$output" == *"/web/api/ping"* ]]
  [[ "$output" == *"/web"* ]]
}

@test "GUARD: prunes nothing on a CLI error body (401) returned with exit 0" {
  # Real payload observed when the token expires. Exit 0 is forced on purpose:
  # even if the CLI did not signal the failure through its exit code, the body
  # carries no .results and the prune must not run.
  load_ingress_fixture ingress-two-paths.yaml
  export NP_LINKS_JSON='{"error":"HTTP status: 401, response: {\"statusCode\":401,\"error\":\"Invalid token\"}"}'

  run_prune
  [ "$status" -eq 0 ]
  [[ "$output" == *"No active links reported"* ]]

  run result_paths
  [[ "$output" == *"/web/api/ping"* ]]
  [[ "$output" == *"/web"* ]]
}

@test "EXCLUDE_LINK_ID drops that link's path even while the API still lists it" {
  # What unlink needs: the link is still active while its delete action runs.
  load_ingress_fixture ingress-two-paths.yaml
  export NP_LINKS_JSON="$(links_json /web /web/api/ping)"
  export EXCLUDE_LINK_ID="link-2"   # the one holding /web/api/ping

  run_prune
  [ "$status" -eq 0 ]

  run result_paths
  [[ "$output" == *"/web"* ]]
  [[ "$output" != *"/web/api/ping"* ]]
}

@test "EXTRA_PATH keeps a path the API has not persisted yet" {
  load_ingress_fixture ingress-two-paths.yaml
  export NP_LINKS_JSON="$(links_json /web/api/ping)"
  export EXTRA_PATH="/web"

  run_prune
  [ "$status" -eq 0 ]

  run result_paths
  [[ "$output" == *"/web"* ]]
  [[ "$output" == *"/web/api/ping"* ]]
}

@test "rename converges whether or not the new path was persisted first" {
  # Both knobs together: drop whatever the link currently claims, keep the new
  # path. The outcome must not depend on the platform's write ordering.
  for listed in /web/api/ping /web; do
    load_ingress_fixture ingress-two-paths.yaml
    export NP_LINKS_JSON="$(links_json $listed)"
    export EXCLUDE_LINK_ID="link-1"
    export EXTRA_PATH="/web"

    run_prune
    [ "$status" -eq 0 ]

    run result_paths
    [[ "$output" == *"/web"* ]]
    [[ "$output" != *"/web/api/ping"* ]]
  done
}
