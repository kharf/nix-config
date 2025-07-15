{
  pkgs,
}: let
  version = "1.2988.0";
  pname = "bar";

  src = pkgs.fetchurl {
    url = "https://github.com/beyond-all-reason/BYAR-Chobby/releases/download/v${version}/Beyond-All-Reason-${version}.AppImage";
    hash = "sha256-ZJW5BdxxqyrM2TJTO0SBp4BXt3ILyi77EZx73X8hqJE=";
  };

  appimageContents = pkgs.appimageTools.extractType2 { inherit pname src version; };
in
pkgs.appimageTools.wrapType2 {
  inherit pname src version;
  name = "${pname}-${version}";

  extraPkgs = pkgs: [ pkgs.openal ];

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/beyond-all-reason.desktop $out/share/applications/beyond-all-reason.desktop
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/0x0/apps/beyond-all-reason.png \
      $out/share/icons/hicolor/0x0/apps/beyond-all-reason.png
    substituteInPlace $out/share/applications/beyond-all-reason.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=${pname}'
  '';

  meta = {
    description = "Beyond All Reason RTS";
    homepage = "https://www.beyondallreason.info";
    downloadPage = "https://www.beyondallreason.info/download";
    platforms = [ "x86_64-linux" ];
  };
}
