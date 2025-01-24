{ pkgs, stdenv, lib, installShellFiles }:
pkgs.stdenv.mkDerivation rec {
  pname = "dagger";
  version = "v0.15.1";
  src = {
    x86_64-linux = pkgs.fetchurl {
      url = "https://github.com/dagger/dagger/releases/download/${version}/${pname}_${version}_linux_amd64.tar.gz";
      hash = "sha256-/90yvGYwZt+C9sGrJMn//gPxb1njMbN1l3X0a+iGFbo=";
    };
    aarch64-linux = pkgs.fetchurl  {
      url = "https://github.com/dagger/dagger/releases/download/${version}/${pname}_${version}_linux_arm64.tar.gz";
      hash = "";
    };
  }.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  dontUnpack = true;

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    tar -xf $src
    mkdir -p $out/bin
    cp dagger $out/bin/dagger
    chmod +x $out/bin/dagger
  '';

  installCheckPhase = ''
  '';

  postInstall = ''
    # Completions
    installShellCompletion --cmd dagger \
      --bash <($out/bin/dagger completion bash) \
      --fish <($out/bin/dagger completion fish) \
      --zsh <($out/bin/dagger completion zsh)
  '';

  meta = with lib;  {
    description = "Application Delivery as Code that Runs Anywhere";
    homepage = "https://dagger.io/";
    license = lib.licenses.asl20;
    maintainers = with maintainers; [ kharf ];
  };
}
