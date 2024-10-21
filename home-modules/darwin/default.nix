{
  self,
  pkgs,
  ezModules,
  ...
}: {
  imports = with ezModules; [discord kitty nerdfonts vscode] ++ [self.modules.generic.agenix-home];

  home = {
    packages = with pkgs; [m-cli];
  };
}
