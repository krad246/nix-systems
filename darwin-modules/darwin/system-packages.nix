{config, ...}: {
  imports = [
    ./homebrew
  ];

  homebrew = {
    brews = ["bash" "zsh"];
    casks = ["macfuse"];
  };

  environment = let
    brewRoot = "${config.homebrew.brewPrefix}";
  in {
    shells = ["${brewRoot}/bash" "${brewRoot}/zsh"];
    loginShell = "${brewRoot}/zsh";
  };
}
