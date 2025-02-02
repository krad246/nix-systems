{
  withSystem,
  self,
  specialArgs,
  ...
}: let
  entrypoint = {system, ...}: {
    imports =
      [
        ./configuration.nix
        ./remotes.nix
      ]
      ++ [
        {
          imports = [self.darwinModules.agenix];

          # Parse the secrets directory
          age.secrets = let
            inherit (specialArgs) krad246;
            paths = krad246.fileset.filterExt "age" ./secrets;
          in
            krad246.attrsets.genAttrs' paths (path:
              krad246.attrsets.stemValuePair path {
                file = path;
              });
        }
      ];

    nixpkgs.system = system;
  };
in
  withSystem "aarch64-darwin" entrypoint
