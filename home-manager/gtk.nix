{ pkgs
, lib
, inputs
, config
, ...
}: {
  gtk = {
    enable = true;
    font.name = " Sauce Code Pro Nerd Font";
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
