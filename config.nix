# copy this into configuration.nix

nixpkgs.overlays = [
  (final: prev: {
    ade = prev.callPackage ./path { };
    opencv4100 = prev.callPackage ./path { };
    photonvision-rocm = prev.callPackage ./path { };
    # Might have to do the following instead:
    # opencv4100 = prev.callPackage ./path { inherit (final) ade; };
    # photonvision-rocm = prev.callPackage ./path { inherit (final) opencv4100; };
  })
];

services.photonvision.package = pkgs.photonvision-rocm;
