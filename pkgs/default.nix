{ pkgs, inputs, ... }: {
  cue = pkgs.callPackage ./cue {};
  dagger = pkgs.callPackage ./dagger {};
  wowup = pkgs.callPackage ./wowup {};
  battlenet = pkgs.callPackage ./battlenet {wine = inputs.nix-gaming.packages.${pkgs.system}.wine-ge;};
}
