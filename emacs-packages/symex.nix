{
  inputs,
  trivialBuild,
  seq,
  mantra,
  repeat-ring,
  pubsub,
  paredit,
  evil
}:

trivialBuild rec {
  pname = "symex";
  version = "current";
  src = inputs.symex;

  propagatedUserEnvPkgs = [
    seq
    mantra
    repeat-ring
    paredit
    pubsub
    evil
  ];

  buildInputs = propagatedUserEnvPkgs;
}
