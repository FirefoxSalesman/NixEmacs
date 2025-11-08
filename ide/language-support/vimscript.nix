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
    ide = {
      treesitter.treesitterGrammars.vim = "https://github.com/tree-sitter-grammars/tree-sitter-vim";
      treesit-fold.enabledModes = lib.mkIf ide.treesit-fold.enable [ "vimscript-ts-mode" ];
    };
    usePackage.vimscript-ts-mode = {
      enable = true;
      mode = [ ''"\\.vim\\'"'' ];
      extraPackages = lib.mkIf (
        ide.eglot.enable || ide.lsp.enable || ide.lspce.enable || ide.lsp-bridge.enable
      ) [ pkgs.vim-language-server ];
      eglot = lib.mkIf ide.eglot.enable ''("vim-language-server" "--stdio")'';
      lsp = ide.lsp.enable;
      lspce = lib.mkIf ide.lspce.enable ''"vimscript" "vim-language-server" "--stdio"'';
    };
  };
}
