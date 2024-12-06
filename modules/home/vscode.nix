{pkgs, ...}: {
  home.packages = with pkgs; [nil nixd nixpkgs-fmt];
  programs.vscode = {
    enable = true;
    package =
      if pkgs.stdenv.isLinux
      then pkgs.vscode.fhsWithPackages (ps: with ps; [nodejs nil nixd nixpkgs-fmt])
      else pkgs.vscode;
  };
}
