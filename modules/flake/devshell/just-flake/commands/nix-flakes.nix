{
  self,
  specialArgs,
  ...
}: let
  inherit (specialArgs) mkJustRecipeGroup nixArgs;
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
          nix = let
            args = nixArgs {inherit lib;};
          in {
            comment = "Wraps `nix`. Pass arguments as normal.";
            justfile = ''
              [unix]
              nix *ARGS:
                ${lib.meta.getExe pkgs.nixVersions.stable} \
                  ${lib.strings.concatStringsSep " " args} \
                  {{ ARGS }}
            '';
          };

          build = {
            comment = "Wraps `nix build`.";
            justfile = ''
              build *ARGS: lock && (nix "build" ARGS)
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
              flake *ARGS: lock && (nix "flake" ARGS)
            '';
          };

          run = {
            comment = "Wraps `nix run`.";
            justfile = ''
              run *ARGS: lock && (nix "run" ARGS)
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
              repl *ARGS: lock && (nix "repl" "--file" "${self}")
            '';
          };

          lock = {
            comment = "Wraps `nix flake lock`.";
            justfile = ''
              lock *ARGS: (add "-A") (nix "flake" "lock" ARGS)
                -nix-direnv-reload
            '';
          };

          update = {
            comment = "Wraps `nix flake update`.";
            justfile = ''
              update *ARGS:
                -exec {{ just_executable() }} flake update {{ ARGS }}
            '';
          };
        };
      };
  };
}
