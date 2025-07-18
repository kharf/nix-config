{ pkgs, stdenv, lib, installShellFiles }:
pkgs.stdenv.mkDerivation rec {
  pname = "navecd";
  version = "v0.26.11";
  src = {
    x86_64-linux = pkgs.fetchurl {
      url = "https://github.com/kharf/${pname}/releases/download/${version}/${pname}_linux_x86_64.tar.gz";
      hash = "sha256-rofgBiNrQRLR6TyisTBZqwajfGIrm7moQyklMsfCJ78=";
    };
  }.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  dontUnpack = true;

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    tar -xf $src
    mkdir -p $out/bin
    cp ${pname} $out/bin/${pname}
    chmod +x $out/bin/${pname}

    runHook postInstall
  '';

  installCheckPhase = ''
  '';

  postInstall = ''
    # Completions
    installShellCompletion --cmd ${pname} \
      --bash <($out/bin/${pname} completion bash) \
      --fish <($out/bin/${pname} completion fish) \
      --zsh <($out/bin/${pname} completion zsh)
  '';

  meta = with lib;  {
    description = "A Declarative Continuous Delivery Toolkit For Kubernetes";
    homepage = "https://navecd.dev/";
    license = lib.licenses.asl20;
    maintainers = with maintainers; [ kharf ];
  };
}
