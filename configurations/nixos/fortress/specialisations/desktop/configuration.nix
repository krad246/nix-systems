{self, ...}: {
  imports =
    [self.modules.generic.unfree]
    ++ (with self.nixosModules; [
      flatpak
      nixos
      opengl
    ]);
}
