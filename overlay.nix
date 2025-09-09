final: prev: inputs: {
  emacsPackagesFor =
    emacs:
    ((prev.emacsPackagesFor emacs).overrideScope (
      nfinal: nprev: {
        org-modern-indent = (
          prev.emacsPackages.callPackage ./emacs-packages/org-modern-indent.nix {
            inherit inputs;
            inherit (prev.emacsPackages) trivialBuild compat;
          }
        );
        doom-utils = (
          prev.emacsPackages.callPackage ./emacs-packages/doom-utils.nix {
            inherit inputs;
            inherit (prev.emacsPackages) trivialBuild;
          }
        );
        eglot-x = (
          prev.emacsPackages.callPackage ./emacs-packages/eglot-x.nix {
            inherit inputs;
            inherit (prev.emacsPackages)
              trivialBuild
              eglot
              project
              xref
            ;
          }
        );
        symex = (
          prev.emacsPackages.callPackage ./emacs-packages/symex.nix {
            inherit inputs;
            inherit (prev.emacsPackages)
              trivialBuild
              tsc
              evil
              seq
              paredit
              lithium
              mantra
              repeat-ring
              pubsub
            ;
          }
        );
        eglot-booster = (
          prev.emacsPackages.callPackage ./emacs-packages/eglot-booster.nix {
            inherit inputs;
            inherit (prev.emacsPackages) trivialBuild eglot jsonrpc;
          }
        );
        svelte-ts-mode = (
          prev.emacsPackages.callPackage ./emacs-packages/svelte-ts-mode.nix {
            inherit inputs;
            inherit (prev.emacsPackages) trivialBuild;
          }
        );
        use-package-eglot = (
          prev.emacsPackages.callPackage ./emacs-packages/use-package-eglot.nix {
            inherit inputs;
            inherit (prev.emacsPackages) trivialBuild use-package eglot;
          }
        );
      }
    ));
}
