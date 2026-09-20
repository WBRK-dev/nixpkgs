{ lib
, stdenvNoCC
, fetchFromGitHub
, bash
, makeWrapper
, docker
, docker-compose
, git
, openssl
, coreutils
, dnsmasqPort ? 53
}:

stdenvNoCC.mkDerivation rec {
  pname = "warden";
  version = "0.16.0-p3";
  srcRev = "0.16.0";

  src = fetchFromGitHub {
    owner = "wardenenv";
    repo = "warden";
    rev = srcRev;
    hash = "sha256-kJCnbMMXG5chIW8Pp9gr3VUStKs6SMr680PZsDPFUdI=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;
  dontConfigure = true;

  postPatch = ''
    sed -i '/^readonly WARDEN_DIR/,/^)"/{
      /^readonly WARDEN_DIR/c\readonly WARDEN_DIR="@out@/share/warden"
      /^readonly WARDEN_DIR/!d
    }' bin/warden

    sed -i 's|export readonly WARDEN_BIN="''${WARDEN_DIR}/bin/warden"|export readonly WARDEN_BIN="@out@/bin/warden"|' bin/warden

    # Host port baked in at build time; override via `warden.override { dnsmasqPort = ...; }`.
    sed -i 's|127.0.0.1:53|127.0.0.1:${toString dnsmasqPort}|' docker/docker-compose.dnsmasq.yml
    sed -i '/-vite\./d' environments/laravel/laravel.base.yml
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/warden

    substituteInPlace bin/warden \
      --replace-fail "@out@" "$out"

    install -Dm755 bin/warden $out/bin/warden

    for dir in commands config docker environments utils; do
      if [ -d "$dir" ]; then
        cp -r "$dir" $out/share/warden/
      fi
    done

    cp -r $out/bin $out/share/warden

    for f in version; do
      if [ -f "$f" ]; then
        install -Dm644 "$f" $out/share/warden/"$f"
      fi
    done

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/warden \
      --set WARDEN_DIR $out/share/warden \
      --prefix PATH : ${lib.makeBinPath [
        bash
        coreutils
        docker
        docker-compose
        git
        openssl
      ]}
  '';

  meta = with lib; {
    description = "CLI utility for orchestrating Docker-based developer environments";
    longDescription = ''
      Warden is a CLI utility for orchestrating Docker based developer
      environments, enabling multiple local environments to run simultaneously
      without port conflicts via centrally run services (Traefik, Portainer,
      Dnsmasq) that proxy requests into the correct environment containers.
    '';
    homepage = "https://warden.dev";
    changelog = "https://github.com/wardenenv/warden/blob/${srcRev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = "warden";
  };
}
