{
  self,
  inputs,
  ...
}: {
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
          ${lib.getExe pkgs.nixFlakes} \
            --option experimental-features 'nix-command flakes' \
            flake lock --no-update-lock-file "${self}" \
          && ${lib.getExe (pkgs.callPackage inputs.devour-flake {})} "${self}" "$@"
        '';
      };
    };
  };
}
