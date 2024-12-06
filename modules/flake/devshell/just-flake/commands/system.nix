# outer / 'flake' scope
{
  mkJustRecipeGroup,
  self,
  ...
}: {
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

        group = "system";

        recipes = let
          args = lib.cli.toGNUCommandLine {} {
            option = [
              "inputs-from ${self}"
              "experimental-features 'nix-command flakes'"
              "keep-going true"
              "show-trace true"
              "accept-flake-config true"
              "builders-use-substitutes true"
              "preallocate-contents true"
            ];
            flake = "$FLAKE_ROOT";
          };
        in
          (lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
            # Add a wrapper around nixos-rebuild to devShell instances if we're on Linux
            nixos-rebuild = {
              comment = "Wraps `nixos-rebuild`.";
              justfile = ''
                [linux]
                @nixos-rebuild *ARGS:
                  #!${lib.meta.getExe pkgs.bash}
                  ${lib.meta.getExe pkgs.nixos-rebuild} \
                    ${lib.strings.concatStringsSep " " args} \
                    --use-remote-sudo \
                    {{ ARGS }}
              '';
            };

            _apply_system = {
              justfile = ''
                [private]
                _apply_system *ARGS: (nixos-rebuild "boot" ARGS)
                  {{ just_executable() }} nixos-rebuild switch --specialisation "$HOSTNAME" {{ ARGS }}
              '';
            };
          })
          // (lib.attrsets.optionalAttrs pkgs.stdenv.isDarwin {
            # Add a wrapper around nixos-rebuild to devShell instances if we're on Darwin
            darwin-rebuild = {
              comment = "Wraps `darwin-rebuild`.";
              justfile = ''
                [macos]
                @darwin-rebuild *ARGS:
                  #!${lib.meta.getExe pkgs.bash}
                  ${lib.meta.getExe' inputs'.darwin.packages.darwin-rebuild "darwin-rebuild"}                     ${lib.strings.concatStringsSep " " args} \
                    {{ ARGS }}
              '';
            };

            _apply_system = {
              justfile = ''
                [private]
                _apply_system *ARGS: (darwin-rebuild "switch" ARGS)
              '';
            };
          })
          // {
            # Home configs work on all *nix systems
            home-manager = {
              comment = "Wraps `home-manager`.";

              justfile = ''
                [unix]
                @home-manager *ARGS:
                  #!${lib.meta.getExe pkgs.bash}
                  ${lib.meta.getExe pkgs.home-manager} \
                    ${lib.strings.concatStringsSep " " args} \
                    -b bak \
                    {{ ARGS }}
              '';
            };

            apply-system = {
              comment = "Wraps `[darwin-rebuild | nixos-rebuild] switch`.";
              justfile = ''
                apply-system *ARGS: (lock) (_apply_system ARGS)
              '';
            };

            upgrade-system = {
              comment = "Update the flake and then run `apply-system`.";
              justfile = ''
                upgrade-system *ARGS: (update) (_apply_system ARGS)
              '';
            };

            rollback-system = {
              comment = "Thin wrapper around `switch --rollback`.";
              justfile = ''
                rollback-system *ARGS: (apply-system "--rollback" ARGS)
              '';
            };

            apply-home = {
              comment = "Wraps `home-manager switch`.";
              justfile = ''
                apply-home *ARGS: (lock) (home-manager "switch" ARGS)
              '';
            };
          };
      };
  };
}
