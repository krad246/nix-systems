let
  dullahan = {
    krad246 = {
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ7h4nTs4FtTsJIsx1RKVF6Apm8/mFLFJC1bUTVcxp+r condor-janitor0e@icloud.com";
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCwHS8BXca5luXc2N0ienu88tFpj/PvPxnCYr7+dDBY/oTzwAnPBu5ptm2L+5LQFyR2rkRwYty8EAh/v7ugM7lWVVi3NNzLzu+9/7xGhnfrKXPo0/kMpNHoVKnojZEDbqOahOqHq+UOgREypIOXZMEcxh2QRLHCwo85WlS5Y8ZditxL43uvgBryKBModbqoNLVZTX9ZTcr9x+tSlAiYVEyR06k4TWOE48dgi7L/sM0M5W21XBpMJdoJmwKI1SNQSvkCfEengN0iqgbt8mTOXqzq1KjE4y55xge0hOyMdntW37C7x3X/9qRW+JhLGp3hA4xLEWQo+vKtUNu43YeQiOQEKd5LADP/+5Kv6nCfpVbvyUwJ6Ed/VMHNg3WjIru6eid0vv4FKUPgrGQtKdiU5mreY2T6D24hprwS9NEhZCBgJJbgZQ2Cfw1iLuRyOFJ9nWxJ1AZUd0k+tg+zIK07FhKEFbwZZqonyGoKlZuiVbtD6H3wACGlqIwkLCfFA5U/OFZ6LTIxyzGQybRdXeSJ9N0joMepsUlY4qFtwPc+1gpqssyihwc8Lhr1gLj0y0cuVRXhAkKVjCST27D0USI9Wa2DGcd26iuFWKoJG9At9ssp/Hp0VR4jPuPCPnAI8uMRcMa9kzmqruvMCnCEyUdZWQcOfrBXCVFBaqYs2AwEgdxMAw== condor-janitor0e@icloud.com";
    };

    system = {
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJXafRdLT+qPTMUzzMc35PxOP4zun6zIPTf98jQ6Bv5P";
    };
  };

  inherit (dullahan) krad246 system;
in {
  "id_ed25519_priv.age".publicKeys = [krad246.ed25519 krad246.rsa system.ed25519];
}
