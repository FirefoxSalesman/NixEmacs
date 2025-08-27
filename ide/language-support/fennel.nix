{ pkgs, config, lib, ... }:

let ide = config.programs.emacs.init.ide;
in {
  options.programs.emacs.init.ide.languages.fennel.enable =
    lib.mkEnableOption "enables fennel support";

  config = lib.mkIf ide.languages.fennel.enable {
    programs.emacs.init.usePackage.fennel-mode = {
      enable = true;
      extraPackages = if ide.lsp-bridge.enable || ide.eglot.enable
      || ide.lspce.enable || ide.lsp.enable then
        [ pkgs.fennel-ls ]
      else
        [ ];
      mode = [ ''"\\.fnl\\'"'' ];
      symex = ide.symex;
      eglot = lib.mkIf ide.eglot.enable ''"fennel-ls"'';
      lsp = ide.lsp.enable;
      lspce = ide.lspce.enable;
      config = lib.mkIf ide.lspce.enable ''(with-eval-after-load 'lspce (add-to-list 'lspce-server-programs '("fennel" "fennel-ls" "")))'';
    };
  };
}
