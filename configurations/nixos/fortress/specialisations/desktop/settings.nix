{self, ...}: {
  imports = with self.nixosModules; [
    avahi
    bluetooth
    efiboot
    kdeconnect
    pipewire
    rdp
    sshd
  ];

  programs.ssh = {
    startAgent = true;
  };
}
