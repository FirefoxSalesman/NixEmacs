{ inputs, trivialBuild, tsc, tree-sitter, paredit, evil, evil-surround, seq } :

trivialBuild rec {
  pname = "symex2";
  version = "current";
  src = inputs.symex2;

  propagatedUserEnvPkgs = [
    tsc
    tree-sitter
    paredit
    evil
    evil-surround
    seq
  ];

  buildInputs = propagatedUserEnvPkgs;
}
