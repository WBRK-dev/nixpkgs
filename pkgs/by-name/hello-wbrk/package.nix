{
  lib,
  stdenv,
  writeShellScriptBin,
}:
stdenv.mkDerivation {
  pname = "hello-wbrk";
  version = "0.1.0";
  src = ./.;
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin
    cp ${writeShellScriptBin "hello-wbrk" "echo 'hello from WBRK-dev/nixpkgs'"}"/bin/hello-wbrk" $out/bin/hello-wbrk
  '';
  meta = {
    description = "Example package - replace with your own";
    platforms = lib.platforms.unix;
  };
}
