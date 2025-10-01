{
  lib,
  makeDesktopItem,
  symlinkJoin,
  writeShellScriptBin,
  gamemode,
  proton-ge-bin,
  pname ? "ashes-of-creation-launcher",
  location ? "$HOME/Games/ashes-of-creation",
  pkgs,
}: let
  script = writeShellScriptBin pname ''
      export WINEARCH="win64"
      export WINEPREFIX="${location}"
      export GAMEID=umu-ashesofcreation
      export PROTONPATH="${proton-ge-bin.steamcompattool}/"
      export STORE="none"
      export PROTON_VERBS="run"
      GAME="${location}/drive_c/Program Files/Intrepid Studios/Launcher/IntrepidStudiosLauncher.exe"
      ${gamemode}/bin/gamemoderun umu-run "$GAME"
 '';

  icon = pkgs.fetchurl {
    url = "https://ashesofcreation.com/_next/image?url=%2Faoc-mobile.png&w=3840&q=75";
    hash = "sha256-k6dlvFEYPkPhmE+bmkb0cXBOkb2Cmb70wbfr32kq1fQ=";
  };

  desktopItems = makeDesktopItem {
    name = pname;
    exec = "${script}/bin/${pname} %U";
    inherit icon;
    comment = "AoC";
    desktopName = "Intrepid Launcher";
    categories = ["Game"];
    mimeTypes = ["application/x-aoc"];
  };
in
  symlinkJoin {
    name = pname;
    paths = [
      desktopItems
      script
    ];

    meta = {
      description = "AoC";
      homepage = "";
      license = lib.licenses.unfree;
      maintainers = with lib.maintainers; [kharf];
      platforms = ["x86_64-linux"];
    };
  }
