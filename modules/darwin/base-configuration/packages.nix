{
  config,
  pkgs,
  ...
}: {
  homebrew = {
    brews = ["bash" "zsh"];
  };

  environment = {
    shells = [
      "${config.homebrew.brewPrefix}/bash"
      "${config.homebrew.brewPrefix}/zsh"
    ];

    systemPackages = with pkgs; [
      m-cli
    ];
  };
}
