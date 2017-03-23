let
  nixpkgs = import ./pkgs.nix {};
in
{ pkgs ? nixpkgs.pkgs ,
  kuberoute ? nixpkgs.kuberoute,
  image_name ? "kuberoute",
  image_tag ? "latest",
}:
pkgs.dockerTools.buildImage {
  name = image_name;
  tag = image_tag;

  # We want to have basic debugging tools in the image
  contents = [ kuberoute pkgs.bash pkgs.curl pkgs.coreutils ];
  runAsRoot = ''
    #!${pkgs.stdenv.shell}

    mkdir -p /srv/kuberoute
    mkdir -p /tmp
  '';

  config = {
    Cmd = [ "/bin/kuberoute" ];
    WorkingDir = "/srv/kuberoute";
    Volumes = {
      "/srv/kuberoute" = {};
    };
    Env = [ "PYTHONPATH /lib/python3.5/site-packages" ];
  };
}
