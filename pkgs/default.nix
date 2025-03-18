{ pkgs, ... }: {
  dagger = pkgs.callPackage ./dagger {};
  navecd = pkgs.callPackage ./navecd {};
  aoc = pkgs.callPackage ./aoc {};
  bar = pkgs.callPackage ./bar {};
}
