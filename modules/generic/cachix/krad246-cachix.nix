{
  nix = {
    settings = {
      # Prefer to pull as many outputs from binary caches as possible.
      builders-use-substitutes = true;
      substituters = [
        "https://krad246.cachix.org"
      ];

      trusted-substituters = [
        "https://krad246.cachix.org"
      ];
      trusted-public-keys = [
        "krad246.cachix.org-1:N57J9SfNFtxMSYnlULH4l7ZkdNjIQb0ByyapaEb/8IM="
      ];
    };
  };
}
