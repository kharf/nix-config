{ inputs, config, ... }: {
  nixpkgs.overlays = [
      (final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          system = final.system;
          config = {
            allowUnfree = true;
          };
        };
      })
      (final: prev: {
        prod-shell = final.callPackage ../environments/prod.nix {inherit config;};
        dev-shell = final.callPackage ../environments/dev.nix {inherit config;};
      })
      (final: prev: {
        local = import ../pkgs { pkgs = final.pkgs; inherit inputs;};
      })
    ];
}
