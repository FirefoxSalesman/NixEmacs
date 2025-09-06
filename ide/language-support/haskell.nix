{
  pkgs,
  lib,
  config,
  ...
}:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.haskell.enable =
    lib.mkEnableOption "enables haskell support";
  config = lib.mkIf ide.languages.haskell.enable {
    programs.emacs.init = {
      ide.treesitterGrammars.haskell = "https://github.com/tree-sitter/tree-sitter-haskell";
      usePackage.haskell-ts-mode = {
        enable = true;
        babel = lib.mkIf ide.languages.org.enable "haskell";
        mode = [ ''"\\.hs\\'"'' ];
        extraPackages =
          if ide.lsp-bridge.enable || ide.lspce.enable || ide.lsp.enable || ide.eglot.enable then
            [ pkgs.haskell-language-server ]
          else
            [ ];
        eglot = ide.eglot.enable;
        lsp = ide.lsp.enable;
        lspce = ide.lspce.enable;
        config = lib.mkIf ide.lspce.enable ''(nix-emacs-lspce-add-server-program "haskell" "haskell-language-server-wrapper" "--lsp")'';
      };
    };
  };
}
