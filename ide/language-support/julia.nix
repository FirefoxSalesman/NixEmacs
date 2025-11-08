{
  config,
  lib,
  ...
}:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.julia.enable =
    lib.mkEnableOption "Enables support for julia (stolen from doom). No support for lspce.";

  config.programs.emacs.init = lib.mkIf ide.languages.julia.enable {
    ide = {
      treesitter.treesitterGrammars.julia = "https://github.com/tree-sitter/tree-sitter-julia";
      treesit-fold.enabledModes = lib.mkIf ide.treesit-fold.enable [ "julia-ts-mode" ];
    };
    usePackage = {
      julia-ts-mode = {
        enable = true;
        mode = [ ''"\\.jl\\'"'' ];
        lsp = ide.lsp.enable;
        eglot = ide.eglot.enable;
        symex = ide.symex;
      };

      julia-repl = {
        enable = true;
        hook = [ "(julia-ts-mode . julia-repl-mode)" ];
      };

      eglot-jl = lib.mkIf ide.eglot.enable {
        enable = true;
        after = [ "eglot" ];
        hook = [
          "(julia-ts-mode . (lambda () (setq-local eglot-connect-timeout (max eglot-connect-timeout 60))))"
        ];
        config = "(eglot-jl-init)";
      };

      lsp-julia = lib.mkIf ide.lsp.enable {
        enable = true;
        after = [ "lsp-mode" ];
        config = ''
          (add-to-list 'lsp-language-id-configuration '(julia-ts-mode . "julia"))
          (lsp-register-client
            (make-lsp-client :new-connection (lsp-stdio-connection 'lsp-julia--rls-command)
                             :major-modes '(julia-mode ess-julia-mode julia-ts-mode)
                             :server-id 'julia-ls
                             :multi-root t))
        '';
      };
    };
  };
}
