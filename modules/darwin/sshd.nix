{
  # add nix to sshd path so nix store is pingable
  environment.etc."ssh/sshd_config.d/102-sshd-nix-env-on-path".text = ''
    SetEnv PATH=/nix/var/nix/profiles/default/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
  '';
}
