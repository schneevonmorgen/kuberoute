let
  nixpkgs = import nix/pkgs.nix {};
in
{ pkgs ? nixpkgs.pkgs,
  pythonPackages ? nixpkgs.pythonPackages }:
(nixpkgs.callPackage nix/default.nix {}).overrideDerivation( old:
  {
    shellHook = ''
      export PYTHONPATH=$PWD/src:$PYTHONPATH
    '';
  }
)
