{inputs, ...}: {
  perSystem = {
    self',
    lib,
    pkgs,
    ...
  }: {
    packages = {
      default = self'.packages."build/all";
      "build/all" = pkgs.writeShellApplication {
        name = "build-all";
        text = ''
          set -x
          ${lib.getExe pkgs.nix} flake lock --no-update-lock-file
          ${lib.getExe (pkgs.callPackage inputs.devour-flake {})} "$FLAKE_ROOT" "$@"
        '';
      };
    };
  };
}
