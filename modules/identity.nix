{
  config,
  lib,
  ...
}: let
  inherit (config.flake.meta) owner;
in {
  flake.modules.homeManager.identity = {
    options.identity = {
      person = {
        email = lib.options.mkOption {
          type = lib.types.str;
          default = owner.email;
          description = "Primary email address for this identity.";
        };

        name = lib.options.mkOption {
          type = lib.types.str;
          default = owner.name;
          description = "Full name for this identity.";
        };

        username = lib.options.mkOption {
          type = lib.types.str;
          default = owner.username;
          description = "Username for this identity.";
        };
      };
    };
  };
}
