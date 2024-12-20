{
  # installing dependencies of quickemu-project
  homebrew = rec {
    brews = [
      "bash"
      "cdrtools"
      "coreutils"
      "jq"
      "python3"
      "qemu"
      "usbutils"
      "samba"
      "socat"
      "swtpm"
      "zsync"
    ];
  };

  # clone project via flake or other fetcher here...
}
