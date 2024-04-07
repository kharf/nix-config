{
  lib,
  makeDesktopItem,
  symlinkJoin,
  writeShellScriptBin,
  gamemode,
  winetricks,
  wine,
  dxvk,
  wineFlags ? "",
  pname ? "battlenet",
  location ? "$HOME/Games/battlenet",
  tricks ? ["arial" "tahoma" "win10"],
  preCommands ? "",
  postCommands ? "",
  pkgs,
}: let
  src = pkgs.fetchurl {
    url = "https://www.battle.net/download/getInstallerForGame?os=win&version=LIVE&gameProgram=BATTLENET_APP";
    name = "Battle.net-Setup.exe";
    hash = "sha256-gldLGvVHPOcK9n9pqNq3wkY5eTtCbP6GvoRmnvNHRwg=";
  };

  # concat winetricks args
  tricksFmt = with builtins;
    if (length tricks) > 0
    then concatStringsSep " " tricks
    else "-V";

  script = writeShellScriptBin pname ''
    export WINEARCH="win64"
    export WINEFSYNC=1
    export WINEESYNC=1
    export WINEPREFIX="${location}"
    export WINEDLLOVERRIDES="libglesv2=b,nvapi,nvapi64=,powershell.exe="
    __GL_SHADER_DISK_CACHE=1
    __GL_SHADER_DISK_CACHE_SIZE=1073741824
    __GL_THREADED_OPTIMIZATIONS=1
    PATH=${lib.makeBinPath [wine winetricks]}:$PATH
    USER="$(whoami)"
    BNET_LAUNCHER="$WINEPREFIX/drive_c/Program Files (x86)/Battle.net/Battle.net Launcher.exe"
    if [ ! -d "$WINEPREFIX" ]; then
      # install tricks
      winetricks -q -f ${tricksFmt}
      wineserver -k
      mkdir -p "$WINEPREFIX/drive_c/Program Files (x86)/Battle.net/Battle.net Launcher.exe"
      # install launcher
      # Use silent install
      wine ${src} /S
      wineserver -k
    fi
    cd $WINEPREFIX
    ${dxvk}/bin/setup_dxvk.sh install --symlink
    ${preCommands}
    ${gamemode}/bin/gamemoderun wine ${wineFlags} "$BNET_LAUNCHER" "$@"
    wineserver -w
    ${postCommands}
  '';

  icon = pkgs.fetchurl {
    url = "https://lutris.net/games/icon/battlenet.png";
    hash = "sha256-F8XNNZyhp1vRVXH2Fqx16X0lTpYINIksf9UwoaN7DJw=";
  };

  desktopItems = makeDesktopItem {
    name = pname;
    exec = "${script}/bin/${pname} %U";
    inherit icon;
    comment = "Battle.net";
    desktopName = "Battle.net";
    categories = ["Game"];
    mimeTypes = ["application/x-battlenet-launcher"];
  };
in
  symlinkJoin {
    name = pname;
    paths = [
      desktopItems
      script
    ];

    meta = {
      description = "Battle.net installer and launcher";
      homepage = "https://www.battle.net";
      license = lib.licenses.unfree;
      maintainers = with lib.maintainers; [kharf];
      platforms = ["x86_64-linux"];
    };
  }
