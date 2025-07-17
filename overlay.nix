final: prev: inputs: {
  emacsPackagesFor = emacs: (
    (prev.emacsPackagesFor emacs).overrideScope (
      nfinal: nprev: {
        doom-utils = (prev.emacsPackages.callPackage ./emacs-packages/doom-utils.nix {
          inherit inputs;
          inherit (prev.emacsPackages) trivialBuild;
        });
        symex = (prev.emacsPackages.callPackage ./emacs-packages/symex2.nix {
          inherit inputs;
          inherit (prev.emacsPackages) trivialBuild tsc tree-sitter evil evil-surround seq paredit;
        });
        eglot-x = (prev.emacsPackages.callPackage ./emacs-packages/eglot-x.nix {
          inherit inputs;
          inherit (prev.emacsPackages) trivialBuild eglot project xref;
        });
        eglot-booster = (prev.emacsPackages.callPackage ./emacs-packages/eglot-booster.nix {
          inherit inputs;
          inherit (prev.emacsPackages) trivialBuild eglot jsonrpc;
        });
      }));
}
