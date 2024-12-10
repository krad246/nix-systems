{specialArgs, ...}: let
  inherit (specialArgs) mkJustRecipeGroup;
in {
  perSystem = {pkgs, ...}: {
    # set up devshell commands
    just-flake.features = let
      inherit (pkgs) lib;
      inherit (lib) meta;
    in
      mkJustRecipeGroup {
        inherit lib;

        group = "misc";
        recipes = {
          dd = {
            comment = "Write flake output to stdout. Must be piped to a file. Syntax: `just dd ARGS`.";
            justfile = ''
              dd *ARGS: (build ARGS)
                ${meta.getExe pkgs.pv} < "$(${meta.getExe' pkgs.findutils "find"} -L {{ ARGS }} -type f)"
            '';
          };
        };
      };
  };
}
