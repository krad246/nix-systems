# outer / 'flake' scope
{mkJustRecipeGroup, ...}: {
  perSystem = {
    lib,
    pkgs,
    ...
  }: {
    just-flake.features = let
      inherit (lib) meta;
    in
      mkJustRecipeGroup {
        inherit lib;
        group = "git";
        recipes = {
          git = {
            comment = "Wraps `git`. Pass arguments as normal.";
            justfile = ''
              [no-exit-message]
              git *ARGS:
                  ${meta.getExe pkgs.git} {{ ARGS }}
            '';
          };

          add = {
            comment = "Equivalent to `git add -u` by default, unless other args are passed.";
            justfile = ''
              add +ARGS="-u": (git "add" "--chmod=+x" ARGS)
            '';
          };

          commit = {
            comment = "Equivalent to `git add -u` followed by `git commit --dry-run`, unless other args are passed.";
            justfile = ''
              commit +ARGS="--dry-run": (add "-u") (git "commit" ARGS)
            '';
          };

          amend = {
            comment = "Equivalent to `git add -u` followed by `git commit --amend`, with other args passed to its invocation.";
            justfile = ''
              amend +ARGS="--dry-run": (add "-u") (commit "--amend" ARGS)
            '';
          };
        };
      };
  };
}
