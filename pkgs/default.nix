{ pkgs, ... }: {
  dagger = pkgs.callPackage ./dagger {};
  navecd = pkgs.callPackage ./navecd {};
  aoc = pkgs.callPackage ./aoc {};
  aocptr = pkgs.callPackage ./aocptr {};
  aoclauncher = pkgs.callPackage ./aoclauncher {};
  bellum= pkgs.callPackage ./bellum {};
  bar = pkgs.callPackage ./bar {};
}
