{ inputs, lib, config, pkgs, ... }: {
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
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. 
  system.stateVersion = "23.11"; 

  # Enable networking
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  networking.hostName = "kharf";
  networking.nameservers = [ "8.8.8.8" "8.8.8.4" ];
  networking.firewall.interfaces."podman+".allowedUDPPorts = [ 53 ];
  # in k8s pod to pod communication is expected to go through iptables
  boot.kernel.sysctl = {
    "net.bridge.bridge-nf-call-iptables"  = 1;
    "net.ipv4.ip_forward"                 = 1;
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

  # rootless podman
  # disable cgroup v1
  boot.kernelParams = [ "cgroup_no_v1=all" "systemd.unified_cgroup_hierarchy=1" ];
  # bpf programs need higher memlock
  security.pam.loginLimits = [
    { domain = "*"; item = "memlock"; type = "-"; value = "unlimited"; }
    { domain = "*"; item = "nofile"; type = "-"; value = "1048576"; }
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

  # DM
  services.displayManager = {
    defaultSession = "none+i3";
  };
  

  # X
  services.xserver = {
    enable = true;
    # Keyboard layout
    xkb = {
      layout = "us";
      variant = "";
    };
    autoRepeatDelay = 300;
    autoRepeatInterval = 30;

    displayManager = {
      lightdm.enable = true;
    };

    desktopManager = {
      xterm.enable = false;
    };

    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      extraPackages = with pkgs; [
        i3lock
        rofi
        i3status-rust
      ];
    };
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  # Provision user
  users.users.kharf = {
    isNormalUser = true;
    description = "kharf";
    extraGroups = [ "networkmanager" "wheel" "audio" ];
  };
  users.defaultUserShell = pkgs.zsh;

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
  };
  security.sudo.extraRules = [
  {
    users = [ "kharf" ];
    commands = [
      {
       command = "/run/current-system/sw/bin/podman";
       options= [ "NOPASSWD" ];
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
  };

  # Printing
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     # environments
     prod-shell
     dev-shell
     # terminal
     unstable.alacritty
     unstable.starship
     unstable.helix
     unstable.fastfetch
     xclip
     unstable.zoxide
     # browser
     brave
     # cloud cli
     unstable.kubectl
     unstable.kubectx
     unstable.kubent
     unstable.k9s
     unstable.fluxcd
     unstable.kubernetes-helm
     unstable.kind
     unstable.cilium-cli
     unstable.minikube
     local.navecd
     unstable.trivy
     unstable.kube-bench
     unstable.cmctl
     (unstable.google-cloud-sdk.withExtraComponents [unstable.google-cloud-sdk.components.gke-gcloud-auth-plugin])
     unstable.terraform-ls
     unstable.tenv
     # development
     unstable.go_1_23
     unstable.gopls
     unstable.golangci-lint
     unstable.golangci-lint-langserver
     unstable.golines
     unstable.delve
     unstable.goreleaser
     local.cue
     local.dagger
     checkov
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
     unstable.helix-gpt
     unstable.yq
     # key remap (executed in zshrc)
     xorg.xmodmap
     # pictures / videos
     feh
     flameshot
     obs-studio
     # media
     alsa-utils
     vlc
     spotify
     discord
     vesktop
     unstable.teamspeak_client
     # files and dirs
     xfce.thunar
     p7zip
     unstable.nnn
     udiskie
     dua
     unzip
     libreoffice
     # privacy
     protonvpn-gui
     keepassxc
     _1password-cli
     _1password-gui
     age
     step-cli
     # system
     unstable.btop
     killall
     appimage-run
     tcpdump
     pciutils
     # games
     wineWowPackages.staging
     winetricks
     protontricks
     gamemode
     local.aoc
     mangohud
     unstable.lutris
     # peripherals
  ];

  programs = {
    zsh = {
      enable = true;
      ohMyZsh.enable = true;
    };
    dconf.enable = true;
    ssh.askPassword = "";
    nm-applet.enable = true;
    steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
  };
}
