{ inputs, config, ... }: {
  nixpkgs.overlays = [
      (final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          system = final.system;
          config = {
            allowUnfree = true;
            permittedInsecurePackages = [
              "electron-25.9.0" 
            ];
          };
        };
      })
      (final: prev: {
        prod-shell = final.callPackage ../environments/prod.nix {inherit config;};
        dev-shell = final.callPackage ../environments/dev.nix {inherit config;};
      })
      (final: prev: {
        local = import ../pkgs { pkgs = final.pkgs;};
      })
    ];
}
