{
  self,
  specialArgs,
  ...
}: {
  imports = [self.nixosModules.agenix];

  age.secrets = let
    inherit (specialArgs) krad246;
    paths = krad246.fileset.filterExt "age" ./secrets;
  in
    krad246.attrsets.genAttrs' paths (path: krad246.attrsets.stemValuePair path {file = path;});
}
