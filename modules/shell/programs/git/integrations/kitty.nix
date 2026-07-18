{lib, ...}: {
  flake.modules.homeManager.git = {
    config,
    options,
    ...
  }: {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "git" "integrations" "kitty" "enable"]
        ["programs" "kitty" "enableGitIntegration"]
      )
    ];

    config = lib.modules.mkIf (options ? terminal.backends.kitty.enable) {
      shell.programs.git.integrations.kitty.enable =
        lib.modules.mkDefault config.terminal.backends.kitty.enable;
    };
  };
}
