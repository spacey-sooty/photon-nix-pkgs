# credit to https://git.nullcube.net/nullcube/nullpkgs/src/commit/8098b41237e479f679b9847029648a18531185bf/pkgs/ade/package.nix
{
  stdenv,
  fetchFromGitHub,
  cmake,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ade";
  version = "0.1.2e";

  src = fetchFromGitHub {
    owner = "opencv";
    repo = "ade";
    rev = "v${finalAttrs.version}";
    hash = "sha256-1z5ChmXyanEghBLpopJlRIjOMu+GFAON0X8K2ZhYVlA=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=OFF"
  ];
})

