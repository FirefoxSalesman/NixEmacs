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
      }));
}
