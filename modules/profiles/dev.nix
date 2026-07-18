{
  self,
  lib,
  ...
}: {
  flake.modules = {
    homeManager.dev = {
      imports = with self.modules.homeManager; [
        base
        editor
      ];

      shell.profiles.dev.enable = true;
      picker.backends.fzf.integrations.helix.enable = lib.modules.mkDefault true;
    };

    nixos.dev = {config, ...}: {
      home-manager.users.${config.owner.username}.imports = [
        self.modules.homeManager.dev
      ];
    };

    darwin.dev = {config, ...}: {
      home-manager.users.${config.owner.username}.imports = [
        self.modules.homeManager.dev
      ];
    };
  };
}
