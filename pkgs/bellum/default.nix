{
  lib,
  makeDesktopItem,
  symlinkJoin,
  writeShellScriptBin,
  gamemode,
  proton-ge-bin,
  pname ? "bellum",
  location ? "$HOME/Games/bellum",
  pkgs,
}: let

  src = pkgs.fetchurl {
    url = "https://astarte.launcher.link/download";
    name = "AstarteLauncher-amd64-installer.exe";
    hash = "sha256-Hym4qVJJz8KPXedkkcHDxtvCcfRVasruId+SoBdnWxU=";
  };

  script = writeShellScriptBin pname ''
      export WINEPREFIX="${location}"
      export GAMEID=umu-bellum
      export PROTONPATH="${proton-ge-bin.steamcompattool}/"
      if [ ! -d "${location}" ]; then
        # install launcher
        umu-run ${src}
      else
        GAME="${location}/drive_c/users/kharf/AppData/Local/Astarte Industries/Astarte Launcher/AstarteLauncher.exe"
        MANGOHUD=1 MANGOHUD_CONFIG=fps_only=1,background_alpha=0 ${gamemode}/bin/gamemoderun umu-run "$GAME"
      fi
 '';

  desktopItems = makeDesktopItem {
    name = pname;
    exec = "${script}/bin/${pname} %U";
    comment = "Bellum";
    desktopName = "Bellum";
    categories = ["Game"];
    mimeTypes = ["application/x-bellum"];
  };
in
  symlinkJoin {
    name = pname;
    paths = [
      desktopItems
      script
    ];

    meta = {
      description = "Bellum";
      homepage = "";
      license = lib.licenses.unfree;
      maintainers = with lib.maintainers; [kharf];
      platforms = ["x86_64-linux"];
    };
  }
