{ inputs, trivialBuild, xelb, exwm } :

trivialBuild rec {
  pname = "exwm-outer-gaps";
  version = "current";
  src = inputs.exwm-outer-gaps;

  propagatedUserEnvPkgs = [
    xelb
    exwm
  ];

  buildInputs = propagatedUserEnvPkgs;
}
