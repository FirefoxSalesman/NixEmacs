final: prev: inputs: {
  emacsPackagesFor =
    emacs:
    ((prev.emacsPackagesFor emacs).overrideScope (
      nfinal: nprev: {
        org-modern-indent = (
          prev.emacs.pkgs.callPackage ./emacs-packages/org-modern-indent.nix {
            inherit inputs;
            inherit (prev.emacs.pkgs) trivialBuild compat;
          }
        );
        doom-utils = (
          prev.emacs.pkgs.callPackage ./emacs-packages/doom-utils.nix {
            inherit inputs;
            inherit (prev.emacs.pkgs) trivialBuild;
          }
        );
        eglot-x = (
          prev.emacs.pkgs.callPackage ./emacs-packages/eglot-x.nix {
            inherit inputs;
            inherit (prev.emacs.pkgs)
              trivialBuild
              eglot
              project
              xref
              ;
          }
        );
        symex = (
          prev.emacs.pkgs.callPackage ./emacs-packages/symex.nix {
            inherit inputs;
            inherit (prev.emacs.pkgs)
              trivialBuild
              seq
              mantra
              repeat-ring
              paredit
              pubsub
              evil
              ;
          }
        );
        eglot-booster = (
          prev.emacs.pkgs.callPackage ./emacs-packages/eglot-booster.nix {
            inherit inputs;
            inherit (prev.emacs.pkgs) trivialBuild eglot jsonrpc;
          }
        );
        svelte-ts-mode = (
          prev.emacs.pkgs.callPackage ./emacs-packages/svelte-ts-mode.nix {
            inherit inputs;
            inherit (prev.emacs.pkgs) trivialBuild;
          }
        );
        use-package-eglot = (
          prev.emacs.pkgs.callPackage ./emacs-packages/use-package-eglot.nix {
            inherit inputs;
            inherit (prev.emacs.pkgs) trivialBuild use-package eglot;
          }
        );
        org-novelist = (
          prev.emacs.pkgs.callPackage ./emacs-packages/org-novelist.nix {
            inherit inputs;
            inherit (prev.emacs.pkgs) trivialBuild org;
          }
        );
      }
    ));
}
