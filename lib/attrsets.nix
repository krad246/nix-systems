{lib}: {
  genAttrs' = keys: f: builtins.listToAttrs (map f keys);

  stemValuePair = key: value: let
    stem = path: lib.strings.nameFromURL (builtins.baseNameOf path) ".";
  in
    lib.attrsets.nameValuePair (stem key) value;
}
