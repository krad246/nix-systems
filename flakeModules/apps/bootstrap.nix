{
  config,
  lib,
  pkgs,
  ...
}: let
  runner = pkgs.writeShellApplication {
    name = "bootstrap";
    runtimeInputs = with pkgs;
      [
        bashInteractive
        git
        coreutils
        curl
        xz
      ]
      ++ [
        direnv
        nix-direnv
      ]
      ++ [nixVersions.stable];
    text = ''
      direnv allow "$(${lib.meta.getExe config.flake-root.package})"
      direnv exec "$PWD" true
    '';
  };
in {
  type = "app";
  program = pkgs.lib.meta.getExe runner;
  meta.description = "Run the devShell bootstrap script.";
}
