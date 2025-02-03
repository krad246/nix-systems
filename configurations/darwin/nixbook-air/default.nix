{
  withSystem,
  self,
  specialArgs,
  ...
}: let
  entrypoint = {system, ...}: {
    imports = let
      modules = {
        secrets = {
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
        };

        apps = {
          imports = with self.darwinModules; [
            bluesnooze
            groupme
            launchcontrol
            signal
          ];
        };
      };
    in
      [
        ./configuration.nix
        ./remotes.nix
      ]
      ++ [modules.apps modules.secrets];

    nixpkgs.system = system;
  };
in
  withSystem "aarch64-darwin" entrypoint
