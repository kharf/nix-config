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
    url = "http://l.playbellum.com/ls/click?upn=u001.uFkQfO97TmRuLhSsg8YRW3AgKfgF4gV9jRU97HiDsfjowpkwei2ai9Bxtq0vpiOIhcT7_3i2bZHWM7XW3klgMBLrBKouTZHb-2FqtJqBOfISspqZBRwckK3Insnir20gJjjJzM0gF2dIkzz1hJOxuHsouY-2Fpktgn9D3FBglpLGUMRoLWF7c2wiG8eOT-2FzPrpVpVfpPwoXd6NwYZugnaXsTsB5br-2F3ysNXRepYfi8jYd9ArRIClT846oU-2F6WSugj6-2FS8P9O6kGIhiu83B9uuDMCRVqr1HrhnE9AeMvsYyPybMX4w-2FKI3-2BhN-2FqtGV1xy4tcg3GDbGyawBlLu4Q6fP-2BMclbj1mtZfA5rwemfgPRG1hlD6NaV-2F5OhNAnN21rQorFM1irPQchalgEodx2QAqdvXgc-2FG3V4bVJS57Kng8MPxp4x52Y1zfIH2kECaqOSH2IAuZBnvsOrxOOBIk1ViPG8tyA-2BuR2Q-3D-3D";
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
