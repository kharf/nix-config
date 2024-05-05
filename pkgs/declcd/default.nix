{ pkgs, stdenv, lib, installShellFiles }:
pkgs.stdenv.mkDerivation rec {
  pname = "declcd";
  version = "v0.11.0";
  src = {
    x86_64-linux = pkgs.fetchurl {
      url = "https://github.com/kharf/${pname}/releases/download/${version}/${pname}-linux-amd64";
      hash = "sha256-C8QUgvA2s01rYO7/L9lTP53DEBsQVx4JgNCLwMigP2U=";
    };
  }.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  dontUnpack = true;

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/${pname}
    chmod +x $out/bin/${pname}
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
    homepage = "https://declcd.io/";
    license = lib.licenses.asl20;
    maintainers = with maintainers; [ kharf ];
  };
}