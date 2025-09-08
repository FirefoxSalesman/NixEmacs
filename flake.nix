{
  description = "Emacs Home Manager Module Flake";

  inputs = {
    org-modern-indent = {
      url = "github:alphapapa/org-modern-indent";
      flake = false;
    };

    eglot-booster = {
      url = "github:jdtsmith/eglot-booster";
      flake = false;
    };

    eglot-x = {
      url = "github:nemethf/eglot-x";
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
