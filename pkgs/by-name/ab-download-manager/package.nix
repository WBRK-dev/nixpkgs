{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  makeFontsConf,
  alsa-lib,
  dbus,
  dejavu_fonts,
  liberation_ttf,
  fontconfig,
  freetype,
  libGL,
  libx11,
  libxext,
  libxi,
  libxrender,
  libxtst,
  libxkbcommon,
  wayland,
  zlib,
  libcxx,
}:

let
  pname = "ab-download-manager";
  version = "1.10.3";

  # The bundled JRE's own font manager (sun.awt.FontConfiguration) needs a
  # resolvable fonts.conf - there isn't one in the Nix sandbox by default,
  # which otherwise fails at startup with "Fontconfig head is null".
  fontsConf = makeFontsConf {
    fontDirectories = [
      dejavu_fonts
      liberation_ttf
    ];
  };

  # Upstream only ships prebuilt app-images (jpackage, with a bundled JRE)
  # for Linux x86_64 and aarch64 - there is no source build in this
  # derivation, only repackaging of the official release tarballs.
  sources = {
    x86_64-linux = fetchurl {
      url = "https://github.com/amir1376/ab-download-manager/releases/download/v${version}/ABDownloadManager_${version}_linux_x64.tar.gz";
      hash = "sha256-hDOmsYyOCIy0NweYtjtiuAQKEpmcZs4Ux2Dol4TnvrM=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/amir1376/ab-download-manager/releases/download/v${version}/ABDownloadManager_${version}_linux_arm64.tar.gz";
      hash = "sha256-GNBxBRrhMkHsSzDKffaexO6nTyyZELVQXjPO6ruNAgA=";
    };
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit pname version;

  src =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "${pname}: no prebuilt release for ${stdenvNoCC.hostPlatform.system} (only x86_64-linux and aarch64-linux are published)");

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
  ];

  # These cover the native libraries the launcher, the bundled JRE (AWT/Xawt,
  # Wayland toolkit) and the Skiko rendering library link against. Everything
  # else they need (libjava.so, libjvm.so, libjli.so, ...) ships inside the
  # tarball itself, under lib/runtime and lib/app, and is picked up by
  # autoPatchelfHook automatically since it scans the whole output.
  buildInputs = [
    alsa-lib
    dbus
    fontconfig
    freetype
    libGL
    libxkbcommon
    wayland
    zlib
    libcxx
    libx11
    libxext
    libxi
    libxrender
    libxtst
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/${pname} $out/bin
    cp -r . $out/opt/${pname}

    for exe in ABDownloadManager ABDownloadManagerCli ABDownloadManagerNativeMessagingHost; do
        makeWrapper $out/opt/${pname}/bin/"$exe" $out/bin/"$exe" \
            --set FONTCONFIG_FILE "${fontsConf}" \
            --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ fontconfig dbus ]}"
    done

    install -Dm444 $out/opt/${pname}/lib/ABDownloadManager.png \
      $out/share/icons/hicolor/512x512/apps/${pname}.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = "ABDownloadManager";
      icon = pname;
      desktopName = "AB Download Manager";
      genericName = "Download Manager";
      comment = "A download manager that speeds up your downloads";
      categories = [
        "Network"
        "FileTransfer"
      ];
      startupWMClass = "com-abdownloadmanager-desktop-AppKt";
    })
  ];

  # Prebuilt, closed-build jpackage bundle (bundled OpenJDK runtime + native
  # launchers); there's nothing here for autoPatchelfHook to "build".
  meta = {
    description = "Download manager with multi-threaded downloads, queues/schedulers and browser integration";
    longDescription = ''
      AB Download Manager is a desktop app that helps you manage and organize
      your downloads more efficiently, with faster download speeds via
      multi-threaded connections, queues and schedulers, and browser
      extensions for Chrome and Firefox.

      This packages the official prebuilt Linux app-image release, which
      ships with its own bundled Java runtime.
    '';
    homepage = "https://abdownloadmanager.com";
    changelog = "https://github.com/amir1376/ab-download-manager/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    mainProgram = "ABDownloadManager";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
