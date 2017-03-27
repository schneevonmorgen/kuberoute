{ nixpkgs ? null }:
let
  pkgs =
    if builtins.isNull nixpkgs
    then import nix/pkgs.nix {}
    else import nix/pkgs.nix { nixpkgs = nixpkgs; };
in
(pkgs.callPackage nix/default.nix {}).overrideDerivation( old:
  {
    shellHook = ''
      export PYTHONPATH=$PWD/src:$PYTHONPATH
    '';
  }
)
