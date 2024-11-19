{
  pkgs,
  targetPkgs ? (_tpkgs: []),
  nativeBuildInputs ? [],
  ...
}: let
  # construct a simple rootfs derivation with the packages
  paths = targetPkgs pkgs;
  fs = pkgs.buildEnv {
    name = "nix-shell";
    inherit paths;
  };
in
  # add a shellHook field to make it understandable by nix-shell
  # pull in all the other dependencies from inputsFrom above
  fs.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ nativeBuildInputs ++ paths;
    shellHook = ''
      if [[ -f /.dockerenv ]]; then
        # nix-build doesn't play very nice with the sticky bit
        # and /tmp in a docker environment. unsetting it enables
        # the container to manage its tmpfs as it pleases.
        unset TEMP TMPDIR NIX_BUILD_TOP
      else
        :
      fi
    '';
  })
