{
  pkgs,
}: let
  version = "latest";
  pname = "curseforge";

  src = pkgs.fetchurl {
    url = "https://curseforge.overwolf.com/downloads/curseforge-latest-linux.AppImage";
    hash = "sha256-4DQZNlrJGY1gGAyqB74+vhhI9lCDPAEQrayhSX5G0Uc=";
  };

  appimageContents = pkgs.appimageTools.extractType2 { inherit pname src version; };
in
pkgs.appimageTools.wrapType2 {
  inherit pname src version;
  name = "${pname}-${version}";

  extraPkgs = pkgs: [ pkgs.openal ];

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/curseforge.desktop $out/share/applications/curseforge.desktop
    substituteInPlace $out/share/applications/curseforge.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=${pname}'
  '';

  meta = {
    description = "CurseForge";
    homepage = "https://www.curseforge.com";
    downloadPage = "https://www.curseforge.com/download/app";
    platforms = [ "x86_64-linux" ];
  };
}
