{pkgs, ...}: 

let 
    packages = with pkgs; [
        unstable.dbeaver
        (unstable.google-cloud-sdk.withExtraComponents [unstable.google-cloud-sdk.components.gke-gcloud-auth-plugin])
    ];
in pkgs.runCommand "work" {
    # Dependencies that should exist in the runtime environment
    buildInputs = packages;    
    # Dependencies that should only exist in the build environment
    nativeBuildInputs = [ pkgs.makeWrapper ];
} ''
    mkdir -p $out/bin/
    cmd=work
    ln -s ${pkgs.zsh}/bin/zsh $out/bin/$cmd
    wrapProgram $out/bin/$cmd \
     --set ENVIRONMENT work \
     --set CLOUDSDK_ACTIVE_CONFIG_NAME work \
     --prefix PATH : ${pkgs.lib.makeBinPath packages}
''
