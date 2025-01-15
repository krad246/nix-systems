{
  withSystem,
  self,
  config,
  lib,
  pkgs,
  ...
}: let
  userDir =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "Library/Application Support/Code/User"
    else "${config.xdg.configHome}/Code/User";

  settingsFilePath = "${userDir}/settings.json";
  keybindingsFilePath = "${userDir}/keybindings.json";
in {
  home.packages = with pkgs;
    [nil nixd]
    ++ [
      (withSystem pkgs.stdenv.system ({self', ...}: self'.packages.term-fonts))
    ];

  programs.vscode = let
    stripComments = path:
      pkgs.runCommand "strip-comments" {} ''
        ${lib.meta.getExe' pkgs.gcc "cpp"} -P -E "${path}" > "$out"
      '';
  in {
    enable = true;

    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;

    package =
      if pkgs.stdenv.isLinux
      then
        pkgs.vscode.fhsWithPackages (ps:
          withSystem ps.stdenv.system ({
            self',
            pkgs,
            ...
          }:
            [self'.packages.term-fonts] ++ [pkgs.nil pkgs.nixd]))
      else pkgs.vscode;

    extensions = [
    ];

    globalSnippets = {
    };

    # immutable reference to configuration generated here
    keybindings = lib.trivial.importJSON (stripComments (self + "/assets/${keybindingsFilePath}"));
    userSettings = lib.trivial.importJSON (stripComments (self + "/assets/${settingsFilePath}"));

    languageSnippets = {
    };

    mutableExtensionsDir = false;

    userTasks = {
    };
  };
}
