forwarded @ {inputs, ...}: let
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
  };

  perSystem = {
    lib,
    pkgs,
    self',
    ...
  }: {
    packages =
      {
        devour-flake =
          pkgs.callPackage ./devour-flake.nix forwarded;
        zen-snapshot = pkgs.callPackage ./zen-snapshot.nix forwarded;
      }
      // (lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
        dconf2nix = pkgs.callPackage inputs.dconf2nix rec {
          compiler = import (inputs.dconf2nix + "/nix/ghc-version.nix");
          packages = {
            inherit pkgs;
            hp = pkgs.haskell.packages.${compiler}.override {
              overrides = _newPkgs: _oldPkgs: {};
            };
          };
        };

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
