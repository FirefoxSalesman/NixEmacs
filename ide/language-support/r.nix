{
  pkgs,
  config,
  lib,
  ...
}:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.r.enable = lib.mkEnableOption "enables r support";

  config = lib.mkIf ide.languages.r.enable {
    programs.emacs.init.usePackage.ess-r-mode = {
      enable = true;
      babel = lib.mkIf ide.languages.org.enable "R";
      package = epkgs: epkgs.ess;
      extraPackages =
        if ide.eglot.enable || ide.lsp.enable || ide.lspce.enable || ide.lsp-bridge.enable then
          [ pkgs.rPackages.languageserver ]
        else
          [ ];
      mode = [ ''"\\.R\\'"'' ];
      eglot = ide.eglot.enable;
      lsp = ide.lsp.enable;
      custom.ess-ask-for-ess-directory = lib.mkDefault false;
      lspce = lib.mkIf ide.lspce.enable '''("R" "ess-r") "R" "--slave -e languageserver::run()"'';
    };
  };
}
