{ trivialBuild, inputs } :

trivialBuild rec {
  pname = "doom-utils";
  version = "current";
  src = inputs.doom-utils;
}
