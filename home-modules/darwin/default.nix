{
  pkgs,
  ezModules,
  ...
}: {
  imports =
    [./unionfs.nix ./mac-app-util.nix]
    ++ (with ezModules; [discord kitty vscode]);

  home = {
    packages = with pkgs; [m-cli];
  };
}
