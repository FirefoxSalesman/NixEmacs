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
  options.programs.emacs.init.ide.languages.ruby.enable = lib.mkEnableOption "Enables ruby support";

  # most of what you see here has been stolen from doom emacs
  config.programs.emacs.init = lib.mkIf ide.languages.ruby.enable {
    ide.treesitter.wantTreesitter = true;
    usePackage = {
      ruby-ts-mode = {
        enable = true;
        mode = [
          ''"\\.\\(?:a?rb\\|aslsx\\)\\'"''
          ''"/\\(?:Brew\\|Fast\\)file\\'"''
        ];
        babel = lib.mkIf ide.languages.org.enable "ruby";
        extraPackages =
          if ide.eglot.enable || ide.lsp.enable || ide.lsp-bridge.enable then
            [ pkgs.rubyPackages.solargraph ]
          else
            [ ];
        eglot = ide.eglot.enable;
        lsp = ide.lsp.enable;
        symex = ide.symex;
        custom.ruby-insert-encoding-magic-comment = lib.mkDefault false;
      };

      yard-mode = {
        enable = true;
        hook = [ "(ruby-ts-mode . yard-mode)" ];
      };
    };
  };
}
