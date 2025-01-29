{
  self,
  specialArgs,
  ...
}: let
  inherit (specialArgs) mkJustRecipeGroup;
in {
  perSystem = {pkgs, ...}: {
    # set up devshell commands
    just-flake.features = let
      inherit (pkgs) lib;
    in
      # Helper command aliases
      mkJustRecipeGroup {
        inherit lib;
        group = "nix";

        recipes = {
          build = {
            comment = "Wraps `nix build`.";
            justfile = ''
              build *ARGS: lock
                nix build {{ ARGS }}
            '';
          };

          develop = {
            comment = "Wraps `nix develop`.";
            justfile = ''
              develop *ARGS: lock
                nix develop {{ ARGS }}
            '';
          };

          run = {
            comment = "Wraps `nix run`.";
            justfile = ''
              run *ARGS: lock
                nix run {{ ARGS }}
            '';
          };

          search = {
            comment = "Wraps `nix search`.";
            justfile = ''
              search *ARGS:
                nix search {{ ARGS }}
            '';
          };

          shell = {
            comment = "Wraps `nix shell`.";
            justfile = ''
              shell *ARGS:
                nix shell {{ ARGS }}
            '';
          };
        };
      }
      // mkJustRecipeGroup {
        inherit lib;
        group = "flake";
        recipes = {
          show = {
            comment = "Wraps `nix flake show`.";
            justfile = ''
              show *ARGS:
                nix flake show {{ ARGS }}
            '';
          };

          check = {
            comment = "Wraps `nix flake check`.";
            justfile = ''
              check *ARGS:
                nix flake check {{ ARGS }}
            '';
          };

          repl = {
            comment = "Wraps `nix repl .`";
            justfile = ''
              repl *ARGS: lock
                nix repl --file "${self}" {{ ARGS }}
            '';
          };

          lock = {
            comment = "Wraps `git add -A && nix flake lock`.";
            justfile = ''
              lock *ARGS: (add "-A")
                nix flake lock {{ ARGS }}
            '';
          };
        };
      };
  };
}
