{
  self,
  config,
  ...
}: let
  cfg = config.flake.meta.owner;
in {
  flake = {
    meta.owner = {
      email = "krad246@gmail.com";
      name = "Keerthi Radhakrishnan";
      username = "krad246";
    };

    modules = {
      generic.owner = {lib, ...}: {
        options = {
          owner = {
            email = lib.options.mkOption {
              type = lib.types.str;
              default = cfg.email;
              description = "Email of the owner of this system.";
            };

            name = lib.options.mkOption {
              type = lib.types.str;
              default = cfg.name;
              description = "Name of the owner of this system.";
            };

            username = lib.options.mkOption {
              type = lib.types.str;
              default = cfg.username;
              description = "Username of the owner of this system.";
            };
          };
        };
      };

      darwin.owner = {config, ...}: let
        cfg = config.owner;
      in {
        imports = [self.modules.generic.owner];

        system.primaryUser = cfg.username;
        users.users.${cfg.username} = {
          description = cfg.name;

          createHome = true;
          home = "/Users/${cfg.username}";
        };
      };

      nixos.owner = {config, ...}: let
        cfg = config.owner;
      in {
        imports = [self.modules.generic.owner];

        users.users.${cfg.username} = {
          description = cfg.name;

          isNormalUser = true;
          extraGroups = ["wheel"];

          createHome = true;
          home = "/home/${cfg.username}";
        };
      };
    };
  };
}
