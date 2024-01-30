{
  config,
  ezModules,
  pkgs,
  ...
}: {
  imports = [ezModules.homebrew];

  homebrew = {
    brews = ["bash" "zsh"];
  };

  environment = let
    brewRoot = "${config.homebrew.brewPrefix}";
  in {
    systemPackages = with pkgs; [m-cli];

    shells = ["${brewRoot}/bash" "${brewRoot}/zsh"];
    loginShell = "${brewRoot}/zsh";
  };
}
