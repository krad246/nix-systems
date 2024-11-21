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
      inputArg = lib.strings.concatStringsSep " " ["--option" "inputs-from" "$FLAKE_ROOT"];
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
                    ${inputArg} \
                    --option accept-flake-config true \
                    --option builders-use-substitutes true \
                    --option keep-going true \
                    --option preallocate-contents true \
                    ${flakeArg} \
                    --use-remote-sudo \
                    {{ ARGS }}
              '';
            };

            switch = {
              comment = "Recreate the lockfile and run `nixos-rebuild switch` to switch the system derivation.";
              justfile = ''
                switch *ARGS: (nix "flake" "lock") (nixos-rebuild "switch" ARGS)
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
                    ${inputArg} \
                    --option accept-flake-config true \
                    --option keep-going true \
                    --option preallocate-contents true \
                    ${flakeArg} \
                    {{ ARGS }}
              '';
            };

            switch = {
              comment = "Recreate the lockfile and run `darwin-rebuild switch` to switch the system derivation.";
              justfile = ''
                switch *ARGS: (nix "flake" "lock") (darwin-rebuild "switch" ARGS)
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
                    ${inputArg} \
                    --option accept-flake-config true \
                    --option keep-going true \
                    --option preallocate-contents true \
                    ${flakeArg} \
                    -b bak \
                    {{ ARGS }}
              '';
            };

            upgrade = {
              comment = "Update the flake and reload the system derivation.";
              justfile = ''
                upgrade *ARGS: && (switch ARGS)
                  -exec just nix flake update
              '';
            };

            rollback = {
              comment = "Rollback the system derivation.";
              justfile = ''
                rollback *ARGS: (switch "--rollback" ARGS)
              '';
            };
          };
      };
  };
}
