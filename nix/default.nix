{ buildPythonPackage,
  pykube, effect, tornado, nose, route53, jinja2, python-etcd, boto3, python3
}:
let
  version = "0.1";
in
buildPythonPackage {
  name = "kuberoute-${version}";
  propagatedBuildInputs =
    [ pykube effect tornado nose route53 jinja2 python-etcd boto3 ];
  buildInputs = [ python3 ];
  src = ./..;
  checkPhase = ''
    python $src/run-tests
  '';
}
