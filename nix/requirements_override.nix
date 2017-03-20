{ pkgs, python }:

self: super: {

  "lxml" = python.overrideDerivation super."lxml" (old: {
    buildInputs = old.buildInputs ++ [ pkgs.libxml2 pkgs.libxslt ];
    hardeningDisable = pkgs.stdenv.lib.optional pkgs.stdenv.isDarwin "format";
  });

  "jinja2" = super."Jinja2";
  
}
