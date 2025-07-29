  { inputs, trivialBuild, use-package, eglot } :

  trivialBuild rec {
    pname = "use-package-eglot";
    version = "current";
    src = inputs.use-package-eglot;

    propagatedUserEnvPkgs = [
      use-package
      eglot
    ];

    buildInputs = propagatedUserEnvPkgs;
  }
