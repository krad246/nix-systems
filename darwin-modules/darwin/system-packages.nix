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
    loginShell = "${brewRoot}/bash";
    systemPackages = with pkgs; ([ m-cli ] ++ [ coreutils safe-rm ] );
  };
}
