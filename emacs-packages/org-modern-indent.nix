  { inputs, trivialBuild, compat } :

  trivialBuild rec {
    pname = "org-modern-indent";
    version = "current";
    src = inputs.org-modern-indent;

    propagatedUserEnvPkgs = [
      compat
    ];

    buildInputs = propagatedUserEnvPkgs;
  }
