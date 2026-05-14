{self, ...}: {
  flake.modules.nixos.builder.imports = with self.modules.nixos; [
    binfmt
    ccache
  ];
}
