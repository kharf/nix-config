{pkgs, config, ...}:

let
    packages = with pkgs; [
        unstable.dbeaver
    ];
    home = config.users.users.kharf.home;
in pkgs.runCommand "prod" {
    # Dependencies that should exist in the runtime environment
    buildInputs = packages;
    # Dependencies that should only exist in the build environment
    nativeBuildInputs = [ pkgs.makeWrapper ];
} ''
    mkdir -p $out/bin/
    cmd=prod
    ln -s ${pkgs.zsh}/bin/zsh $out/bin/$cmd
    wrapProgram $out/bin/$cmd \
     --set ENVIRONMENT prod \
     --set CLOUDSDK_ACTIVE_CONFIG_NAME prod \
     --set KUBECONFIG ${home}/.kube/prod \
     --prefix PATH : ${pkgs.lib.makeBinPath packages}
''
