{ inputs, trivialBuild, org }:

trivialBuild rec {
  pname = "org-novelist";
  version = "current";
  src = inputs.org-novelist;

  propogatedUserEnvPkgs = [
    org
  ];

  buildInputs = propogatedUserEnvPkgs;
}
