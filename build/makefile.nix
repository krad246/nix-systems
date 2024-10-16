{
  perSystem = {
    self',
    pkgs,
    lib,
    ...
  }: {
    packages = {
      Makefile = self'.packages.makefile;

      # Generate a wrapper Makefile handling the container activations.
      makefile = let
        inherit (self'.packages) devshell;
        image = "${devshell.imageName}:${devshell.imageTag}";
      in
        pkgs.substituteAll rec {
          src = ./Makefile.in;
          inherit devshell image;

          # Generate a devcontainer.json with the 'image' parameter set to this flake's devshell.
          template = pkgs.substituteAll {
            src = ./devcontainer.json.in;
            inherit image;
          };

          loader = lib.getExe (pkgs.writeShellApplication {
            name = "loader";
            text = ''
              ${lib.getExe' pkgs.coreutils "ln"} -snvrf \
                 ${template} "$CACHEDIR/devcontainer.json"
            '';
          });
        };
    };
  };
}
