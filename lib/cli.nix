{lib}: {
  toGNUCommandLineShell = bin: args:
    lib.strings.concatStringsSep " " ([bin] ++ lib.cli.toGNUCommandLine {} args);
}
