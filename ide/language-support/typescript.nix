{ pkgs, config, lib, ... }:

let ide = config.programs.emacs.init.ide;
in {
  options.programs.emacs.init.ide.languages.typescript.enable =
    lib.mkEnableOption "enables typescript support";

  config = lib.mkIf ide.languages.typescript.enable {
    programs.emacs.init.usePackage.typescript-ts-mode = {
      enable = true;
      babel = lib.mkIf ide.languages.org.enable "typescript";
      extraPackages = if ide.lsp-bridge.enable || ide.lspce.enable
      || ide.lsp.enable || ide.eglot.enable then
        with pkgs; [ typescript-language-server ]
      else
        [ ];
      mode = [ ''"\\.ts\\'"'' ];
      eglot = ide.eglot.enable;
      symex = ide.symex;
      lsp = ide.lsp.enable;
      lspce = lib.mkIf ide.lspce.enable '''("tsx" "typescript") "typescript-language-server" "--stdio"'';
    };
  };
}
