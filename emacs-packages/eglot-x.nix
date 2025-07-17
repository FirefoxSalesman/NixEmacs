{ inputs, trivialBuild, eglot, project, xref }:

trivialBuild rec {
  pname = "eglot-x";
  version = "current";
  src = inputs.eglot-x;

  propagatedUserEnvPkgs = [
    eglot
    project
    xref
  ];

  buildInputs = propagatedUserEnvPkgs;
}
