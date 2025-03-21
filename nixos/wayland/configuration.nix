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
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

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

  hardware = {
    # Vulkan
    opengl = {
      driSupport = true;  
      driSupport32Bit = true;
    };
    # razer driver
    openrazer = {
      enable = true;
    };
  };

  # Provision user
  users.users.kharf = {
    isNormalUser = true;
    description = "kharf";
    extraGroups = [ "networkmanager" "wheel" "audio" "openrazer" ];
  };
  users.defaultUserShell = pkgs.zsh;

  # Fonts
  fonts.packages = with pkgs; [
    unstable.nerdfonts
    font-awesome
  ];

  # Container
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
  };

  # Credentials
  services.gnome.gnome-keyring.enable = true;

  # automounting with udiskie frontend
  services.udisks2.enable = true;

  # llm
  services.ollama = {
    enable = true;
    package = pkgs.ollama;
    acceleration = "rocm";
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
     unstable.neofetch
     xclip
     unstable.zoxide
     # browser
     unstable.brave
     unstable.floorp
     # cloud cli
     unstable.kubectl
     unstable.kubectx
     unstable.k9s
     unstable.fluxcd
     unstable.kind
     local.declcd
     # development
     unstable.go_1_22
     gopls
     unstable.golangci-lint
     unstable.golangci-lint-langserver
     unstable.golines
     unstable.delve
     unstable.goreleaser
     local.cue
     local.dagger
     unstable.golangci-lint
     checkov
     unstable.terraform-ls
     unstable.terraform
     unstable.gnumake
     unstable.nil
     unstable.sops
     unstable.httpie
     unstable.hugo
     unstable.jdt-language-server
     # key remap (executed in zshrc)
     xorg.xmodmap
     # pictures
     feh
     flameshot
     # media
     alsa-utils
     vlc
     spotify
     discord
     # files and dirs
     xfce.thunar
     p7zip
     unstable.nnn
     udiskie
     unzip
     # privacy
     protonvpn-gui
     keepassxc
     _1password
     _1password-gui
     age
     step-cli
     # system
     bottom
     killall
     appimage-run
     tcpdump
     # games
     steam
     inputs.nix-gaming.packages.${pkgs.system}.star-citizen
     lutris
     gamemode
     (unstable.wineWowPackages.full.override {
       wineRelease = "staging";
       mingwSupport = true;
     })
     winetricks
     # peripherals
     polychromatic
  ];

  programs = {
    zsh = {
      enable = true;
      ohMyZsh.enable = true;
    };
    dconf.enable = true;
    ssh.askPassword = "";
    nm-applet.enable = true;
    hyprland.enable = true;
  };
}
