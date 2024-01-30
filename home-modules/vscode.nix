{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;
  programs.vscode = {
    enable = true;
    package =
      if pkgs.stdenv.isLinux
      then pkgs.vscode.fhs
      else pkgs.vscode;
  };
}
