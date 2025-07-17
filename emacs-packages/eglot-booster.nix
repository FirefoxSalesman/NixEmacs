{ inputs, trivialBuild, eglot, jsonrpc }:

trivialBuild rec {
  pname = "eglot-booster";
  version = "current";
  src = inputs.eglot-booster;

  propagatedUserEnvPkgs = [
    eglot
    jsonrpc
  ];

  buildInputs = propagatedUserEnvPkgs;
}
