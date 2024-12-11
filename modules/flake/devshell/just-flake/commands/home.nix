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
      mkJustRecipeGroup {
        inherit lib;

        group = "home";

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
            flake = "{{ flake }}";
          };
        in {
          # Home configs work on all *nix systems
          home-manager = {
            comment = "Wraps `home-manager`.";

            justfile = ''
              [unix]
              home-manager *ARGS:
                ${lib.meta.getExe pkgs.home-manager} ${lib.strings.concatStringsSep " " args} -b bak {{ ARGS }}
            '';
          };

          apply-home = {
            justfile = ''
              apply-home PROFILE="default" +ARGS="": (lock)
                exec {{ just_executable() }} build --print-out-paths \
                  {{ ARGS }} "{{ flake }}#homeConfigurations.{{ whoami }}@{{ hostname }}.activationPackage" | \
                  ${lib.meta.getExe' pkgs.findutils "xargs"} -I {drv} \
                  ${lib.meta.getExe pkgs.bashInteractive} {drv}/specialisation/{{ PROFILE }}/activate
            '';
          };
        };
      };
  };
}
