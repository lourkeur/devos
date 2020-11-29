{ modulesPath, ... }: {
  imports = [
    ../users/louis
    "${modulesPath}/installer/cd-dvd/iso-image.nix"
  ];

  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  networking.networkmanager.enable = true;

  services.mingetty.autologinUser = "louis";

  isoImage.contents = [ {
    source = ../secrets/id_niximg;
    target = "id_niximg";
  } ];
  programs.ssh.extraConfig = ''
    IdentityFile /iso/id_niximg
  '';
}
