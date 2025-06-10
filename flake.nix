{
  description = "Emacs Home Manager Module Flake";

  inputs = {
    doom-utils = {
      url = "github:firefoxsalesman/doom-utils";
      flake = false;
    };
    
    symex2 = {
      url = "github:firefoxsalesman/symex.el/2.0-integration";
      flake = false;
    };
  };

  outputs = { self, ... }:
    {
      homeModules = {
        emacs-init = import ./emacs-init.nix;
      };
      homeModule = self.homeModules.emacs-init;
    };
}
