# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, lib, config, pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ./gtk.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
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
    file = {
      ".config/i3/config".source = ./i3/config;
      ".config/i3/i3-lock-screen-scaled.png".source = ./i3/i3-lock-screen-scaled.png;
      ".config/i3status-rust/config.toml".source = ./i3status-rust/config.toml;
      ".alacritty.yml".source = ./alacritty/alacritty.yaml;
      ".config/starship.toml".source = ./starship/starship.toml;
      ".zshrc".source = ./zsh/zshrc;
      ".config/helix/config.toml".source = ./helix/config.toml;
      ".config/helix/themes/oxocarbon.toml".source = ./helix/themes/oxocarbon.toml;
      ".config/k9s/skin.yml".source = ./k9s/skin.yaml;
      ".config/picom.conf".source = ./picom/picom.conf;
      ".xprofile".source = ./x/xprofile;
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
      };
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
