{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  tomlplusplus,
  cli11,
  gtest,
  libei,
  libportal,
  libX11,
  libxkbfile,
  libXtst,
  libXinerama,
  libXi,
  libXrandr,
  libxkbcommon,
  pugixml,
  python3,
  gdk-pixbuf,
  libnotify,
  qt6,
  xkeyboard_config,
  openssl,
}:
stdenv.mkDerivation {
  pname = "deskflow";
  version = "1.17.0.169";

  src = fetchFromGitHub {
    owner = "deskflow";
    repo = "deskflow";
    rev = "16a1ba8f4543a63eae532995297eb02ae88344e5";
    hash = "sha256-ld7RgzEZ7n8UK1RL4boMa4HyU5aF4jwDTUrwNOXGLNk=";
  };

  postPatch = ''
    substituteInPlace src/lib/deskflow/unix/AppUtilUnix.cpp --replace-fail "/usr/share/X11/xkb/rules/evdev.xml" "${xkeyboard_config}/share/X11/xkb/rules/evdev.xml"
    substituteInPlace src/lib/gui/tls/TlsCertificate.cpp --replace-fail "\"openssl\"" "\"${openssl.bin}/bin/openssl\""
  '';

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    qt6.wrapQtAppsHook
  ];

  cmakeFlags = [
    "-DCMAKE_SKIP_RPATH=ON"
  ];

  strictDeps = true;

  buildInputs = [
    tomlplusplus
    cli11
    gtest
    libei
    libportal
    libX11
    libxkbfile
    libXinerama
    libXi
    libXrandr
    libXtst
    libxkbcommon
    pugixml
    gdk-pixbuf
    libnotify
    python3
    qt6.qtbase
  ];

  postInstall = ''
    substituteInPlace $out/share/applications/deskflow.desktop \
        --replace-fail "Path=/usr/bin" "Path=$out/bin" \
        --replace-fail "Exec=/usr/bin/deskflow" "Exec=deskflow"
  '';

  meta = {
    homepage = "https://github.com/deskflow/deskflow";
    description = "Share one mouse and keyboard between multiple computers on Windows, macOS and Linux";
    mainProgram = "deskflow";
    maintainers = with lib.maintainers; [ aucub ];
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
}
