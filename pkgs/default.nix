{ pkgs, ... }: {
  dagger = pkgs.callPackage ./dagger {};
  navecd = pkgs.callPackage ./navecd {};
  bellum= pkgs.callPackage ./bellum {};
  bar = pkgs.callPackage ./bar {};
}
