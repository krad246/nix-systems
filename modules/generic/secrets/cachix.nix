{
  config,
  lib,
  pkgs,
  ...
}: let
  name = "agenix-cachix-authtoken";
  exec = ''
    ${lib.getExe pkgs.cachix} authtoken --stdin < ${config.age.secrets.cachix.path}
  '';
  hasCachix = config.age.secrets ? cachix;
in {
  systemd.user.services."${name}" = lib.modules.mkIf (pkgs.stdenv.isLinux && hasCachix) {
    Unit = {
      Description = "Cachix login after secrets mounting";
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

  launchd.agents."${name}" = lib.modules.mkIf (pkgs.stdenv.isDarwin && hasCachix) {
    enable = true;
    config = {
      ProgramArguments = ["${lib.getExe pkgs.bash}" "-c" "${lib.strings.escapeXML exec}"];
      RunAtLoad = true;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/${name}/stdout";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/${name}/stderr";
      WatchPaths = [config.age.secrets.cachix.path];
    };
  };
}
