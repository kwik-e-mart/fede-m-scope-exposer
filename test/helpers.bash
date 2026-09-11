#!/usr/bin/env bash
# Test helpers for the exposer scripts.
# Stub `np` and `kubectl` on the PATH and set up a temporary OUTPUT_DIR.

setup_exposer_env() {
  export SERVICE_PATH="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export TEST_TEMP_DIR="$(mktemp -d)"
  export OUTPUT_DIR="$TEST_TEMP_DIR/out"
  mkdir -p "$OUTPUT_DIR" "$TEST_TEMP_DIR/bin"

  export SERVICE_ID="aaaa1111-bbbb-2222-cccc-333344445555"
  export SCOPE_ID="100000001"
  export K8S_NAMESPACE="nullplatform"

  # np stub: echoes NP_LINKS_JSON, or fails with NP_EXIT_CODE
  cat > "$TEST_TEMP_DIR/bin/np" <<'STUB'
#!/bin/sh
if [ -n "$NP_EXIT_CODE" ] && [ "$NP_EXIT_CODE" != "0" ]; then
  echo "error: could not list links" >&2
  exit "$NP_EXIT_CODE"
fi
printf '%s' "$NP_LINKS_JSON"
STUB

  # kubectl stub: should not be reached by these tests
  cat > "$TEST_TEMP_DIR/bin/kubectl" <<'STUB'
#!/bin/sh
echo "kubectl should not be invoked here: $*" >&2
exit 1
STUB

  chmod +x "$TEST_TEMP_DIR/bin/np" "$TEST_TEMP_DIR/bin/kubectl"
  export PATH="$TEST_TEMP_DIR/bin:$PATH"
}

teardown_exposer_env() {
  [ -n "$TEST_TEMP_DIR" ] && rm -rf "$TEST_TEMP_DIR"
}

# Copy a fixture to the path where build_ingress_with_rule would leave the file.
load_ingress_fixture() {
  cp "$SERVICE_PATH/test/fixtures/$1" \
     "$OUTPUT_DIR/ingress-$SERVICE_ID-$SCOPE_ID-public.yaml"
}

ingress_file() {
  echo "$OUTPUT_DIR/ingress-$SERVICE_ID-$SCOPE_ID-public.yaml"
}

# Paths of the resulting ingress, one per line.
result_paths() {
  yq '.spec.rules[0].http.paths[].path' "$(ingress_file)"
}

# Build the JSON `np link list` returns, from the given paths.
links_json() {
  local out="" p
  for p in "$@"; do
    out="$out{\"attributes\":{\"path\":\"$p\"}},"
  done
  echo "{\"results\":[${out%,}]}"
}

run_prune() {
  run bash -c "source '$SERVICE_PATH/scripts/prune_orphan_rules'"
}
