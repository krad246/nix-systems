{
  host,
  devcontainer-tag,
  devcontainer-json,
  devcontainer-loader,
  ...
}:
host.pkgs.substituteAll rec {
  src = ./Makefile.in;

  tag = devcontainer-tag;
  loader = devcontainer-loader;
  json = devcontainer-json;

  devcontainer = host.pkgs.lib.meta.getExe host.pkgs.devcontainer;
  docker = host.pkgs.lib.meta.getExe host.pkgs.docker;
}
