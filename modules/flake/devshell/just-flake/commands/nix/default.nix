{
  mkJustRecipeGroup,
  self,
  ...
}: {
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
          nix = {
            comment = "Wraps `nix`. Pass arguments as normal.";
            justfile = ''
              [unix]
              nix VERB *ARGS: (add)
                ${lib.meta.getExe pkgs.nixVersions.stable} {{ VERB }} \
                  --option experimental-features 'nix-command flakes' \
                  --option inputs-from ${self} \
                  --option accept-flake-config true \
                  --option builders-use-substitutes true \
                  --option keep-going true \
                  --option preallocate-contents true \
                  {{ ARGS }}
            '';
          };

          build = {
            comment = "Wraps `nix build`.";
            justfile = ''
              build *ARGS: (nix "build" ARGS)
            '';
          };

          develop = {
            comment = "Wraps `nix develop`.";
            justfile = ''
              develop *ARGS: (nix "develop" ARGS)
            '';
          };

          flake = {
            comment = "Wraps `nix flake`.";
            justfile = ''
              flake *ARGS: (fmt) (nix "flake" ARGS)
            '';
          };

          run = {
            comment = "Wraps `nix run`.";
            justfile = ''
              run *ARGS: (nix "run" ARGS)
            '';
          };

          search = {
            comment = "Wraps `nix search`.";
            justfile = ''
              search *ARGS: (nix "search" ARGS)
            '';
          };

          shell = {
            comment = "Wraps `nix shell`.";
            justfile = ''
              shell *ARGS: (nix "shell" ARGS)
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
              show *ARGS: (flake "show" ARGS)
            '';
          };

          check = {
            comment = "Wraps `nix flake check`.";
            justfile = ''
              check *ARGS: (flake "check" ARGS)
            '';
          };

          repl = {
            comment = "Wraps `nix repl .`";
            justfile = ''
              repl *ARGS: (nix "repl" "--file" "$FLAKE_ROOT")
            '';
          };

          lock = {
            comment = "Wraps `nix flake lock`.";
            justfile = ''
              lock *ARGS: (nix "flake" "lock" ARGS)
            '';
          };

          update = {
            comment = "Wraps `nix flake update`.";
            justfile = ''
              update *ARGS:
                -exec {{ just_executable() }} nix flake update {{ ARGS }}
            '';
          };
        };
      };
  };
}
