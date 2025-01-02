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
      mkJustRecipeGroup {
        inherit lib;

        group = "home";

        recipes = let
          args = nixArgs lib;
        in {
          # Home configs work on all *nix systems
          home-manager = {
            comment = "Wraps `home-manager`.";

            justfile = ''
              [unix]
              home-manager *ARGS:
                ${lib.meta.getExe pkgs.home-manager} ${lib.strings.concatStringsSep " " args} --flake ${self} -b bak {{ ARGS }}
            '';
          };

          apply-home = {
            justfile = ''
              apply-home PROFILE="default" +ARGS="": (lock)
                exec {{ just_executable() }} build --print-out-paths \
                  {{ ARGS }} "${self}#homeConfigurations.{{ whoami }}@{{ hostname }}.activationPackage" | \
                  ${lib.meta.getExe' pkgs.findutils "xargs"} -I {drv} \
                  ${lib.meta.getExe pkgs.bashInteractive} {drv}/specialisation/{{ PROFILE }}/activate
            '';
          };
        };
      };
  };
}
