{lib, ...}: {
  # Keep the stock users laying around.
  users = {
    users.nixos = {
      initialHashedPassword = lib.mkDefault "$y$j9T$wGrPZQfqKmoKMYKh.DV2b.$I2/4NrxfRvS1d.M8QbPG.c8raX/jD8xBy.nOpQK./hA";
      isNormalUser = true;
    };

    users.root = {
      initialHashedPassword = lib.mkDefault "$y$j9T$2CXtKDXh5W.N9aCUikvlM/$OmcgpG/XxMUK0KUx5Hh8/3CLUcSg3OFAK02fJQiw0a7";
      isSystemUser = true;
    };
  };

  security.sudo.wheelNeedsPassword = false;

  nix.settings = rec {
    allowed-users = ["nixos" "root" "@wheel"];
    trusted-users = allowed-users;
  };
}
