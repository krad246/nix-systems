{ezModules, ...}: {
  imports = with ezModules; [darwin homebrew] ++ [arc signal] ++ [nerdfonts];
}
