{
  withSystem,
  config,
  lib,
  pkgs,
  ...
}: let
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
}
