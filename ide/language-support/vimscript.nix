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
  options.programs.emacs.init.ide.languages.vimscript.enable =
    lib.mkEnableOption "Enables support for vimscript, because why not?";

  config.programs.emacs.init = lib.mkIf ide.languages.vimscript.enable {
    ide.treesitterGrammars.vim = "https://github.com/tree-sitter-grammars/tree-sitter-vim";
    usePackage.vimscript-ts-mode = {
      enable = true;
      mode = [ ''"\\.vim\\'"'' ];
      extraPackages = lib.mkIf (
        ide.eglot.enable || ide.lsp.enable || ide.lspce.enable || ide.lsp-bridge.enable
      ) [ pkgs.vim-language-server ];
      eglot = lib.mkIf ide.eglot.enable ''("vim-language-server" "--stdio")'';
      lsp = ide.lsp.enable;
      lspce = ide.lspce.enable;
      config = lib.mkIf ide.lspce.enable ''(with-eval-after-load 'lspce (add-to-list 'lspce-server-programs '("vimscript" "vim-language-server" "--stdio")))'';
    };
  };
}
