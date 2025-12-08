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
      ".config/niri/config.kdl".source = ./niri/config.kdl;
      ".config/fuzzel/fuzzel.ini".source = ./fuzzel/fuzzel.ini;
      ".config/btop/themes/oxocarbon_dark.theme".source = ./btop/oxocarbon_dark.theme;
      ".config/waybar/config".source = ./waybar/config;
      ".config/waybar/style.css".source = ./waybar/style.css;
      ".config/mako/config".source = ./mako/config;
      ".alacritty.toml".source = ./alacritty/alacritty.toml;
      ".config/ghostty/config".source = ./ghostty/config;
      ".config/starship.toml".source = ./starship/starship.toml;
      ".zshrc".source = ./zsh/zshrc;
      ".config/helix/config.toml".source = ./helix/config.toml;
      ".config/helix/languages.toml".source = ./helix/languages.toml;
      ".config/helix/themes/oxocarbon.toml".source = ./helix/themes/oxocarbon.toml;
      ".config/k9s/skins/oxocarbon.yaml".source = ./k9s/skins/oxocarbon.yaml;
      ".config/k9s/config.yaml".source = ./k9s/config.yaml;
      ".config/jj/config.toml".source = ./jj/config.toml;
      ".config/opencode/opencode.json".source = ./opencode/opencode.json;
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
      settings = {
        user = {
          name = "Kevin Fritz";
          email = "kevinfritz210@gmail.com";
        };
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
