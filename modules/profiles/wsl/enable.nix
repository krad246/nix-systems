{
  inputs,
  self,
  ...
}: {
  flake.modules.nixos.wsl = {config, ...}: {
    imports =
      [
        inputs.nixos-wsl.nixosModules.wsl
      ]
      ++ [
        self.modules.nixos.headless
      ];

    wsl = {
      enable = true;
      defaultUser = config.owner.username;
      tarball.configPath = self;
    };

    image.modules.wsl = {config, ...}: {
      system.build.image = config.system.build.tarballBuilder;
    };
  };
}
