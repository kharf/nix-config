{ pkgs, stdenv, lib, installShellFiles }:
pkgs.stdenv.mkDerivation rec {
  pname = "cue";
  version = "v0.8.0-alpha.5";
  src = {
    x86_64-linux = pkgs.fetchurl {
      url = "https://github.com/cue-lang/cue/releases/download/${version}/${pname}_${version}_linux_amd64.tar.gz";
      hash = "sha256-IzAPso9qXmOV4meSxpDA/SItfxvR/LsrBjaWbYC8tw8=";
    };
    aarch64-linux = pkgs.fetchurl  {
      url = "https://github.com/cue-lang/cue/releases/download/${version}/${pname}_${version}_linux_arm64.tar.gz";
      hash = "";
    };
  }.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  dontUnpack = true;

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    tar -xf $src
    mkdir -p $out/bin
    cp cue $out/bin/cue
    cp cuepls $out/bin/cuepls
    chmod +x $out/bin/cue
    chmod +x $out/bin/cuepls
  '';

  installCheckPhase = ''
    $out/bin/cue eval - <<<'a: "all good"' > /dev/null
  '';

  postInstall = ''
    # Completions
    installShellCompletion --cmd cue \
      --bash <($out/bin/cue completion bash) \
      --fish <($out/bin/cue completion fish) \
      --zsh <($out/bin/cue completion zsh)
  '';

  meta = with lib;  {
    description = "A data constraint language which aims to simplify tasks involving defining and using data";
    homepage = "https://cuelang.org/";
    license = lib.licenses.asl20;
    maintainers = with maintainers; [ kharf ];
  };
}
