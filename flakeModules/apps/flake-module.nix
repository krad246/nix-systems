# outer / 'flake' scope
{
  perSystem = {
    config,
    lib,
    pkgs,
    ...
  }: {
    apps = {
      bootstrap = let
        runner = pkgs.callPackage ./bootstrap.nix {
          flake-root = config.flake-root.package;
        };
      in {
        type = "app";
        program = lib.meta.getExe runner;
        meta.description = "Run the devShell bootstrap script.";
      };
    };
  };
}
