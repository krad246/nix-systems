{
  withSystem,
  pkgs,
  ...
}: {
  home.packages = with pkgs;
    [nil nixd]
    ++ [
      (withSystem pkgs.stdenv.system ({self', ...}: self'.packages.term-fonts))
    ];
  programs.vscode = {
    enable = true;
    package =
      if pkgs.stdenv.isLinux
      then
        pkgs.vscode.fhsWithPackages (ps:
          [ps.nil ps.nixd]
          ++ [
            (withSystem pkgs.stdenv.system ({self', ...}: self'.packages.term-fonts))
          ])
      else pkgs.vscode;
  };
}
