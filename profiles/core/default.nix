{ config, lib, pkgs, ... }:
let inherit (lib) fileContents;

in
{
  boot.cleanTmpDir = true;

  nix.package = pkgs.nixFlakes;

  nix.systemFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];

  imports = [ ../../local/locale.nix ];

  services.xserver.layout = "custom_xbows";
  console.useXkbConfig = true;

  environment = {

    variables = {
      CDPATH = ["." "~"];
      LESS = "-eRSX";  # e causes less to automatically exit when it reaches end-of-file.
                       # R causes less to let color sequences through.
                       # S causes less not to wrap long lines.
                       # X causes less not to clear the screen.
      LESSOPEN = "|${pkgs.lesspipe}/bin/lesspipe.sh %s";
      PAGER = "less";
    };

    systemPackages = with pkgs; [
      binutils
      coreutils
      curl
      direnv
      dnsutils
      dosfstools
      fd
      file
      git
      gitAndTools.git-subrepo
      gitAndTools.git-crypt
      gptfdisk
      htop
      iputils
      jq
      less
      libarchive
      moreutils
      nix-direnv  # need to enable in ~/.direnvrc
      nmap
      pass-otp
      ripgrep
      utillinux
      whois
    ];

    shellAliases =
      let ifSudo = lib.mkIf config.security.sudo.enable;
      in
      {
        # quick cd
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";

        # bsdtar (multi-format archive)
        tar = "bsdtar";

        e = "$EDITOR";

        l = pkgs.writers.writeC "l" {} ./l.c;

        # git
        g = "git";

        # grep
        grep = "rg";
        gi = "grep -i";

        # internet ip
        myip = "dig +short myip.opendns.com @208.67.222.222 2>&1";

        # nix
        n = "nix";
        np = "n profile";
        ni = "np install";
        nr = "np remove";
        ns = "n search --no-update-lock-file";
        nf = "n flake";
        srch = "ns nixpkgs";
        nrb = ifSudo "sudo nixos-rebuild";

        # sudo
        s = ifSudo (pkgs.writers.writeC "s" {} ./s.c);
        se = ifSudo "sudoedit";

        # top
        top = "htop";

        # systemd
        ctl = "systemctl";
        stl = ifSudo "s systemctl";
        utl = "systemctl --user";
        ut = "systemctl --user start";
        un = "systemctl --user stop";
        up = ifSudo "s systemctl start";
        dn = ifSudo "s systemctl stop";
        jtl = "journalctl";
      };
  };

  fonts = {
    fonts = with pkgs; [ source-code-pro libertinus ];

    fontconfig.defaultFonts = {
      monospace = lib.mkBefore [ "Source Code Pro" ];
      sansSerif = lib.mkBefore [ "Libertinus Sans" ];
      serif = lib.mkBefore [ "Libertinus Serif" ];
    };

    # lowercase numerals
    fontconfig.localConf = ''
    <match target="font">
      <edit name="fontfeatures" mode="append">
        <string>onum on</string>
      </edit>
    </match>
    '';
  };

  hardware.nitrokey.enable = true;

  nix = {

    useSandbox = true;

    allowedUsers = [ "nix-ssh" "@wheel" ];

    trustedUsers = [ "root" "@wheel" ];

    extraOptions = ''
      experimental-features = nix-command flakes ca-references
      min-free = ${toString (5  * 1024 * 1024 * 1024)}
      max-free = ${toString (10 * 1024 * 1024 * 1024)}
      builders-use-substitutes = true
    '';

    binaryCaches = lib.mkAfter (lib.optional (config.networking.hostName != "hadron" && !config.special.roaming) "ssh-ng://nix-ssh@hadron");
  };

  programs.autojump.enable = true;

  programs.fish = {
    enable = true;
    promptInit = builtins.readFile ./prompt_init.fish;
  };

  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.enableSSHSupport = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  security = {

    hideProcessInformation = true;

    protectKernelImage = true;

    pam.enableSSHAgentAuth = true;

  };

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 1w";
  nix.gc.dates = "Sat 03:15";
  systemd.timers.nix-gc.timerConfig.Persistent = true;

  services.earlyoom.enable = true;

  services.openssh = {
    enable = true;
    startWhenNeeded = true;

    # hardening
    permitRootLogin = "prohibit-password";
    challengeResponseAuthentication = false;
    passwordAuthentication = false;
  };

  users.mutableUsers = false;
}
