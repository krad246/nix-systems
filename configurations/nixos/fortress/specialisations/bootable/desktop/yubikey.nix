{
  security.pam.yubico = {
    enable = true;
    debug = true;
    mode = "challenge-response";
    id = ["27472474"];
    control = "required";
  };

  services.pcscd.enable = true;

  security.pam = {
    u2f.enable = true;
  };
}
