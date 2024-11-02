{
  self,
  inputs,
  pkgs,
  ezModules,
  ...
}: let
  inherit (inputs) mac-app-util;
in {
  imports = with ezModules;
    ([colima] ++ [discord kitty vscode])
    ++ [self.modules.generic.agenix-home]
    ++ [mac-app-util.homeManagerModules.default];

  home = {
    packages = with pkgs; [m-cli];
  };
}
