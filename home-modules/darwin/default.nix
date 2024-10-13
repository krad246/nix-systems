{
  pkgs,
  ezModules,
  ...
}: {
  imports = with ezModules; [discord kitty nerdfonts vscode];

  home = {
    packages = with pkgs; [m-cli];
  };
}
