# outer / 'flake' scope
{withSystem, ...}: {
  flake.apps = {
    aarch64-darwin = {
      fortress-disko-vm = let
        vm = withSystem "aarch64-darwin" ({self', ...}: self'.packages.fortress-disko-vm);
      in {
        type = "app";
        program = "${vm}/disko-vm";
        meta.description = "Run a disko-images VM based on the fortress configuration.";
      };
    };
  };

  perSystem = ctx @ {
    config,
    lib,
    pkgs,
    ...
  }: {
    apps = {
      bootstrap = import ./bootstrap.nix {
        inherit (ctx) config lib pkgs;
      };
    };
  };
}
