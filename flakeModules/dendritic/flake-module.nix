{
  config,
  inputs,
  lib,
  ...
}: {
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
    flake.dendritic = rec {
      inherit (inputs.dendritic) darwinModules nixosModules;

      modules =
        inputs.dendritic.modules
        // {
          homeManager =
            inputs.dendritic.modules.homeManager
            // rec {
              base = {
                lib,
                pkgs,
                ...
              }: {
                imports = [
                  inputs.dendritic.homeModules.home-manager
                  inputs.dendritic.homeModules.identity
                ];

                config = lib.mkMerge [
                  {
                    home.preferXdgDirectories = true;
                    manual = {
                      html.enable = false;
                      json.enable = true;
                    };
                    news.display = "silent";
                    xdg.enable = true;
                  }
                  (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
                    targets.genericLinux = {
                      enable = true;
                      gpu.enable = lib.mkDefault false;
                    };

                    systemd.user.startServices = "sd-switch";
                  })
                ];
              };

              standalone = {
                config,
                pkgs,
                ...
              }: {
                imports = [base];

                home = {
                  username = lib.mkDefault config.identity.person.username;
                  homeDirectory = lib.mkDefault (
                    if pkgs.stdenv.hostPlatform.isDarwin
                    then "/Users/${config.identity.person.username}"
                    else "/home/${config.identity.person.username}"
                  );
                };

                nix.package = lib.mkDefault pkgs.nix;
              };
            };
        };

      homeModules = modules.homeManager;

      homeConfigurations = let
        inherit (config.flake.dendritic.homeModules) standalone;
      in {
        base-aarch64-darwin = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
          modules = [standalone];
        };

        base-x86_64-linux = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
          modules = [standalone];
        };
      };
    };

    flake = {
      homeConfigurations = lib.mkIf (!lib.inPureEvalMode) {
        base = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = import inputs.nixpkgs {
            system = builtins.currentSystem;
            config.allowUnfree = true;
          };
          modules = let inherit (config.flake.dendritic.homeModules) standalone; in [standalone];
        };
      };

      nixosConfigurations.generic-headless-interactive = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          config.flake.dendritic.modules.nixos.headless
          config.flake.dendritic.modules.nixos.interactive
          ({
            config,
            lib,
            ...
          }: {
            image.modules.vm = {
              config,
              modulesPath,
              ...
            }: {
              imports = ["${modulesPath}/virtualisation/qemu-vm.nix"];

              system.build.image = config.system.build.vm;
            };

            image.modules.vm-nogui = {
              imports = [config.image.modules.vm];
              virtualisation.graphics = false;
            };

            home-manager.users.krad246 = {
              home.stateVersion = lib.mkForce "26.05";
            };

            networking.hostName = "generic-headless-interactive";
            system.stateVersion = lib.mkForce "25.11";
          })
        ];
      };
    };

    perSystem = {system, ...}:
      lib.mkMerge [
        (lib.mkIf (system == "aarch64-darwin") {
          checks.dendritic-hm-base = let
            configuration = config.flake.dendritic.homeConfigurations.base-aarch64-darwin;
            cfg = configuration.config;
          in
            assert cfg.home.username == "krad246";
            assert cfg.home.homeDirectory == "/Users/krad246";
            assert cfg.identity.person
            == {
              email = "krad246@gmail.com";
              name = "Keerthi Radhakrishnan";
              username = "krad246";
            };
            assert cfg.xdg.enable;
            assert cfg.manual.json.enable;
            assert !cfg.manual.html.enable;
            assert cfg.programs.home-manager.enable;
            assert !cfg.programs.bash.enable;
            assert !cfg.programs.bat.enable;
            assert !cfg.programs.fzf.enable;
            assert !cfg.programs.git.enable;
            assert !cfg.programs.helix.enable;
            assert !cfg.programs.kitty.enable;
            assert !cfg.programs.rbw.enable;
              configuration.activationPackage;
        })
        (lib.mkIf (system == "x86_64-linux") {
          packages.generic-headless-interactive-vm =
            config.flake.nixosConfigurations.generic-headless-interactive.config.system.build.images.vm-nogui;

          checks.dendritic-hm-base = let
            configuration = config.flake.dendritic.homeConfigurations.base-x86_64-linux;
            cfg = configuration.config;
          in
            assert cfg.home.username == "krad246";
            assert cfg.home.homeDirectory == "/home/krad246";
            assert cfg.targets.genericLinux.enable;
            assert !cfg.targets.genericLinux.gpu.enable;
            assert cfg.systemd.user.startServices;
              configuration.activationPackage;

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
