# outer / 'flake' scope
{mkJustRecipeGroup, ...}: {
  perSystem = {
    inputs',
    pkgs,
    ...
  }: {
    # set up devshell commands
    just-flake.features = let
      inherit (pkgs) lib;
    in
      mkJustRecipeGroup {
        inherit lib;

        group = "misc";
        recipes = {
          rekey = {
            comment = "Run `agenix --rekey`.";
            justfile = ''
              rekey *ARGS:
                ${lib.getExe' pkgs.coreutils "env"} --chdir "$FLAKE_ROOT/modules/generic/secrets" \
                  ${lib.getExe' inputs'.agenix.packages.default "agenix"} -r {{ ARGS }}
            '';
          };

          dd = {
            comment = "Write flake output to stdout. Must be piped to a file. Syntax: `just dd ARGS`.";
            justfile = ''
              dd *ARGS: (build ARGS)
                ${lib.getExe pkgs.pv} < "$(${lib.getExe' pkgs.findutils "find"} -L {{ ARGS }} -type f)"
            '';
          };
        };
      };
  };
}
