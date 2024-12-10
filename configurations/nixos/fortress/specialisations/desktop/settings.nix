{self, ...}: {
  imports = with self.nixosModules; [
    avahi
    bluetooth
    kdeconnect
    pipewire
    rdp
    sshd
  ];

  programs.ssh = {
    startAgent = true;
  };
}
