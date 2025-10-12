final: prev: {
  genAttrs' = keys: f: builtins.listToAttrs (map f keys);

  stemValuePair = key: value: let
    inherit (final.krad246.strings) stem;
  in
    prev.attrsets.nameValuePair (stem key) value;
}
