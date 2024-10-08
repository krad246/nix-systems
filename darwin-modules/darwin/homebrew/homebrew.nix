{config, ...}: {
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };

    taps = [
      "homebrew/services"
    ];

    global.brewfile = true;
  };

  environment.systemPath = ["${config.homebrew.brewPrefix}"];
}
