{
  self,
  lib,
  ...
}: {
  imports =
    [
      ./aarch64-binfmt.nix
      ./default-users.nix
      ./environment.nix
      ./hm-compat.nix
      ./kernel.nix
      ./nerdfonts.nix
      ./nix-ld.nix
      ./packages.nix
    ]
    ++ (with self.nixosModules; [
      agenix
      ccache-stdenv
      zram
    ])
    ++ (with self.modules.generic; [
      system-link-registry
      flake-registry
      lorri
      nix-core
      unfree
    ]);

  environment.variables = {
    NIX_REMOTE = "daemon";
    NIX_SSHOPTS = "-o SetEnv=PATH=${lib.strings.makeBinPath ["/run/current-system/sw" "/nix/var/nix/profiles/default"]}";
  };
}
