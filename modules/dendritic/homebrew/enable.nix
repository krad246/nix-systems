{inputs, ...}: {
  flake-file.inputs.nix-homebrew = {
    url = "github:zhaofengli-wip/nix-homebrew";
  };

  flake.modules.darwin.homebrew = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [inputs.nix-homebrew.darwinModules.nix-homebrew];

    options.appManagement.backends.homebrew.enable =
      lib.options.mkEnableOption "Homebrew application-management backend";

    config = lib.modules.mkIf config.appManagement.backends.homebrew.enable {
      nix-homebrew = {
        enable = true;
        enableRosetta = pkgs.stdenv.hostPlatform.isAarch64;
        autoMigrate = true;
        user = config.owner.username;
      };

      homebrew = {
        enable = true;
        global.brewfile = true;
        onActivation = {
          autoUpdate = true;
          cleanup = "zap";
          upgrade = true;
        };
      };
    };
  };
}
