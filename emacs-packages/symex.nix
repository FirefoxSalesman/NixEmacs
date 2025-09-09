{ inputs, trivialBuild, tsc, paredit, evil, seq, lithium, mantra, repeat-ring, pubsub }:

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
    mantra
    repeat-ring 
    pubsub
  ];

  buildInputs = propagatedUserEnvPkgs;
}
