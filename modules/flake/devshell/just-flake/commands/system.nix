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
          flakeArg = lib.strings.concatStringsSep " " ["--flake" "$FLAKE_ROOT"];
        in
          (lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
            # Add a wrapper around nixos-rebuild to devShell instances if we're on Linux
            nixos-rebuild = {
              comment = "Wraps `nixos-rebuild`.";
              justfile = ''
                [linux]
                @nixos-rebuild *ARGS: (add)
                  #!${lib.meta.getExe pkgs.bash}
                  ${lib.meta.getExe pkgs.nixos-rebuild} \
                    --option experimental-features 'nix-command flakes' \
                    --option inputs-from ${self} \
                    --option accept-flake-config true \
                    --option builders-use-substitutes true \
                    --option keep-going true \
                    --option preallocate-contents true \
                    ${flakeArg} \
                    --use-remote-sudo \
                    {{ ARGS }}
              '';
            };

            _apply_system = {
              justfile = ''
                [private]
                _apply_system *ARGS: (nixos-rebuild "switch" ARGS)
                  -exec {{ just_executable() }} nixos-rebuild switch --specialisation "$HOSTNAME" {{ ARGS }}
              '';
            };
          })
          // (lib.attrsets.optionalAttrs pkgs.stdenv.isDarwin {
            # Add a wrapper around nixos-rebuild to devShell instances if we're on Darwin
            darwin-rebuild = {
              comment = "Wraps `darwin-rebuild`.";
              justfile = ''
                [macos]
                @darwin-rebuild *ARGS: (add)
                  #!${lib.meta.getExe pkgs.bash}
                  ${lib.meta.getExe' inputs'.darwin.packages.darwin-rebuild "darwin-rebuild"} \
                    --option experimental-features 'nix-command flakes' \
                    --option inputs-from ${self} \
                    --option accept-flake-config true \
                    --option keep-going true \
                    --option preallocate-contents true \
                    ${flakeArg} \
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
                @home-manager *ARGS: (add)
                  #!${lib.meta.getExe pkgs.bash}
                  ${lib.meta.getExe pkgs.home-manager} \
                    --option experimental-features 'nix-command flakes' \
                    --option inputs-from ${self} \
                    --option accept-flake-config true \
                    --option keep-going true \
                    --option preallocate-contents true \
                    ${flakeArg} \
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
