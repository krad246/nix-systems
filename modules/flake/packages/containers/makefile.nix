{
  host,
  devcontainer-image,
  devcontainer-json,
  devcontainer-loader,
  ...
}:
host.pkgs.substituteAll rec {
  src = ./Makefile.in;

  image = devcontainer-image;
  loader = devcontainer-loader;
  json = devcontainer-json;

  devcontainer = host.pkgs.lib.meta.getExe host.pkgs.devcontainer;
  docker = host.pkgs.lib.meta.getExe host.pkgs.docker;
}
