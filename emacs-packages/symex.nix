{ inputs, trivialBuild, tsc, paredit, evil, seq } :

trivialBuild rec {
  pname = "symex";
  version = "current";
  src = inputs.symex;

  propagatedUserEnvPkgs = [
    tsc
    paredit
    evil
    evil-surround
    seq
  ];

  buildInputs = propagatedUserEnvPkgs;
}
