{
  self,
  specialArgs,
  ...
}: let
  inherit (specialArgs) mkJustRecipeGroup nixArgs;
in {
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
          args = nixArgs lib;
        in
          (lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
            nixos-rebuild = {
              comment = "Wraps `nixos-rebuild`.";
              justfile = ''
                [linux]
                nixos-rebuild *ARGS:
                  ${lib.meta.getExe pkgs.nixos-rebuild} ${lib.strings.concatStringsSep " " args} --flake ${self} \
                    --use-remote-sudo \
                    {{ ARGS }}
              '';
            };

            _test_system = {
              justfile = ''
                [private]
                _test_system *ARGS: (nixos-rebuild "test" ARGS)
              '';
            };

            _boot_system = {
              justfile = ''
                [private]
                _boot_system *ARGS: (nixos-rebuild "boot" replace(replace(ARGS, "--specialisation", ""), hostname, ""))
              '';
            };
          })
          // (lib.attrsets.optionalAttrs pkgs.stdenv.isDarwin {
            darwin-rebuild = {
              comment = "Wraps `darwin-rebuild`.";
              justfile = ''
                [macos]
                darwin-rebuild *ARGS:
                  ${lib.meta.getExe' inputs'.darwin.packages.darwin-rebuild "darwin-rebuild"} ${lib.strings.concatStringsSep " " args} --flake ${self} {{ ARGS }}
              '';
            };

            _test_system = {
              justfile = ''
                [private]
                _test_system *ARGS: (darwin-rebuild "check" ARGS)
              '';
            };

            _boot_system = {
              justfile = ''
                [private]
                _boot_system *ARGS: (darwin-rebuild "switch" ARGS)
              '';
            };
          })
          // {
            _apply_system = {
              justfile = ''
                [private]
                _apply_system *ARGS: (_test_system ARGS) && (_boot_system ARGS)
              '';
            };

            apply-system = {
              comment = "Wraps `[darwin-rebuild | nixos-rebuild] switch`.";
              justfile = ''
                apply-system *ARGS: (lock) (_apply_system ARGS)
              '';
            };

            test-system = {
              comment = "Wraps `[darwin-rebuild | nixos-rebuild] test`.";
              justfile = ''
                test-system *ARGS: (lock) (_test_system ARGS)
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
          };
      };
  };
}
