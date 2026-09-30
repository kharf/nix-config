{
  lib,
  makeDesktopItem,
  symlinkJoin,
  writeShellScriptBin,
  proton-ge-bin,
  pname ? "battlenet",
  location ? "$HOME/Games/battlenet",
  pkgs,
}: let

  src = pkgs.fetchurl {
    url = "https://downloader.battle.net//download/getInstallerForGame?os=win&gameProgram=BATTLENET_APP&version=Live";
    name = "Battle.net-Setup.exe";
    hash = "sha256-3l0y1Ope7VqeEgAn+2izcJdtv+zI8qj5EwWXfwuH/K8=";
  };

  script = writeShellScriptBin pname ''
      export WINEPREFIX="${location}"
      export GAMEID=umu-wow
      export PROTONPATH="${proton-ge-bin.steamcompattool}/"
      if [ ! -d "${location}" ]; then
        # install launcher
        umu-run ${src}
      else
        GAME="${location}/drive_c/Program Files (x86)/Battle.net/Battle.net Launcher.exe"
        PROTON_ENABLE_WAYLAND=1 umu-run "$GAME"
      fi
 '';

  desktopItems = makeDesktopItem {
    name = pname;
    exec = "${script}/bin/${pname} %U";
    comment = "Battle.net";
    desktopName = "Battle.net";
    categories = ["Game"];
    mimeTypes = ["application/x-battlenet"];
  };
in
  symlinkJoin {
    name = pname;
    paths = [
      desktopItems
      script
    ];

    meta = {
      description = "Battle.net";
      homepage = "";
      license = lib.licenses.unfree;
      maintainers = with lib.maintainers; [kharf];
      platforms = ["x86_64-linux"];
    };
  }
