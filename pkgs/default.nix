{ pkgs, ... }: {
  cue = pkgs.callPackage ./cue {};
  dagger = pkgs.callPackage ./dagger {};
  navecd = pkgs.callPackage ./navecd {};
  aoc = pkgs.callPackage ./aoc {};
  bar = pkgs.callPackage ./bar {};
}
