{
  flake.modules.homeManager.git = {
    programs.git.settings.alias = {
      whoami = "config user.name";
      tree = "log --pretty=oneline --graph --decorate --all --reflog";
    };
  };
}
