{
  trivialBuild,
  inputs,
  gptel,
}:

trivialBuild rec {
  pname = "ragmacs";
  version = "current";
  src = inputs.ragmacs;

  propagatedUserEnvPkgs = [ gptel ];

  buildInputs = propagatedUserEnvPkgs;
}
