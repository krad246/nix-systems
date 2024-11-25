{self, ...}: {
  imports = with self.homeModules; [
    chromium
    dconf
    kitty
  ];
}
