{ pkgs, ... }: {
  cue = pkgs.callPackage ./cue {};
  dagger = pkgs.callPackage ./dagger {};
}
