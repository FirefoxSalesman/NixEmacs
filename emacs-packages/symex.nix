{
  inputs,
  trivialBuild,
  tsc,
  tree-sitter,
  evil,
  evil-surround,
  seq,
  paredit
}:

trivialBuild rec {
  pname = "symex";
  version = "current";
  src = inputs.symex;

  propagatedUserEnvPkgs = [
    tsc
    tree-sitter
    evil
    evil-surround
    seq
    paredit
  ];

  buildInputs = propagatedUserEnvPkgs;
}
