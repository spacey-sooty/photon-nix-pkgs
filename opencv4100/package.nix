# credit to https://git.nullcube.net/nullcube/nullpkgs/src/commit/8098b41237e479f679b9847029648a18531185bf/pkgs/opencv4100/package.nix#
{
  fetchFromGitHub,
  fetchpatch2,
  opencv4,
  ade,
  ant,
  openjdk,
  python3,
  python3Packages,
}:
(opencv4.override { runAccuracyTests = false; }).overrideAttrs (oldAttr: rec {
  version = "4.10.0";
  src = fetchFromGitHub {
    owner = "opencv";
    repo = "opencv";
    rev = version;
    hash = "sha256-s+KvBrV/BxrxEvPhHzWCVFQdUQwhUdRJyb0wcGDFpeo=";
  };

  # Fix build with cmake4:
  patches = (oldAttr.patches or [ ]) ++ [
    (fetchpatch2 {
      url = "https://github.com/opencv/opencv/commit/cb8030809e0278d02fa335cc1f5ec7c3c17548e0.patch";
      hash = "sha256-1yzOU9xR5LmdxzczM4sXuDyZ/DCLJApAQMUQE2mmAlg=";
    })
  ];

  buildInputs = (oldAttr.buildInputs or [ ]) ++ [ ade ];

  nativeBuildInputs = oldAttr.nativeBuildInputs ++ [
    ant
    openjdk
    python3
    python3Packages.numpy
  ];

  cmakeFlags = oldAttr.cmakeFlags ++ [
    "-DBUILD_JAVA=ON"
    "-DBUILD_opencv_dnn=OFF"
    "-DBUILD_opencv_gapi=ON"
    "-DWITH_ADE=ON"
    "-Dade_DIR=${ade}/lib/cmake/ade"
  ];

  postInstall = (oldAttr.postInstall or "") + ''
    cd $out/lib
    for lib in libopencv_*.so.${version}; do
      if [ -f "$lib" ]; then
        base=$(basename "$lib" .so.${version})
        ln -sf "$lib" "$base.so.4.10"
      fi
    done
  '';
})

