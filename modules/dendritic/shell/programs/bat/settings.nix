{
  flake.modules.homeManager.bat = {
    programs.bat.config = {
      # lessopen = true;
      set-terminal-title = true;
      theme = "gruvbox-dark";
    };
  };
}
