{ pkgs ? (import ./pkgs.nix {}),
}:

let

  nixpkgs = pkgs.pkgs;

  packages =
    builtins.filter
    (obj: builtins.typeOf obj == "set" && builtins.hasAttr "update" obj)
    (builtins.attrValues pkgs);

in nixpkgs.stdenv.mkDerivation {
  name = "update-releng";
  buildCommand = ''
    echo "+--------------------------------------------------------+"
    echo "| Not possible to update repositories using \`nix-build\`. |"
    echo "|         Please run \`nix-shell update.nix\`.             |"
    echo "+--------------------------------------------------------+"
    exit 1
  '';
  shellHook = ''
    export HOME=$PWD
    echo "Updating packages ..."
    ${builtins.concatStringsSep "\n\n" (
        map (pkg: "echo ' - ${(builtins.parseDrvName pkg.name).name}'; ${pkg.update}") packages)}
    echo ""
    echo "Packages updated!"
    exit
  '';
}
