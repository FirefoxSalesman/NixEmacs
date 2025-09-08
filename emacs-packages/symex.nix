{ inputs, trivialBuild, tsc, paredit, evil, seq, lithium }:

trivialBuild rec {
  pname = "symex";
  version = "current";
  src = inputs.symex;

  propagatedUserEnvPkgs = [
    tsc
    paredit
    evil
    seq
    lithium
  ];

  buildInputs = propagatedUserEnvPkgs;
}
