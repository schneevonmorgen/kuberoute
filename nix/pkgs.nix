let
  _pkgs = import <nixpkgs> {};

  load_from_json = path: builtins.fromJSON (builtins.readFile path);

  nixpkgs = import (_pkgs.fetchFromGitHub (load_from_json ./nixpkgs.json)) {};

  mozilla_releng_lib = _pkgs.fetchFromGitHub (load_from_json ./mozilla_releng.json);
  mozilla_releng = import ("${mozilla_releng_lib}/nix") { pkgs = nixpkgs; };
in
{ pkgs ? nixpkgs
}:

let

  fix' = f: let x = f x // { __unfix__ = f; }; in x;
  extends = f: rattrs: self:
    let
      super = rattrs self;
    in
      super // f self super;

  update_pkgs = mozilla_releng.lib.updateFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs-channels";
    branch = "nixpkgs-unstable";
    path = "nix/nixpkgs.json";
  };

  update_mozilla_releng = mozilla_releng.lib.updateFromGitHub {
    owner = "mozilla-releng";
    repo = "services";
    branch = "master";
    path = "nix/mozilla_releng.json";
  };

  base = self: {
    pkgs = pkgs // {
      name = "nixpkgs";
      update = update_pkgs;
    };
    mozilla_releng = mozilla_releng // {
      name = "mozilla-releng-services";
      update = update_mozilla_releng;
    };
  };

  additions = self: super: {
    update_python_packages = self.pkgs.writeScript "update-pypi2nix-pkgs" ''
      pushd nix
      ${self.pypi2nix}/bin/pypi2nix -v \
        -V 3.5 \
        -E "libxml2 libxslt" \
        -r "../requirements.txt"
      popd
    '';

    pypi2nix = self.pkgs.pypi2nix.overrideDerivation (old:
      let
        src = self.pkgs.fetchFromGitHub (load_from_json ./pypi2nix.json);
      in
      {
        srcs = [ src ] ++ builtins.tail old.srcs;
      }) // {
        name = "pypi2nix";
        update = self.mozilla_releng.lib.updateFromGitHub {
          owner = "garbas";
          repo = "pypi2nix";
          branch = "master";
          path = "nix/pypi2nix.json";
        };
      };

    pythonPackages = (import ./requirements.nix { pkgs = self.pkgs; }) // {
      update = self.update_python_packages;
      name = "pypi-packages";
    };
    callPackage = self.pkgs.lib.callPackageWith (
      self.pkgs //
      self.pythonPackages //
      self.pythonPackages.packages //
      { buildPythonPackage = self.buildPythonPackage ;
        gdo = self.pkgs.haskellPackages.gdo;
      }
    );
    buildPythonPackage = self.pkgs.python3Packages.buildPythonPackage;
  };
in fix' (extends additions base)
