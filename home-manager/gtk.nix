{ pkgs, ... }: {
  gtk = {
    enable = true;
    font.name = "Iosevka Nerd Font";
    iconTheme = {
      package = pkgs.dracula-icon-theme;
      name = "Dracula";
    };
    theme = {
      name = "Dracula";
      package = pkgs.dracula-theme;
    };
  };
}
