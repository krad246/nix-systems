{inputs, ...}: {
  perSystem = {
    lib,
    pkgs,
    ...
  }: {
    packages = {
      "build/all" = pkgs.writeShellApplication {
        name = "build-all";
        text = ''
          set -x
          ${lib.getExe pkgs.nixFlakes} \
            --option experimental-features 'nix-command flakes' \
            flake lock --no-update-lock-file "$FLAKE_ROOT" \
          && ${lib.getExe (pkgs.callPackage inputs.devour-flake {})} "$FLAKE_ROOT" "$@"
        '';
      };
    };
  };

  flake.packages.aarch64-darwin.default = let
    pkgs = import inputs.nixpkgs {system = "aarch64-darwin";};
    inherit (pkgs) lib;
  in
    pkgs.writeShellApplication {
      name = "default";
      text = ''
        set -x
        ${lib.getExe pkgs.nixFlakes} \
          --option experimental-features 'nix-command flakes' \
          flake lock --no-update-lock-file "$FLAKE_ROOT" \
        && ${lib.getExe (pkgs.callPackage inputs.devour-flake {})} "$FLAKE_ROOT" \
          --override-input systems github:nix-systems/default-linux "$@"
      '';
    };
}
