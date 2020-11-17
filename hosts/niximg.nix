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
}
