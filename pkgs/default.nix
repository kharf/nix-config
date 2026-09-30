{ pkgs, ... }: {
  dagger = pkgs.callPackage ./dagger {};
  navecd = pkgs.callPackage ./navecd {};
  bellum= pkgs.callPackage ./bellum {};
  bar = pkgs.callPackage ./bar {};
  battlenet = pkgs.callPackage ./battlenet {
    proton-ge-bin = pkgs.unstable.proton-ge-bin;
  };
  curseforge = pkgs.callPackage ./curseforge {};
}
