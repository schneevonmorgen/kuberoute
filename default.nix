let
  nixpkgs = import nix/pkgs.nix {};
in
{ pkgs ? nixpkgs.pkgs,
  pythonPackages ? nixpkgs.pythonPackages }:
let
  callPackage = nixpkgs.callPackage;
in
(callPackage nix/default.nix { gdo = pkgs.haskellPackages.gdo; }).overrideDerivation( old:
  let
    oldShellHook = if builtins.hasAttr "shellHook" old then old.shellHook else "";
    oldBuildInputs = if builtins.hasAttr "buildInputs" old then old.buildInputs else [];
  in
  {
    shellHook = oldShellHook + ''
      export PYTHONPATH=$PWD/src:$PYTHONPATH
    '';
    buildInputs = oldBuildInputs ++ [ pkgs.python3Packages.pylint ];
    
  }
)
