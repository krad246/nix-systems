{
  security.pam = {
    u2f = {
      cue = true;
      control = "required";
    };
    services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
    };
  };
}
