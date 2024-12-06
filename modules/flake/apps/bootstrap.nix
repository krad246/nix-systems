{pkgs, ...}: let
  runner = pkgs.writeShellApplication {
    name = "bootstrap";
    runtimeInputs = with pkgs; [bashInteractive coreutils direnv git nix];
    text = ''
      set -x

      direnv allow "$PWD"
      exec bash --rcfile <(echo $'source ~/.bashrc; eval "$(direnv hook bash)"')
    '';
  };
in {
  type = "app";
  program = pkgs.lib.meta.getExe runner;
  meta.description = "Run the devShell bootstrap script.";
}
