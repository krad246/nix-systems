{
  config,
  pkgs,
  ...
}: let
  brewRoot = "${config.homebrew.brewPrefix}";
in {
  homebrew = {
    brews = ["bash" "zsh"];
    casks = ["macfuse"];
  };

  environment = {
    shells = ["${brewRoot}/bash" "${brewRoot}/zsh"];
    systemPackages = with pkgs; ([m-cli] ++ [coreutils safe-rm] ++ [dust]);
  };
}
