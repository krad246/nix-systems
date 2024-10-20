_: {
  perSystem = {
    self',
    pkgs,
    ...
  }: {
    packages = {
      "docker/nix-shell" = pkgs.dockerTools.streamNixShellImage {
        drv = self'.devShells.default;
      };
    };
  };
}
