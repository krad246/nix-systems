# outer / 'flake' scope
{
  withSystem,
  self,
  inputs,
  lib,
  ...
}: {
  flake.overlays = {
    nix-wrapped = _final: prev:
      withSystem prev.stdenv.hostPlatform.system ({
        inputs',
        pkgs,
        ...
      }: {
        nixVersions.stable = let
          old = inputs'.nixpkgs.legacyPackages.nix;
          inherit (lib) attrsets cli strings;
        in
          pkgs.writeShellApplication {
            name = "nix-wrapped";
            runtimeInputs = [old];
            text = let
              args = cli.toGNUCommandLineShell {} {
                option = attrsets.mapAttrsToList (name: value: strings.concatStringsSep " " [name value]) {
                  experimental-features = ''"nix-command flakes"'';
                  builders-use-substitutes = "true";
                  preallocate-contents = "true";
                  accept-flake-config = "true";
                  inputs-from = self;
                  keep-going = "true";
                  show-trace = "true";
                };
              };
            in ''
              nix ${args} "$@"
            '';
          };
      });
  };

  perSystem = {
    pkgs,
    system,
    ...
  }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [];
      config = {allowUnfree = true;};
    };
  };
}
