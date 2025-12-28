# credit to https://git.nullcube.net/nullcube/nullpkgs/src/commit/8098b41237e479f679b9847029648a18531185bf/pkgs/photonvision-rocm/package.nix
# Modified from:
# https://github.com/NixOS/nixpkgs/blob/3e2499d5539c16d0d173ba53552a4ff8547f4539/pkgs/by-name/ph/photonvision/package.nix
{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,

  temurin-bin-17,
  bash,
  suitesparse,
  nixosTests,

  onnxruntime,
  opencv4100,

  cmake,
  clang,
  lapack,
  pnpm,
  re2,
}:

let
  onnxruntime' = onnxruntime.override {
    rocmSupport = true;
  };
in
stdenv.mkDerivation rec {
  pname = "photonvision";
  version = "amd-od-hopefully";

  src =
    {
      "x86_64-linux" = fetchurl {
        url = "https://github.com/spacey-sooty/photonvision/releases/download/${version}/photonvision-${version}-linuxx64.jar";
        hash = "sha256-fba7c75cb93d8c5b6294305f4ad8f78282837b96442d122ad078b6adbc25f3fa";
      };
    }
    .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -D $src $out/lib/photonvision.jar

    makeWrapper ${temurin-bin-17}/bin/java $out/bin/photonvision \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          stdenv.cc.cc
          suitesparse

          temurin-bin-17
          cmake
          opencv4100
          clang
          lapack
          pnpm
          onnxruntime'
          re2
        ]
      } \
      --prefix LD_LIBRARY_PATH : ${opencv4100}/share/java/opencv4 \
      --prefix PATH : ${
        lib.makeBinPath [
          temurin-bin-17
          bash.out
        ]
      } \
      --add-flags "-jar $out/lib/photonvision.jar"

    runHook postInstall
  '';

  passthru.tests = {
    starts-web-server = nixosTests.photonvision;
  };

  meta = {
    description = "Free, fast, and easy-to-use computer vision solution for the FIRST Robotics Competition";
    homepage = "https://photonvision.org/";
    license = lib.licenses.gpl3;
    # maintainers = with lib.maintainers; [ ];
    mainProgram = "photonvision";
    platforms = [
      "x86_64-linux"
    ];
  };
}

