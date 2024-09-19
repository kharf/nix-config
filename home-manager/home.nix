# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [
    ./gtk.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

  home = {
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "23.05";
    username = "kharf";
    homeDirectory = "/home/kharf";
    pointerCursor = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };
    file = {
      ".config/i3/config".source = ./i3/config;
      ".config/i3/i3-lock-screen-scaled.png".source = ./i3/i3-lock-screen-scaled.png;
      ".config/i3status-rust/config.toml".source = ./i3status-rust/config.toml;
      ".alacritty.toml".source = ./alacritty/alacritty.toml;
      ".config/starship.toml".source = ./starship/starship.toml;
      ".zshrc".source = ./zsh/zshrc;
      ".config/helix/config.toml".source = ./helix/config.toml;
      ".config/helix/languages.toml".source = ./helix/languages.toml;
      ".config/helix/themes/oxocarbon.toml".source = ./helix/themes/oxocarbon.toml;
      ".config/k9s/skins/oxocarbon.yaml".source = ./k9s/skins/oxocarbon.yaml;
      ".config/k9s/config.yaml".source = ./k9s/config.yaml;
      ".background-image".source = ./wallpaper/nixos-wallpaper.png;
    };
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  # Enable home-manager and git
  programs = {
    home-manager = {
      enable = true;
    };

    git = {
      enable = true;
      userName = "kharf";
      userEmail = "kevinfritz210@gmail.com";
      extraConfig = {
        url = {
          "ssh://git@github.com/mediamarktsaturn" = {
            insteadOf = "https://github.com/mediamarktsaturn";
         };
        };
        commit.gpgsign = true;
      };
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
