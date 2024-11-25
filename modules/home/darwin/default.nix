{
  self,
  inputs,
  pkgs,
  ...
}: let
  inherit (inputs) mac-app-util;
in {
  imports = with self.homeModules;
    ([colima] ++ [discord kitty vscode])
    ++ [self.modules.generic.agenix-home]
    ++ [mac-app-util.homeManagerModules.default];

  home = {
    packages = with pkgs; [mas m-cli];
  };
}
