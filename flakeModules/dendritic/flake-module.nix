{
  config,
  inputs,
  lib,
  withSystem,
  ...
}: let
  homeManagerConfiguration = args:
    inputs.home-manager.lib.homeManagerConfiguration (
      args
      // {
        modules = [config.flake.dendritic.modules.homeManager.standalone] ++ (args.modules or []);
      }
    );
in {
  options.flake.homeConfigurations = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = {};
    description = "Mergeable registry of standalone Home Manager configurations.";
  };

  config = {
    flake-file.inputs.dendritic = {
      url = "github:krad246/nix-systems/dendritic";

      inputs = {
        agenix.follows = "agenix";
        agenix-shell.follows = "agenix-shell";
        disko.follows = "disko";
        flake-compat.follows = "flake-compat";
        flake-file.follows = "flake-file";
        flake-parts.follows = "flake-parts";
        flake-root.follows = "flake-root";
        home-manager.follows = "home-manager";
        impermanence.follows = "impermanence";
        just-flake.follows = "just-flake";
        nix-darwin.follows = "darwin";
        nix-homebrew.follows = "nix-homebrew";
        nixos-wsl.follows = "nixos-wsl";
        nixpkgs.follows = "nixpkgs";
        nixpkgs-lib.follows = "nixpkgs";
        nixpkgs-unstable.follows = "nixpkgs-unstable";
        pre-commit-hooks-nix.follows = "pre-commit-hooks-nix";
        systems.follows = "systems";
        treefmt-nix.follows = "treefmt-nix";
      };
    };

    # Stable migration seam. Consumers use this namespace while its values are
    # progressively replaced with modules materialized in the current tree.
    flake.dendritic = {
      inherit (inputs.dendritic) darwinModules modules nixosModules;
    };

    flake = {
      homeConfigurations = lib.mkIf (!lib.inPureEvalMode) {
        base = homeManagerConfiguration {
          pkgs = withSystem builtins.currentSystem ({pkgs, ...}: pkgs);
        };
      };

      nixosConfigurations.generic-headless-interactive = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          config.flake.dendritic.modules.nixos.headless
          config.flake.dendritic.modules.nixos.interactive
          ({config, ...}: {
            image.modules.vm = import ./image-modules/vm.nix;
            image.modules.vm-nogui = import ./image-modules/vm-nogui.nix {
              vm = config.image.modules.vm;
            };

            networking.hostName = "generic-headless-interactive";
          })
        ];
      };
    };

    perSystem = {
      pkgs,
      system,
      ...
    }: let
      standalone = homeManagerConfiguration {inherit pkgs;};
      cfg = standalone.config;
    in
      lib.mkMerge [
        {
          checks.home-manager-base = standalone.activationPackage;
        }
        (lib.mkIf (system == "aarch64-darwin") {
          checks = {
            dendritic-hm-base = assert cfg.home.username == "krad246";
            assert cfg.home.homeDirectory == "/Users/krad246";
            assert cfg.identity.person
            == {
              email = "krad246@gmail.com";
              name = "Keerthi Radhakrishnan";
              username = "krad246";
            };
            assert cfg.home.stateVersion == inputs.nixpkgs.lib.trivial.release;
            assert cfg.xdg.enable;
            assert cfg.manual.json.enable;
            assert !cfg.manual.html.enable;
            assert cfg.input-registry.registry.managed;
            assert !cfg.input-registry.registry.locked;
            assert !cfg.input-registry.sysroot.install;
            assert !cfg.input-registry.search-path.enable;
            assert cfg.nix.registry ? nixpkgs;
            assert cfg.nix.registry ? home-manager;
            assert cfg.nix.settings.experimental-features == ["nix-command" "flakes"];
            assert cfg.programs.home-manager.enable;
            assert cfg.shell.profiles.interactive.enable;
            assert cfg.programs.bash.enable;
            assert cfg.programs.bat.enable;
            assert cfg.programs.fzf.enable;
            assert !cfg.programs.git.enable;
            assert !cfg.programs.helix.enable;
            assert !cfg.programs.kitty.enable;
            assert !cfg.programs.rbw.enable;
              standalone.activationPackage;

            dendritic-nixbook-pro-hm = let
              configuration = inputs.dendritic.darwinConfigurations.nixbook-pro;
              cfg = configuration.config;
              home = cfg.home-manager.users.${cfg.owner.username};
            in
              assert home.home.username == cfg.owner.username;
              assert home.home.homeDirectory == "/Users/${cfg.owner.username}";
              assert home.home.stateVersion == inputs.nixpkgs.lib.trivial.release;
              assert home.programs.home-manager.enable;
              assert home.xdg.enable;
              assert home.manual.json.enable;
              assert !home.manual.html.enable;
                home.home.activationPackage;
          };
        })
        (lib.mkIf (system == "x86_64-linux") {
          checks.dendritic-hm-base = assert cfg.home.username == "krad246";
          assert cfg.home.homeDirectory == "/home/krad246";
          assert cfg.home.stateVersion == inputs.nixpkgs.lib.trivial.release;
          assert cfg.targets.genericLinux.enable;
          assert !cfg.targets.genericLinux.gpu.enable;
          assert cfg.systemd.user.startServices;
          assert cfg.input-registry.registry.managed;
          assert !cfg.input-registry.registry.locked;
          assert !cfg.input-registry.sysroot.install;
          assert !cfg.input-registry.search-path.enable;
          assert cfg.nix.registry ? nixpkgs;
          assert cfg.nix.registry ? home-manager;
          assert cfg.nix.settings.experimental-features == ["nix-command" "flakes"];
          assert cfg.shell.profiles.interactive.enable;
          assert cfg.programs.bash.enable;
            standalone.activationPackage;

          checks.generic-headless-interactive = let
            configuration = config.flake.nixosConfigurations.generic-headless-interactive;
            image = configuration.config.system.build.images.vm-nogui;
            cfg = image.passthru.config;
          in
            assert !cfg.virtualisation.graphics;
            assert !cfg.services.xserver.enable;
            assert cfg.home-manager.users.${cfg.owner.username}.shell.profiles.interactive.enable; image;
        })
      ];
  };
}
