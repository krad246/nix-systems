{self, ...}: {
  imports = with self.nixosModules; [
    aarch64-binfmt
    avahi
    bluetooth
    kdeconnect
    pipewire
    rdp
    sshd
    system76-scheduler
  ];

  programs.ssh = {
    startAgent = true;
  };
}
