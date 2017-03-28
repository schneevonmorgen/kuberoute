# generated using pypi2nix tool (version: 1.8.0)
# See more at: https://github.com/garbas/pypi2nix
#
# COMMAND:
#   pypi2nix -v -V 3.5 -E libxml2 libxslt -r ../requirements.txt
#

{ pkgs ? import <nixpkgs> {}
}:

let

  inherit (pkgs) makeWrapper;
  inherit (pkgs.stdenv.lib) fix' extends inNixShell;

  pythonPackages =
  import "${toString pkgs.path}/pkgs/top-level/python-packages.nix" {
    inherit pkgs;
    inherit (pkgs) stdenv;
    python = pkgs.python35;
  };

  commonBuildInputs = with pkgs; [ libxml2 libxslt ];
  commonDoCheck = false;

  withPackages = pkgs':
    let
      pkgs = builtins.removeAttrs pkgs' ["__unfix__"];
      interpreter = pythonPackages.buildPythonPackage {
        name = "python35-interpreter";
        buildInputs = [ makeWrapper ] ++ (builtins.attrValues pkgs);
        buildCommand = ''
          mkdir -p $out/bin
          ln -s ${pythonPackages.python.interpreter}               $out/bin/${pythonPackages.python.executable}
          for dep in ${builtins.concatStringsSep " "               (builtins.attrValues pkgs)}; do
            if [ -d "$dep/bin" ]; then
              for prog in "$dep/bin/"*; do
                if [ -f $prog ]; then
                  ln -s $prog $out/bin/`basename $prog`
                fi
              done
            fi
          done
          for prog in "$out/bin/"*; do
            wrapProgram "$prog" --prefix PYTHONPATH : "$PYTHONPATH"
          done
          pushd $out/bin
          ln -s ${pythonPackages.python.executable} python
          popd
        '';
        passthru.interpreter = pythonPackages.python;
      };
    in {
      __old = pythonPackages;
      inherit interpreter;
      mkDerivation = pythonPackages.buildPythonPackage;
      packages = pkgs;
      overrideDerivation = drv: f:
        pythonPackages.buildPythonPackage (drv.drvAttrs // f drv.drvAttrs);
      withPackages = pkgs'':
        withPackages (pkgs // pkgs'');
    };

  python = withPackages {};

  generated = self: {

    "Jinja2" = python.mkDerivation {
      name = "Jinja2-2.9.5";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/71/59/d7423bd5e7ddaf3a1ce299ab4490e9044e8dfd195420fc83a24de9e60726/Jinja2-2.9.5.tar.gz"; sha256 = "702a24d992f856fa8d5a7a36db6128198d0c21e1da34448ca236c42e92384825"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."MarkupSafe"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.bsdOriginal;
        description = "A small but fast and easy to use stand-alone template engine written in pure python.";
      };
    };



    "MarkupSafe" = python.mkDerivation {
      name = "MarkupSafe-1.0";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/4d/de/32d741db316d8fdb7680822dd37001ef7a448255de9699ab4bfcbdf4172b/MarkupSafe-1.0.tar.gz"; sha256 = "a6be69091dac236ea9c6bc7d012beab42010fa914c459791d627dad4910eb665"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.bsdOriginal;
        description = "Implements a XML/HTML/XHTML Markup safe string for Python";
      };
    };



    "PyYAML" = python.mkDerivation {
      name = "PyYAML-3.12";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/4a/85/db5a2df477072b2902b0eb892feb37d88ac635d36245a72a6a69b23b383a/PyYAML-3.12.tar.gz"; sha256 = "592766c6303207a20efc445587778322d7f73b161bd994f227adaa341ba212ab"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.mit;
        description = "YAML parser and emitter for Python";
      };
    };



    "attrs" = python.mkDerivation {
      name = "attrs-16.3.0";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/01/b0/3ac73bf6df716a38568a16f6a9cbc46cc9e8ed6fe30c8768260030db55d4/attrs-16.3.0.tar.gz"; sha256 = "80203177723e36f3bbe15aa8553da6e80d47bfe53647220ccaa9ad7a5e473ccc"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.mit;
        description = "Attributes Without Boilerplate";
      };
    };



    "boto3" = python.mkDerivation {
      name = "boto3-1.4.4";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/58/61/50d2e459049c5dbc963473a71fae928ac0e58ffe3fe7afd24c817ee210b9/boto3-1.4.4.tar.gz"; sha256 = "518f724c4758e5a5bed114fbcbd1cf470a15306d416ff421a025b76f1d390939"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."botocore"
      self."jmespath"
      self."s3transfer"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.asl20;
        description = "The AWS SDK for Python";
      };
    };



    "botocore" = python.mkDerivation {
      name = "botocore-1.5.30";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/f7/52/7de9b8eacc3cd90b9687435cc9573b682dccf929ff532a302385d3af825a/botocore-1.5.30.tar.gz"; sha256 = "c06efafa14710da1c6019ab5b2668015cd21d3781ffe371d3fc2610332566bbf"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."docutils"
      self."jmespath"
      self."python-dateutil"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.asl20;
        description = "Low-level, data-driven core of boto 3.";
      };
    };



    "dnspython" = python.mkDerivation {
      name = "dnspython-1.15.0";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/e4/96/a598fa35f8a625bc39fed50cdbe3fd8a52ef215ef8475c17cabade6656cb/dnspython-1.15.0.zip"; sha256 = "40f563e1f7a7b80dc5a4e76ad75c23da53d62f1e15e6e517293b04e1f84ead7c"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.bsdOriginal;
        description = "DNS toolkit";
      };
    };



    "docutils" = python.mkDerivation {
      name = "docutils-0.13.1";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/05/25/7b5484aca5d46915493f1fd4ecb63c38c333bd32aa9ad6e19da8d08895ae/docutils-0.13.1.tar.gz"; sha256 = "718c0f5fb677be0f34b781e04241c4067cbd9327b66bdd8e763201130f5175be"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.publicDomain;
        description = "Docutils -- Python Documentation Utilities";
      };
    };



    "effect" = python.mkDerivation {
      name = "effect-0.11.0";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/8a/9a/25a881d1a48847ae95742a30ad0471d9fd71f28a506d30e09dc8cdf4b3ac/effect-0.11.0.tar.gz"; sha256 = "0607530ef589b59f907cfebcb681b5ed4ed56bff1fc2a5de430dcfa72ae1e5e0"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."attrs"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.mit;
        description = "pure effects for Python";
      };
    };



    "httplib2" = python.mkDerivation {
      name = "httplib2-0.10.3";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/e4/2e/a7e27d2c36076efeb8c0e519758968b20389adf57a9ce3af139891af2696/httplib2-0.10.3.tar.gz"; sha256 = "e404d3b7bd86c1bc931906098e7c1305d6a3a6dcef141b8bb1059903abb3ceeb"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.mit;
        description = "A comprehensive HTTP client library.";
      };
    };



    "jmespath" = python.mkDerivation {
      name = "jmespath-0.9.2";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/96/6e/0723cccec195a37de6a428ad8879fe063b6debe5c855444e9285b27d253e/jmespath-0.9.2.tar.gz"; sha256 = "54c441e2e08b23f12d7fa7d8e6761768c47c969e6aed10eead57505ba760aee9"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.mit;
        description = "JSON Matching Expressions";
      };
    };



    "lxml" = python.mkDerivation {
      name = "lxml-3.7.3";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/39/e8/a8e0b1fa65dd021d48fe21464f71783655f39a41f218293c1c590d54eb82/lxml-3.7.3.tar.gz"; sha256 = "aa502d78a51ee7d127b4824ff96500f0181d3c7826e6ee7b800d068be79361c7"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.bsdOriginal;
        description = "Powerful and Pythonic XML processing library combining libxml2/libxslt with the ElementTree API.";
      };
    };



    "nose" = python.mkDerivation {
      name = "nose-1.3.7";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/58/a5/0dc93c3ec33f4e281849523a5a913fa1eea9a3068acfa754d44d88107a44/nose-1.3.7.tar.gz"; sha256 = "f1bffef9cbc82628f6e7d7b40d7e255aefaa1adb6a1b1d26c69a8b79e6208a98"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.lgpl2;
        description = "nose extends unittest to make testing easier";
      };
    };



    "oauth2client" = python.mkDerivation {
      name = "oauth2client-4.0.0";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/c2/ce/7aaf19d8b856191e2e1885201fe45f3dc57b97f5ec5bc98ef2cc15472918/oauth2client-4.0.0.tar.gz"; sha256 = "80be5420889694634b8517b4acd3292ace881d9d1aa9d590d37ec52faec238c7"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."httplib2"
      self."pyasn1"
      self."pyasn1-modules"
      self."rsa"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.asl20;
        description = "OAuth 2.0 client library";
      };
    };



    "oauthlib" = python.mkDerivation {
      name = "oauthlib-2.0.2";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/fa/2e/25f25e6c69d97cf921f0a8f7d520e0ef336dd3deca0142c0b634b0236a90/oauthlib-2.0.2.tar.gz"; sha256 = "b3b9b47f2a263fe249b5b48c4e25a5bce882ff20a0ac34d553ce43cff55b53ac"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."nose"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.bsdOriginal;
        description = "A generic, spec-compliant, thorough implementation of the OAuth request-signing logic";
      };
    };



    "pyasn1" = python.mkDerivation {
      name = "pyasn1-0.2.3";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/69/17/eec927b7604d2663fef82204578a0056e11e0fc08d485fdb3b6199d9b590/pyasn1-0.2.3.tar.gz"; sha256 = "738c4ebd88a718e700ee35c8d129acce2286542daa80a82823a7073644f706ad"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.bsdOriginal;
        description = "ASN.1 types and codecs";
      };
    };



    "pyasn1-modules" = python.mkDerivation {
      name = "pyasn1-modules-0.0.8";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/60/32/7703bccdba05998e4ff04db5038a6695a93bedc45dcf491724b85b5db76a/pyasn1-modules-0.0.8.tar.gz"; sha256 = "10561934f1829bcc455c7ecdcdacdb4be5ffd3696f26f468eb6eb41e107f3837"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pyasn1"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.bsdOriginal;
        description = "A collection of ASN.1-based protocols modules.";
      };
    };



    "pykube" = python.mkDerivation {
      name = "pykube-0.15.0";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/a2/40/59fe3425a3d4ac4a41f8d99e71f4862b1c3aaaa99f61afd50ff37f39dae2/pykube-0.15.0.tar.gz"; sha256 = "e53800d0d45f13911aa4ebca8463ae5cc82afad461f6575a0a217d2fce5f088b"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."PyYAML"
      self."oauth2client"
      self."requests"
      self."requests-oauthlib"
      self."six"
      self."tzlocal"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Python client library for Kubernetes";
      };
    };



    "python-dateutil" = python.mkDerivation {
      name = "python-dateutil-2.6.0";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/51/fc/39a3fbde6864942e8bb24c93663734b74e281b984d1b8c4f95d64b0c21f6/python-dateutil-2.6.0.tar.gz"; sha256 = "62a2f8df3d66f878373fd0072eacf4ee52194ba302e00082828e0d263b0418d2"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.bsdOriginal;
        description = "Extensions to the standard Python datetime module";
      };
    };



    "python-etcd" = python.mkDerivation {
      name = "python-etcd-0.4.5";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/a1/da/616a4d073642da5dd432e5289b7c1cb0963cc5dde23d1ecb8d726821ab41/python-etcd-0.4.5.tar.gz"; sha256 = "f1b5ebb825a3e8190494f5ce1509fde9069f2754838ed90402a8c11e1f52b8cb"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."dnspython"
      self."urllib3"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.mit;
        description = "A python client for etcd";
      };
    };



    "pytz" = python.mkDerivation {
      name = "pytz-2016.10";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/d0/e1/aca6ef73a7bd322a7fc73fd99631ee3454d4fc67dc2bee463e2adf6bb3d3/pytz-2016.10.tar.bz2"; sha256 = "7016b2c4fa075c564b81c37a252a5fccf60d8964aa31b7f5eae59aeb594ae02b"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.mit;
        description = "World timezone definitions, modern and historical";
      };
    };



    "requests" = python.mkDerivation {
      name = "requests-2.13.0";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/16/09/37b69de7c924d318e51ece1c4ceb679bf93be9d05973bb30c35babd596e2/requests-2.13.0.tar.gz"; sha256 = "5722cd09762faa01276230270ff16af7acf7c5c45d623868d9ba116f15791ce8"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.asl20;
        description = "Python HTTP for Humans.";
      };
    };



    "requests-oauthlib" = python.mkDerivation {
      name = "requests-oauthlib-0.8.0";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/80/14/ad120c720f86c547ba8988010d5186102030591f71f7099f23921ca47fe5/requests-oauthlib-0.8.0.tar.gz"; sha256 = "883ac416757eada6d3d07054ec7092ac21c7f35cb1d2cf82faf205637081f468"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."oauthlib"
      self."requests"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.bsdOriginal;
        description = "OAuthlib authentication support for Requests.";
      };
    };



    "route53" = python.mkDerivation {
      name = "route53-1.0.1";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/0f/8e/6a2801012c000f81580ff6a6d69d5c5ad136589f4ed306f7b0bb8e63c5fe/route53-1.0.1.tar.gz"; sha256 = "8e08a1c575bac3adc9288f9b10a35b0ff54eced79fc67ceface72a91080e9baa"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."lxml"
      self."pytz"
      self."requests"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.bsdOriginal;
        description = "A simple Route53 API for Python 2.7/3.x, powered by requests.";
      };
    };



    "rsa" = python.mkDerivation {
      name = "rsa-3.4.2";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/14/89/adf8b72371e37f3ca69c6cb8ab6319d009c4a24b04a31399e5bd77d9bb57/rsa-3.4.2.tar.gz"; sha256 = "25df4e10c263fb88b5ace923dd84bf9aa7f5019687b5e55382ffcdb8bede9db5"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pyasn1"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Pure-Python RSA implementation";
      };
    };



    "s3transfer" = python.mkDerivation {
      name = "s3transfer-0.1.10";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/8b/13/517e8ec7c13f0bb002be33fbf53c4e3198c55bb03148827d72064426fe6e/s3transfer-0.1.10.tar.gz"; sha256 = "ba1a9104939b7c0331dc4dd234d79afeed8b66edce77bbeeecd4f56de74a0fc1"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."botocore"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.asl20;
        description = "An Amazon S3 Transfer Manager";
      };
    };



    "six" = python.mkDerivation {
      name = "six-1.10.0";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/b3/b2/238e2590826bfdd113244a40d9d3eb26918bd798fc187e2360a8367068db/six-1.10.0.tar.gz"; sha256 = "105f8d68616f8248e24bf0e9372ef04d3cc10104f1980f54d57b2ce73a5ad56a"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.mit;
        description = "Python 2 and 3 compatibility utilities";
      };
    };



    "tornado" = python.mkDerivation {
      name = "tornado-4.4.2";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/1e/7c/ea047f7bbd1ff22a7f69fe55e7561040e3e54d6f31da6267ef9748321f98/tornado-4.4.2.tar.gz"; sha256 = "2898f992f898cd41eeb8d53b6df75495f2f423b6672890aadaf196ea1448edcc"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Tornado is a Python web framework and asynchronous networking library, originally developed at FriendFeed.";
      };
    };



    "tzlocal" = python.mkDerivation {
      name = "tzlocal-1.3";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/d3/64/e4b18738496213f82b88b31c431a0e4ece143801fb6771dddd1c2bf0101b/tzlocal-1.3.tar.gz"; sha256 = "d160c2ce4f8b1831dabfe766bd844cf9012f766539cf84139c2faac5201882ce"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pytz"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = "License :: CC0 1.0 Universal (CC0 1.0) Public Domain Dedication";
        description = "tzinfo object for the local timezone";
      };
    };



    "urllib3" = python.mkDerivation {
      name = "urllib3-1.20";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/20/56/a6aa403b0998f857b474a538343ee483f5c02491bd1aebf61d42a3f60f77/urllib3-1.20.tar.gz"; sha256 = "97ef2b6e2878d84c0126b9f4e608e37a951ca7848e4855a7f7f4437d5c34a72f"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.mit;
        description = "HTTP library with thread-safe connection pooling, file post, and more.";
      };
    };

  };
  overrides = import ./requirements_override.nix { inherit pkgs python; };
  commonOverrides = [

  ];

in python.withPackages
   (fix' (pkgs.lib.fold
            extends
            generated
            ([overrides] ++ commonOverrides)
         )
   )