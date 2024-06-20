{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (inputs) agenix;
  name = "agenix-gh-autologin";
  exec = "${pkgs.gh}/bin/gh auth login -p ssh --with-token";
in {
  imports = [agenix.homeManagerModules.age];
  age = {
    secrets.gh.file = ../secrets/gh.age;
    secrets.gh.path = "${config.home.homeDirectory}/secrets/gh";
  };

  home.packages = [agenix.packages.${pkgs.stdenv.system}.default];

  systemd.user.services."${name}" = lib.mkIf pkgs.stdenv.isLinux {
    Unit = {
      Description = "GitHub CLI login after secrets mounting";
      Requires = ["agenix.service"];
    };
    Install = {
      WantedBy = ["default.target"];
    };
    Service = {
      ExecStart = "${pkgs.bash}/bin/bash -c '${exec} < ${config.age.secrets.gh.path}'";
      Environment = ["XDG_RUNTIME_DIR=%t"];
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  launchd.agents."${name}" = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    config = {
      ProgramArguments = ["${pkgs.bash}/bin/bash" "-c" "${exec}" "&lt;" "${config.age.secrets.gh.path}"];
      RunAtLoad = true;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/${name}/stdout";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/${name}/stderr";
    };
  };
}
