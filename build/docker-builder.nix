{
  perSystem = {
    self',
    lib,
    pkgs,
    ...
  }: {
    packages = lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
      "docker/devshell" = pkgs.dockerTools.buildNixShellImage {
        drv = self'.devShells.default;
      };
    };
  };
}
