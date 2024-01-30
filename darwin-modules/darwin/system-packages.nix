{
  config,
  pkgs,
  ...
}: let
  brewRoot = "${config.homebrew.brewPrefix}";
in {
  imports = [
    ./homebrew
  ];

  homebrew = {
    brews = ["bash" "zsh"];
    casks = ["macfuse"];
  };

  environment = {
    shells = ["${brewRoot}/bash" "${brewRoot}/zsh"];
    loginShell = "${brewRoot}/zsh";
    systemPackages = [pkgs.m-cli];
  };
}
