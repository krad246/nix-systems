{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) meta;
  name = "agenix-gh-auth-login";
  redirect =
    if pkgs.stdenv.isLinux
    then "<"
    else
      (
        if pkgs.stdenv.isDarwin
        then "&lt;"
        else
          throw
          "Illegal platform for this module!"
      );
  exec = ''
    ${meta.getExe pkgs.gh} auth login -p ssh --with-token ${redirect} ${config.age.secrets.gh.path}
  '';

  inherit (lib) modules;
in {
  systemd.user.services."${name}" = modules.mkIf (pkgs.stdenv.isLinux && (config.age.secrets ? gh)) {
    Unit = {
      Description = "GitHub CLI login after secrets mounting";
      Requires = ["agenix.service"];
    };
    Install = {
      WantedBy = ["default.target"];
    };
    Service = {
      ExecStart = "${meta.getExe pkgs.bash} -c '${exec}'";
      Environment = ["XDG_RUNTIME_DIR=%t"];
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  launchd.agents."${name}" = modules.mkIf (pkgs.stdenv.isDarwin && (config.age.secrets ? gh)) {
    enable = true;
    config = {
      ProgramArguments = ["${meta.getExe pkgs.bash}" "-c" "${exec}"];
      RunAtLoad = true;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/${name}/stdout";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/${name}/stderr";
      WatchPaths = [config.age.secrets.gh.path];
    };
  };
}
