# outer / 'flake' scope
{mkJustRecipeGroup, ...}: {
  perSystem = {
    inputs',
    lib,
    pkgs,
    ...
  }: {
    # set up devshell commands
    just-flake.features = let
      inherit (lib) meta;
    in
      mkJustRecipeGroup {
        inherit lib;

        group = "misc";
        recipes = {
          rekey = {
            comment = "Run `agenix --rekey`.";
            justfile = ''
              rekey *ARGS:
                ${meta.getExe' pkgs.coreutils "env"} --chdir "$FLAKE_ROOT/modules/generic/secrets" \
                  ${meta.getExe' inputs'.agenix.packages.default "agenix"} -r {{ ARGS }}
            '';
          };

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
