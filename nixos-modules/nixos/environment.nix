{
  lib,
  pkgs,
  ...
}: {
  system = {
    # Include the usual suspects for cache warming (we'll be installing stuff dependent on it).
    extraDependencies = with pkgs; [stdenv stdenvNoCC busybox toybox];
    stateVersion = lib.trivial.release;
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
  };
}
