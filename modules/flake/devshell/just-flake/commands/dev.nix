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
          container = {
            enable = false;
            comment = "Container commands. Syntax: `just container ARGS`";
            justfile = ''
              container *ARGS:
                ${lib.meta.getExe pkgs.gnumake} -f ${self'.packages.makefile} {{ prepend("container-", ARGS) }}
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
