{
  self,
  pkgs,
  ezModules,
  ...
}: {
  imports = with ezModules; ([colima] ++ [discord kitty vscode]) ++ [self.modules.generic.agenix-home];

  home = {
    packages = with pkgs; [m-cli];
  };
}
