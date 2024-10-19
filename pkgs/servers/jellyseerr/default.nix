{
  lib,
  pnpm_9,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  node-pre-gyp,
  nodejs,
  python3,
  sqlite,
}:

let
  pnpm = pnpm_9;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "jellyseerr";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "Fallenbagel";
    repo = "jellyseerr";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ZqHm8GeougFGfOeHXit2+2dRMeQrGgt3kFlm7pUxWpg=";
  };

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs)
      pname
      version
      src
      ;
    hash = "sha256-L0oV4DqjrLubPFnOp4YxnRq+QyJFcbyv3Xpw7rBJ3ms=";
  };

  nativeBuildInputs = [
    nodejs
    makeWrapper
    pnpm.configHook
    node-pre-gyp
    sqlite
    python3
  ];

  pnpmInstallFlags = "--frozen-lockfile";
  env = {
    CYPRESS_INSTALL_BINARY = "0";
  };

  buildPhase = ''
    runHook preBuild

    pnpm build

    runHook postBuild
  '';

  preInstall = ''
    mkdir -p $out/libexec/jellyseerr/deps/jellyseerr/config
    cp -R ./dist $out/libexec/jellyseerr/deps/jellyseerr
    cp -R ./node_modules $out/libexec/jellyseerr/deps/jellyseerr
  '';

  postInstall = ''
    makeWrapper '${nodejs}/bin/node' "$out/bin/jellyseerr" \
      --add-flags "$out/libexec/jellyseerr/deps/jellyseerr/dist/index.js" \
      --set NODE_ENV production
  '';

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "Fork of overseerr for jellyfin support";
    homepage = "https://github.com/Fallenbagel/jellyseerr";
    longDescription = ''
      Jellyseerr is a free and open source software application for managing
      requests for your media library. It is a a fork of Overseerr built to
      bring support for Jellyfin & Emby media servers!
    '';
    license = licenses.mit;
    maintainers = with maintainers; [ camillemndn ];
    platforms = platforms.linux;
    mainProgram = "jellyseerr";
  };
})
