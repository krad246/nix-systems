{pkgs, ...}: let
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
      direnv allow "$PWD"
      direnv exec "$PWD" true
    '';
  };
in {
  type = "app";
  program = pkgs.lib.meta.getExe runner;
  meta.description = "Run the devShell bootstrap script.";
}
