{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.miniboi = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      # {
      #   imports = with self.modules.nixos; [
      #     theme
      #     kmscon
      #   ];

      #   stylix = {
      #     targets = {
      #       # console.enable = true;
      #       kmscon.enable = true;
      #     };
      #   };
      # }
      ({config, ...}: {
        imports = with self.modules.nixos; [
          headless
        ];

        networking.hostName = "miniboi";
        security.sudo.wheelNeedsPassword = false;
        users.users.${config.owner.username}.initialHashedPassword = "";
      })

      {
        imports = [self.modules.nixos.disko];
      }
      {
        imports = [self.diskoConfigurations.simple];
      }

      {
        imports = [self.modules.nixos.bootloader];

        boot.loader = {
          enable = true;
          mode = "efi";
        };
      }
      ({lib, ...}: {
        nixpkgs.hostPlatform =
          if lib.trivial.inPureEvalMode
          then "aarch64-linux"
          else builtins.currentSystem;
      })
    ];
  };

  perSystem = {
    lib,
    pkgs,
    ...
  }: {
    legacyPackages = let
      outputs = self.nixosConfigurations.miniboi.extendModules {
        modules = [
          {
            virtualisation = {
              vmVariant = {
                virtualisation.host = {inherit pkgs;};
              };

              vmVariantWithBootLoader = {
                virtualisation = {
                  host = {inherit pkgs;};
                  diskSize = 20 * 1024;
                };
              };
            };
          }
          {
            virtualisation.vmVariantWithDisko = {
              virtualisation.host = {inherit pkgs;};
            };
          }

          # Sensible default: cross-compile from one Linux to another
          (lib.modules.mkIf pkgs.stdenv.hostPlatform.isLinux {
            nixpkgs.buildPlatform = pkgs.stdenv.hostPlatform.system;
          })
          # If we're on Darwin, we (presumably) have a Linux builder
          # for the same machine architecture. Use that to cross-compile.
          (lib.modules.mkIf pkgs.stdenv.hostPlatform.isDarwin {
            nixpkgs.buildPlatform = lib.systems.parse.doubleFromSystem {
              inherit (pkgs.stdenv.hostPlatform.parsed) cpu;
              kernel = lib.systems.parse.kernels.linux;
              vendor = lib.systems.parse.vendors.unknown;
              abi = lib.systems.parse.abis.gnu;
            };
          })
        ];
      };
    in {nixosConfigurations.miniboi = outputs;};
  };
}
