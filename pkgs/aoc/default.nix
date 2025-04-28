{
  lib,
  makeDesktopItem,
  symlinkJoin,
  writeShellScriptBin,
  gamemode,
  proton-ge-bin,
  pname ? "ashes-of-creation",
  location ? "$HOME/Games/ashes-of-creation",
  pkgs,
}: let
  version = "0.3.268.25582";

  src = pkgs.fetchurl {
    url = "https://ff-intrepid-launcher.s3.us-east-2.amazonaws.com/b9p7a3j6-6cw3-nz5s-km5y-r9w8u2x5cb4d/IntrepidInstaller-${version}.exe";
    name = "IntrepidInstaller-${version}.exe";
    hash = "sha256-PrI62bcIWylF5aL24TNm6THxlYu/qMtGONykDu8Pj08=";
  };

  script = writeShellScriptBin pname ''
    if [ ! -d "${location}" ]; then
    export WINEARCH="win64"
    export WINEPREFIX="${location}"
      # install launcher
      wine ${src}
    else
      export GAMEID=umu-ashesofcreation
      export PROTONPATH="${proton-ge-bin.steamcompattool}/"
      export STORE="none"
      export PROTON_VERBS="run"
      GAME="${location}/drive_c/Program Files/Intrepid Studios/AshesOfCreation/PROD/AOCClient.exe"
      LAUNCHER_PORT="$(netstat -ulpn 2>/dev/null | grep wineserv | awk '{split($4, a , ":"); print a[2]}')"
      ${gamemode}/bin/gamemoderun umu-run "$GAME" LauncherTetherPort=$LAUNCHER_PORT -NOSPLASH -USEEOS=0
    fi
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
    desktopName = "Ashes of Creation";
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
