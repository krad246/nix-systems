{
  nixArgs,
  self,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) cli meta strings;
  runner = pkgs.writeShellApplication {
    name = "devour-flake";

    text = let
      runner = pkgs.callPackage inputs.devour-flake {};
      args = strings.concatStringsSep " " (cli.toGNUCommandLine {} (nixArgs lib));
    in ''
      set -x
      ${meta.getExe runner} "${self}" ${args} "$@"
    '';
  };
in {
  type = "app";
  program = meta.getExe runner;
  meta.description = "Build all flake outputs in parallel.";
}
