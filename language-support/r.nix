{ pkgs, config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.r.enable = lib.mkEnableOption "enables r support";

  config = lib.mkIf ide.languages.r.enable {
    programs.emacs.init.usePackage.ess-r-mode = {
      enable = true;
      package = epkgs: epkgs.ess;
      extraPackages = if ide.eglot.enable || ide.lsp.enable || ide.lsp-bridge.enable then [pkgs.rPackages.languageserver] else [];
      mode = [''"\\.R\\'"''];
      eglot = ide.eglot.enable;
      lsp = ide.lsp.enable;
      lsp-bridge = ide.lsp-bridge.enable;
      symex = ide.symex;
      custom.ess-ask-for-ess-directory = lib.mkDefault "nil";
    };
  };
}
