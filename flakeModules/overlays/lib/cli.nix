_final: prev: {
  toGNUCommandLineShell = bin: args:
    prev.strings.concatStringsSep " " ([bin] ++ prev.cli.toGNUCommandLine {} args);
}
