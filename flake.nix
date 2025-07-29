{
  description = "Emacs Home Manager Module Flake";

  inputs = {
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

    symex2 = {
      url = "github:firefoxsalesman/symex.el/2.0-integration";
      flake = false;
    };

    use-package-eglot = {
      url = "gitlab:aidanhall/use-package-eglot";
      flake = false;
    };
  };

  outputs = { self, ... }@inputs: {
    homeModules = {
      emacs-init = import ./emacs-init.nix;
      emacs-presets = import ./emacs-presets.nix;
    };
    homeModule = self.homeModules.emacs-init;
    overlay = final: prev: import ./overlay.nix final prev inputs;
  };
}
