{ pkgs, stdenv, lib, appimageTools }:
let
  version = "2.11.1-beta.1";
in
appimageTools.wrapType2 { # or wrapType1
  name = "wowup";
  src = {
    x86_64-linux = pkgs.fetchurl {
      url = "https://github.com/wowup/wowup.cf/releases/download/v${version}/WowUp-cf-${version}.AppImage";
      hash = "sha256-8qBdabr/qMvENnt/99AqsHJZb49S6EXq5YPlbJ+E67M=";
    };
  }.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  meta = with lib;  {
    description = "WowUp the World of Warcraft addon updater";
    homepage = "https://wowup.io/";
    license = lib.licenses.gpl3;
    maintainers = with maintainers; [ kharf ];
  };
}
