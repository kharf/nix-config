{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ../hardware-configuration.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    # This will additionally add inputs to the system's legacy channels
    # Making legacy nix commands consistent as well
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };
  };

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Bootloader.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
      configurationLimit = 10;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken.
  system.stateVersion = "23.11";

  # Enable networking
  networking.networkmanager.enable = true;

  networking.firewall.enable = true;
  networking.firewall.trustedInterfaces = ["virbr0"];
  networking.hostName = "kharf";
  networking.firewall.interfaces."podman+".allowedUDPPorts = [ 53 ];
  # in k8s pod to pod communication is expected to go through iptables
  boot.kernel.sysctl = {
    "net.bridge.bridge-nf-call-iptables" = 1;
    "net.ipv4.ip_forward" = 1;
    "net.bridge.bridge-nf-call-ip6tables" = 1;
  };

  # Time zone.
  time.timeZone = "Europe/Berlin";

  # Internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "us";

  # Tweaks
  boot.kernel.sysctl = {
    "vm.max_map_count" = 16777216;
    "fs.file-max" = 524288;
  };

  # lact
  services.lact.enable = true;
  hardware.amdgpu.overdrive.enable = true;

  # rootless podman
  # disable cgroup v1
  # disable PP_OVERDRIVE_MASK, PP_GFXOFF_MASK, and PP_STUTTER_MODE to avoid complete system freezes
  boot.kernelParams = [
    "cgroup_no_v1=all"
    "systemd.unified_cgroup_hierarchy=1"
    "amdgpu.ppfeaturemask=0xfffd3fff"
  ];
  # bpf programs need higher memlock
  security.pam.loginLimits = [
    {
      domain = "*";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
    {
      domain = "*";
      item = "nofile";
      type = "-";
      value = "1048576";
    }
  ];

  # Swap
  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };

  # Sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Input
  services.libinput = {
    mouse = {
      accelProfile = "flat";
      accelSpeed = "0";
      middleEmulation = false;
    };
  };

  services.udev = {
    packages = with pkgs; [
      qmk
      qmk-udev-rules
      qmk_hid
      via
      unstable.vial
      rivalcfg
    ];
  };

  # DM
  services.displayManager = {
    defaultSession = "niri";
    gdm.enable = true;
  };

  services.xserver = {
    enable = true;

    desktopManager = {
      xterm.enable = false;
    };
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  # Provision user
  users = {
    defaultUserShell = pkgs.zsh;
    users.kharf = {
        isNormalUser = true;
        description = "kharf";
        extraGroups = [
          "networkmanager"
          "wheel"
          "audio"
          "libvirtd"
          "podman"
          "openrazer"
        ];
      };
    groups.libvirtd.members = ["kharf"];
  };

  # Fonts
  fonts.packages = with pkgs; [
    unstable.nerd-fonts.iosevka
    unstable.nerd-fonts.iosevka-term
    font-awesome
  ];

  # Container
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
    libvirtd = {
      enable = true;
    };
    spiceUSBRedirection.enable = true;
  };

  security.sudo.extraRules = [
    {
      users = [ "kharf" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/podman";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Credentials
  services.gnome.gnome-keyring.enable = true;

  # automounting with udiskie frontend
  services.udisks2.enable = true;

  # signing
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-curses;
    settings = {
      default-cache-ttl-ssh = 60 * 60 * 12;
      max-cache-ttl-ssh = 60 * 60 * 12;
    };
  };

  # Printing
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Fuse filesystem that returns symlinks to executables based on the PATH of the requesting process.
  # This is useful to execute shebangs on NixOS that assume hard coded locations in locations like /bin or /usr/bin etc
  services.envfs.enable = true;

  hardware.openrazer.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    prod-shell
    dev-shell
    unstable.alacritty
    unstable.starship
    unstable.helix
    unstable.fastfetch
    unstable.zoxide
    bc
    unstable.presenterm
    cosign
    unstable.brave
    inputs.waterfox.packages.${pkgs.stdenv.hostPlatform.system}.waterfox-bin
    unstable.kubectl
    unstable.kubectx
    unstable.kubent
    unstable.k9s
    unstable.fluxcd
    unstable.kubernetes-helm
    unstable.kind
    local.navecd
    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])
    unstable.terraform-ls
    unstable.tenv
    unstable.docker-compose
    unstable.go
    unstable.gopls
    unstable.golangci-lint
    unstable.delve
    unstable.goreleaser
    unstable.zvm
    unstable.cue
    local.dagger
    unstable.gnumake
    unstable.nil
    unstable.sops
    unstable.httpie
    unstable.hey
    unstable.marksman
    unstable.crane
    unstable.openssl
    unstable.dig
    unstable.traceroute
    unstable.openssh
    unstable.gh-dash
    unstable.gh
    unstable.yq
    unstable.jq
    unstable.jujutsu
    unstable.addlicense
    gpu-screen-recorder-gtk
    alsa-utils
    vlc
    spotify
    discord
    p7zip
    udiskie
    dua
    unzip
    libreoffice
    unstable.proton-vpn-cli
    unstable.proton-vpn
    keepassxc
    unstable.proton-pass
    unstable.btop-rocm
    killall
    appimage-run
    tcpdump
    pciutils
    wineWow64Packages.staging
    winetricks
    protontricks
    mangohud
    lutris
    unstable.umu-launcher
    local.bellum
    local.bar
    unstable.vial
    usbutils
    dnsmasq
    difftastic
    dyff
    fuzzel
    mako
    swaybg
    swaylock
    xwayland-satellite
    wl-clipboard
    gamescope
    openrazer-daemon
    polychromatic
    unstable.opencode
    unstable.glow
    unstable.gotestsum
    unstable.bun
    unstable.kdePackages.okular
    unstable.kyverno
    unstable.nautilus
  ];

  programs = {
    zsh = {
      enable = true;
      ohMyZsh.enable = true;
    };
    dconf.enable = true;
    ssh = {
      startAgent = false;
      askPassword = "";
    };
    nm-applet.enable = true;
    steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        unstable.proton-ge-bin
      ];
    };
    gamemode.enable = true;
    gpu-screen-recorder = {
      enable = true;
    };
    niri = with pkgs; {
      enable = true;
      package = unstable.niri;
    };
    waybar.enable = true;
    obs-studio = {
      enable = true;
      enableVirtualCamera = true; 
    };
    bazecor = with pkgs; {
      enable = true;
      package = unstable.bazecor;
    };
  };
}
