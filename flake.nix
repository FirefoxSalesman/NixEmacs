{
  description = "Emacs Home Manager Module Flake";

  inputs = {
    semel = {
      url = "github:eshelyaron/semel";
      flake = false;
    };

    org-modern-indent = {
      url = "github:alphapapa/org-modern-indent";
      flake = false;
    };

    eglot-booster = {
      url = "github:jdtsmith/eglot-booster";
      flake = false;
    };

    eglot-x = {
      url = "github:dylanwh/eglot-x/dylan/apply-workspace-edit-arity";
      flake = false;
    };

    doom-utils = {
      url = "github:firefoxsalesman/doom-utils";
      flake = false;
    };

    use-package-eglot = {
      url = "github:firefoxsalesman/use-package-eglot";
      flake = false;
    };

    svelte-ts-mode = {
      url = "github:leafOfTree/svelte-ts-mode";
      flake = false;
    };

    symex = {
      url = "github:firefoxsalesman/symex.el/treesit";
      flake = false;
    };

    org-novelist = {
      url = "github:sympodius/org-novelist";
      flake = false;
    };

    exwm-outer-gaps = {
      url = "github:firefoxsalesman/exwm-outer-gaps";
      flake = false;
    };

    gptel-quick = {
      url = "github:karthink/gptel-quick";
      flake = false;
    };

    ob-gptel.url = "github:jwiegley/ob-gptel";

    ragmacs = {
      url = "github:positron-solutions/ragmacs";
      flake = false;
    };

    macher-agent = {
      url = "github:elij/macher-agent";
      flake = false;
    };
  };

  outputs =
    { self, ... }@inputs:
    {
      homeModules = {
        emacs-init = import ./emacs-init.nix;
        emacs-presets = import ./emacs-presets.nix;
      };
      homeModule = self.homeModules.emacs-init;
      overlay = final: prev: import ./overlay.nix final prev inputs;
    };
}
