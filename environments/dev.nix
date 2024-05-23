{pkgs, config, ...}: 

let 
    packages = with pkgs; [
        unstable.dbeaver-bin
    ];
    home = config.users.users.kharf.home;
in pkgs.runCommand "dev" {
    # Dependencies that should exist in the runtime environment
    buildInputs = packages;    
    # Dependencies that should only exist in the build environment
    nativeBuildInputs = [ pkgs.makeWrapper ];
} ''
    mkdir -p $out/bin/
    cmd=dev
    ln -s ${pkgs.zsh}/bin/zsh $out/bin/$cmd
    wrapProgram $out/bin/$cmd \
     --set ENVIRONMENT dev \
     --set CLOUDSDK_ACTIVE_CONFIG_NAME dev \
     --set KUBECONFIG ${home}/.kube/dev \
     --prefix PATH : ${pkgs.lib.makeBinPath packages}
''
