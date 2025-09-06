{ trivialBuild, inputs } :

trivialBuild rec {
  pname = "svelte-ts-mode";
  version = "current";
  src = inputs.svelte-ts-mode;

  propagatedUserEnvPkgs = [];

  buildInputs = propagatedUserEnvPkgs;
}
