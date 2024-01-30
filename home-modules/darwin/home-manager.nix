# https://github.com/nix-community/home-manager/issues/1341#issuecomment-1716147796
{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (inputs) mac-app-util;
  inherit (pkgs.stdenv) system;
  instantiate = mac-app-util.packages.${system}.default;

  # The upstream maintainer did not add the mainProgram attribute, so we are
  # patching it in here.
  addMainProgram = drv: lib.meta.addMetaAttrs {mainProgram = lib.getName drv;} drv;
  fixup = addMainProgram instantiate;
in {
  imports = [mac-app-util.homeManagerModules.default];

  # Inject an activation script that reshims the app folders as described
  # in the attached issue.
  home.activation = {
    trampolineApps = lib.mkForce (lib.hm.dag.entryAfter ["writeBoundary"] ''
      fromDir="${config.home.sessionVariables.HOME}/Applications/Home Manager Apps"
      toDir="${config.home.sessionVariables.HOME}/Applications/Home Manager Trampolines"
      ${lib.getExe fixup} sync-trampolines "$fromDir" "$toDir"
    '');
  };
}
