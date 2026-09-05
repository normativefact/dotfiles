{ pkgs, ... }:
{
  services.ssh-agent = {
    enable = true;
};

programs.ssh = {
  enable = true;
  enableDefaultConfig = false;

  settings = {
    "*" = {
      addKeysToAgent = "yes";
      identityFile = "~/.ssh/id_ed25519";
    };
  };
};

}

