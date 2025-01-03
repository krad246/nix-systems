{
  config,
  lib,
  pkgs,
  ...
}: let
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
    ${lib.meta.getExe pkgs.gh} auth login -p ssh --with-token ${redirect} ${config.age.secrets.gh.path}
  '';
in {
  systemd.user.services."${name}" = lib.modules.mkIf (pkgs.stdenv.isLinux && (config.age.secrets ? gh)) {
    Unit = {
      Description = "GitHub CLI login after secrets mounting";
      Requires = ["agenix.service"];
    };
    Install = {
      WantedBy = ["default.target"];
    };
    Service = {
      ExecStart = "${lib.meta.getExe pkgs.bash} -c '${exec}'";
      Environment = ["XDG_RUNTIME_DIR=%t"];
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  launchd.agents."${name}" = lib.modules.mkIf (pkgs.stdenv.isDarwin && (config.age.secrets ? gh)) {
    enable = true;
    config = {
      ProgramArguments = ["${lib.meta.getExe pkgs.bash}" "-c" "${exec}"];
      RunAtLoad = true;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/${name}/stdout";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/${name}/stderr";
      WatchPaths = [config.age.secrets.gh.path];
    };
  };
}
