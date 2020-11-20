{ modulesPath, ... }: {
  imports = [
    # passwd is nixos by default
    ../users/nixos
    # passwd is empty by default
    ../users/root
    "${modulesPath}/installer/cd-dvd/iso-image.nix"
    ../profiles/core
  ];

  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  networking.networkmanager.enable = true;

  isoImage.contents = [ {
    source = ../secrets/id_niximg;
    target = "id_niximg";
  } ];
  programs.ssh.extraConfig = ''
    IdentityFile /iso/id_niximg
  '';
}
