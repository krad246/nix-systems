{
  pkgs,
  ezModules,
  ...
}: {
  imports =
    (with ezModules; [discord kitty nerdfonts vscode])
    ++ [./unionfs.nix ./mac-app-util.nix];

  home = {
    packages = with pkgs; [m-cli];
  };
}
