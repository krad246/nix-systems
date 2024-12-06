{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) meta strings;
  name = "agenix-cachix-authtoken";
  exec = ''
    ${meta.getExe pkgs.cachix} authtoken --stdin < ${config.age.secrets.cachix.path}
  '';
  hasCachix = config.age.secrets ? cachix;

  inherit (lib) modules;
in {
  systemd.user.services."${name}" = modules.mkIf (pkgs.stdenv.isLinux && hasCachix) {
    Unit = {
      Description = "Cachix login after secrets mounting";
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

  launchd.agents."${name}" = modules.mkIf (pkgs.stdenv.isDarwin && hasCachix) {
    enable = true;
    config = {
      ProgramArguments = ["${meta.getExe pkgs.bash}" "-c" "${strings.escapeXML exec}"];
      RunAtLoad = true;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/${name}/stdout";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/${name}/stderr";
      WatchPaths = [config.age.secrets.cachix.path];
    };
  };
}
