{pkgs, ...}: let
  inherit (pkgs) lib;
in {
  packages =
    (lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
      disko-install = import ./disko-install.nix {inherit pkgs;};
    })
    // (let
      targetPkgs = tpkgs:
        with tpkgs;
          [git]
          ++ [direnv nix-direnv]
          ++ [just gnumake]
          ++ [shellcheck nil];

      profile = ''
        if [[ -f /.dockerenv ]]; then
          # nix-build doesn't play very nice with the sticky bit
          # and /tmp in a docker environment. unsetting it enables
          # the container to manage its tmpfs as it pleases.
          unset TEMP TMPDIR NIX_BUILD_TOP
        else
          :
        fi
      '';
    in
      (lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
        devshell-bwrapenv = pkgs.buildFHSEnvBubblewrap {
          name = "devshell-bwrapenv";
          inherit targetPkgs profile;
        };
      })
      // {
        devshell-chrootenv = pkgs.buildFHSEnvChroot {
          name = "devshell-chrootenv";
          inherit targetPkgs profile;
        };
      });
}
