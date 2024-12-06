{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) meta;

  runner = pkgs.writeShellApplication {
    name = "bootstrap";
    runtimeInputs = with pkgs; [bashInteractive coreutils direnv git nix];
    text = let
      startupCommands = ''
        --rcfile <(echo $'source ~/.bashrc; eval "$(direnv hook bash)"')
      '';
    in ''
      set -x

      direnv allow "$PWD"
      exec bash ${startupCommands}
    '';
  };
in {
  type = "app";
  program = meta.getExe runner;
  meta.description = "Run the devShell bootstrap script.";
}
