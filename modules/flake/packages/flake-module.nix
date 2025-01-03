forwarded @ {self, ...}: let
  # Sets up container image packages, custom devShell derivation within the container
  # VSCode *is* supported!
  containers = import ./containers forwarded;
  nixos-generators = import ./nixos-generators forwarded;
  disko-config = import ./disko forwarded;
  nerdfonts = import ./nerdfonts forwarded;
in {
  imports = [
    containers.flakeModule
    disko-config.flakeModule
    nixos-generators.flakeModule
    nerdfonts.flakeModule
  ];

  # export the flake modules we loaded to this context for user consumption
  flake = rec {
    flakeModules = {
      containers = containers.flakeModule;
      nixos-generators = nixos-generators.flakeModule;
      disko-config = disko-config.flakeModule;
      nerdfonts = nerdfonts.flakeModule;
    };

    modules.flake = flakeModules;

    packages = {
      aarch64-darwin = {
        "krad246@nixbook-pro" = self.homeConfigurations."krad246@nixbook-pro".activationPackage;
        "krad246@dullahan" = self.homeConfigurations."krad246@dullahan".activationPackage;
        "krad246@nixbook-air" = self.homeConfigurations."krad246@nixbook-air".activationPackage;
      };

      x86_64-linux = {
        "krad246@fortress" = self.homeConfigurations."krad246@fortress".activationPackage;
        "krad246@windex" = self.homeConfigurations."krad246@windex".activationPackage;
        "keerad@windex" = self.homeConfigurations."keerad@windex".activationPackage;
      };

      aarch64-linux = {
        "krad246@fortress" = let
          extended = self.homeConfigurations."krad246@fortress".extendModules {
            modules = [
              {
                nixpkgs.system = "aarch64-linux";
              }
            ];
          };
        in
          extended.activationPackage;

        "krad246@windex" = let
          extended = self.homeConfigurations."krad246@windex".extendModules {
            modules = [
              {
                nixpkgs.system = "aarch64-linux";
              }
            ];
          };
        in
          extended.activationPackage;

        "keerad@windex" = let
          extended = self.homeConfigurations."keerad@windex".extendModules {
            modules = [
              {
                nixpkgs.system = "aarch64-linux";
              }
            ];
          };
        in
          extended.activationPackage;
      };
    };
  };

  perSystem = {
    config,
    lib,
    pkgs,
    self',
    ...
  }: let
    # Core package list for the host
    targetPkgs = tpkgs:
      with tpkgs;
        [git delta]
        ++ [direnv nix-direnv lorri]
        ++ [just gnumake]
        ++ [shellcheck nil];
  in {
    devShells = {
      interactive = pkgs.mkShell {
        inputsFrom = [
          self'.devShells.nix-shell-env
          config.just-flake.outputs.devShell
        ];

        shellHook = ''
          (${lib.meta.getExe pkgs.lorri} daemon --extra-nix-options ${builtins.toJSON {}} 1>/dev/null 2>/dev/null) &
          eval "$(${lib.meta.getExe pkgs.lorri} -v direnv --flake $FLAKE_ROOT)"
        '';
      };

      nix-shell-env = pkgs.mkShell {
        packages = targetPkgs pkgs;

        inputsFrom = [
          config.flake-root.devShell
          config.treefmt.build.devShell
          config.pre-commit.devShell
        ];

        shellHook = ''
        '';
      };
    };

    packages =
      {
        devour-flake =
          pkgs.callPackage ./devour-flake.nix forwarded;
      }
      // (lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
        disko-install = pkgs.callPackage ./disko-install.nix forwarded;

        # linux has first class support for namespacing, the backend of docker
        # this means that we have a slightly simpler container interface available
        # with more capabilities on linux environments
        bwrapenv = pkgs.buildFHSEnvBubblewrap {
          name = "bwrapenv";
          runScript = "bash --rcfile <(echo ${lib.strings.escapeShellArg self'.devShells.nix-shell-env.shellHook})";
          nativeBuildInputs = let
            # 1. get all `{build,nativeBuild,...}Inputs` from the elements of `inputs`
            # 2. since that is a list of lists, `flatten` that into a regular list
            # 3. filter out of the result everything that's in `inputsFrom` itself
            # this leaves actual dependencies of the derivations in `inputsFrom`, but never the derivations themselves
            mergeInputs = inputs: name: (lib.subtractLists inputs (lib.flatten (lib.catAttrs name inputs)));
          in
            mergeInputs [self'.devShells.nix-shell-env] "nativeBuildInputs";

          extraInstallCommands = "";
          meta = {};
          passhtru = {};
          extraPreBwrapCmds = "";
          extraBwrapArgs = [];
          unshareUser = false;
          unshareIpc = false;
          unsharePid = false;
          unshareNet = false;
          unshareUts = false;
          unshareCgroup = false;
          privateTmp = true;
          dieWithParent = true;
        };
      });
  };
}
