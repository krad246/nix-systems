{specialArgs, ...}: let
  inherit (specialArgs) mkJustRecipeGroup;
in {
  perSystem = {pkgs, ...}: {
    just-flake.features = let
      inherit (pkgs) lib;
    in
      mkJustRecipeGroup {
        inherit lib;
        group = "git";
        recipes = {
          add = {
            comment = "Equivalent to `git add -u` by default, unless other args are passed.";
            justfile = ''
              add +ARGS="-u":
                git add --chmod=+x {{ ARGS }}
            '';
          };

          commit = {
            comment = "Equivalent to `git add -u` followed by `git commit --dry-run`, unless other args are passed.";
            justfile = ''
              commit +ARGS="--dry-run": (add "-u")
                git commit {{ ARGS }}
            '';
          };

          amend = {
            comment = "Equivalent to `git add -u` followed by `git commit -a --amend`, with other args passed to its invocation.";
            justfile = ''
              amend +ARGS="--dry-run": (add "-u")
                git commit -a --amend {{ ARGS }}
            '';
          };
        };
      };
  };
}
