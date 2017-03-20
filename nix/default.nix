{ buildPythonPackage,
  pykube, effect, tornado, nose, route53, jinja2, python-etcd, boto3,
  gdo }:
let
  version = "0.1";
in
buildPythonPackage {
  name = "kuberoute-${version}";
  propagatedBuildInputs =
    [ pykube effect tornado nose route53 jinja2 python-etcd boto3 ];
  buildInputs = [ gdo ];
  src = ./..;
  doCheck = false;
}
