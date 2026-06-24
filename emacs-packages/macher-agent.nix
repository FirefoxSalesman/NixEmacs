{
  trivialBuild,
  inputs,
  gptel,
  macher,
}:

trivialBuild rec {
  pname = "macher-agent";
  version = "current";
  src = inputs.macher-agent;

  propagatedUserEnvPkgs = [
    gptel
    macher
  ];

  buildInputs = propagatedUserEnvPkgs;
}
