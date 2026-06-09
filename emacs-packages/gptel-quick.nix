{
  trivialBuild,
  inputs,
  gptel,
}:

trivialBuild rec {
  pname = "gptel-quick";
  version = "current";
  src = inputs.gptel-quick;

  propagatedUserEnvPkgs = [ gptel ];

  buildInputs = propagatedUserEnvPkgs;
}
