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
  exec = lib.strings.optionalString (config.age.secrets ? gh) ''
    ${lib.getExe pkgs.gh} auth login -p ssh --with-token ${redirect} ${config.age.secrets.gh.path}
  '';
in {
  systemd.user.services."${name}" = lib.mkIf pkgs.stdenv.isLinux {
    Unit = {
      Description = "GitHub CLI login after secrets mounting";
      Requires = ["agenix.service"];
    };
    Install = {
      WantedBy = ["default.target"];
    };
    Service = {
      ExecStart = "${lib.getExe pkgs.bash} -c '${exec}'";
      Environment = ["XDG_RUNTIME_DIR=%t"];
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  launchd.agents."${name}" = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    config = {
      ProgramArguments = ["${lib.getExe pkgs.bash}" "-c" "${exec}"];
      RunAtLoad = true;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/${name}/stdout";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/${name}/stderr";
      WatchPaths = [config.age.secrets.gh.path];
    };
  };
}
