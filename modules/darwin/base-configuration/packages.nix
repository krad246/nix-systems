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
      "${config.homebrew.prefix}/bin/bash"
      "${config.homebrew.prefix}/bin/zsh"
    ];

    systemPackages = with pkgs; [
      m-cli
    ];
  };
}
