def escape_regex: gsub("(?<c>[^A-Za-z0-9_/-])"; "\\\(.c)");

def entry_path($paths):
  if ($paths | length) == 1
  then $paths[0]
  else "/^(" + ($paths | map(escape_regex) | join("|")) + ")(/.*)?$"
  end;

def entry_type($paths):
  if ($paths | length) == 1 then "Prefix" else "ImplementationSpecific" end;

def owned_entry_paths($published; $desired):
  $published
  + $desired
  + (if ($published | length) > 1 then [entry_path($published)] else [] end)
  + (if ($desired | length) > 1 then [entry_path($desired)] else [] end)
  | unique;
