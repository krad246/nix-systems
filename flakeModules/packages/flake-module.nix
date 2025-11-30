{
  inputs,
  self,
  lib,
  ...
}: let
  # Sets up container image packages, custom devShell derivation within the container
  # VSCode *is* supported!
  containers = ./containers;
  nixos-generators = ./nixos-generators;
  disko-config = ./disko;
in {
  imports = [
    containers
    disko-config
    nixos-generators
  ];

  # export the flake modules we loaded to this context for user consumption
  flake = rec {
    flakeModules = {
      inherit containers;
      inherit disko-config;
      inherit nixos-generators;
    };

    modules.flake = flakeModules;
  };

  perSystem = {
    inputs',
    self',
    pkgs,
    ...
  }: let
    nixArgs = let
      inherit (lib) cli;
    in
      cli.toGNUCommandLine {} {
        option = [
          "experimental-features 'nix-command flakes'"
          "keep-going true"
          "show-trace true"
          "accept-flake-config true"
          "builders-use-substitutes true"
          "preallocate-contents true"
          "allow-import-from-derivation true"
        ];
        # verbose = true;
        # print-build-logs = true;
      };
    addFlags = x: "--add-flags ${lib.strings.escapeShellArg x}";
    wrapArgs = lib.strings.concatMapStringsSep " " addFlags nixArgs;
  in {
    packages =
      {
        devour-flake = pkgs.writeShellApplication {
          name = "devour-flake";

          text = ''
            set -x
            ${lib.meta.getExe (pkgs.callPackage inputs.devour-flake {})} "${self}" "$@"
          '';
        };

        home-manager = pkgs.symlinkJoin {
          name = "home-manager";
          paths = [inputs'.home-manager.packages.home-manager];
          buildInputs = [pkgs.makeWrapper];
          postBuild = ''
            wrapProgram $out/bin/home-manager ${wrapArgs} --add-flags '-b ${self.rev or self.dirtyRev or "bak"}'
          '';
        };

        nix = pkgs.symlinkJoin {
          name = "nix";
          paths = [pkgs.nixVersions.stable];
          buildInputs = [pkgs.makeWrapper];
          postBuild = ''
            wrapProgram $out/bin/nix ${wrapArgs}
          '';
        };

        term-fonts = pkgs.callPackage ./term-fonts.nix {};

        zen-profile-manifest = pkgs.callPackage ./zen-profile-manifest.nix {};
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

        disko-install = pkgs.callPackage ./disko-install.nix {inherit self;};

        # linux has first class support for namespacing, the backend of docker
        # this means that we have a slightly simpler container interface available
        # with more capabilities on linux environments
        bubblewrap = pkgs.buildFHSEnvBubblewrap {
          name = "bubblewrap";
          runScript = "bash --rcfile <(echo ${lib.strings.escapeShellArg self'.devShells.default.shellHook})";
          nativeBuildInputs = let
            # 1. get all `{build,nativeBuild,...}Inputs` from the elements of `inputs`
            # 2. since that is a list of lists, `flatten` that into a regular list
            # 3. filter out of the result everything that's in `inputsFrom` itself
            # this leaves actual dependencies of the derivations in `inputsFrom`, but never the derivations themselves
            mergeInputs = inputs: name: (lib.subtractLists inputs (lib.flatten (lib.catAttrs name inputs)));
          in
            mergeInputs [self'.devShells.default] "nativeBuildInputs";

          extraInstallCommands = "";
          meta = {};
          passhtru = {};
          extraPreBwrapCmds = "";
          extraBwrapArgs = [];
          unshareUser = true; # all users are remapped into a new UID space
          unshareIpc = true; # no need for message queues, etc.
          unsharePid = true; # enter a new PID namespace
          unshareNet = false;
          unshareUts = true;
          unshareCgroup = true;
          privateTmp = true;
          dieWithParent = true;
        };

        nixos-rebuild = pkgs.symlinkJoin {
          name = "nixos-rebuild";
          paths = [pkgs.nixos-rebuild];
          buildInputs = [pkgs.makeWrapper];
          postBuild = ''
            wrapProgram $out/bin/nixos-rebuild ${wrapArgs} --add-flags '--use-remote-sudo'
          '';
        };
      })
      // (lib.attrsets.optionalAttrs pkgs.stdenv.isDarwin {
        darwin-rebuild = pkgs.symlinkJoin {
          name = "darwin-rebuild";
          paths = [inputs'.darwin.packages.darwin-rebuild];
          buildInputs = [pkgs.makeWrapper];
          postBuild = ''
            wrapProgram $out/bin/darwin-rebuild ${wrapArgs}
          '';
        };
      });
  };
}
