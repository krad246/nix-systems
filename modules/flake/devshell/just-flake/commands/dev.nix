{
  self,
  specialArgs,
  ...
}: let
  inherit (specialArgs) mkJustRecipeGroup;
in {
  perSystem = {
    self',
    config,
    pkgs,
    ...
  }: {
    just-flake.features = let
      inherit (pkgs) lib;
    in
      mkJustRecipeGroup {
        inherit lib;
        group = "dev";
        recipes = {
          make = {
            enable = self'.packages ? makefile;
            comment = "Makefile commands. Syntax: `make ARGS`";
            justfile = ''
              make +ARGS:
                exec {{ just_executable() }} build --print-out-paths ${self}#packages.$system.makefile | \
                ${lib.meta.getExe' pkgs.findutils "xargs"} -I {drv} \
                  ${lib.meta.getExe pkgs.gnumake} -f {drv} {{ ARGS }}
            '';
          };

          container = {
            enable = self'.packages ? makefile;
            comment = "Container commands. Syntax: `just container ARGS`";
            justfile = ''
              container *ARGS: (make prepend("container-", ARGS))
            '';
          };

          devour-flake = {
            comment = "Build all outputs in the repository.";
            justfile = ''
              devour-flake *ARGS: (lock) (run "${self}#devour-flake -- " ARGS)
            '';
          };

          fmt = {
            comment = "Format the repository.";
            justfile = ''
              fmt *ARGS: (lock)
                ${lib.meta.getExe config.treefmt.build.wrapper} {{ ARGS }}
            '';
          };
        };
      };
  };
}
