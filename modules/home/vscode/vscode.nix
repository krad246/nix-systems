{
  withSystem,
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

  stripComments = path:
    pkgs.runCommand "strip-comments" {} ''
      ${lib.meta.getExe pkgs.gnused} \
        -re 's#^(([^"\n]*"[^"\n]*")*[^"\n]*)\/\/.*$#\1#' \
        ${path} >$out
    '';
in {
  home.packages = with pkgs;
    [nil nixd]
    ++ [
      (withSystem pkgs.stdenv.system ({self', ...}: self'.packages.term-fonts))
    ];

  programs.vscode = {
    enable = true;
    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;

    package =
      if pkgs.stdenv.isLinux
      then pkgs.vscode.fhsWithPackages (_ps: config.home.packages)
      else pkgs.vscode;

    extensions = [
    ];

    globalSnippets = {
    };

    keybindings = lib.trivial.importJSON (stripComments ./darwin/keybindings.json);

    languageSnippets = {
    };

    mutableExtensionsDir = false;

    userSettings = lib.trivial.importJSON (stripComments ./darwin/settings.json);

    userTasks = {
    };
  };

  # mutable store links for VSCode to actually see.
  # points at a mutable version of the dotfiles
  home.file = {
    ${keybindingsFilePath} = {
      source = config.lib.file.mkOutOfStoreSymlink "$HOME/dotfiles/modules/home/vscode/darwin/keybindings.json";
    };

    ${settingsFilePath} = {
      source = config.lib.file.mkOutOfStoreSymlink "$HOME/dotfiles/modules/home/vscode/darwin/settings.json";
    };
  };
}
