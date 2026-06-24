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

    tools.apheleia.modeFormatters.ruby-ts-mode = lib.mkIf (
      config.programs.emacs.init.tools.apheleia.enable && (ide.eglot.enable || ide.lsp.enable)
    ) (lib.mkDefault (if ide.eglot.enable then "eglot" else "lsp"));

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
        setopt.ruby-insert-encoding-magic-comment = lib.mkDefault false;
        config = lib.mkIf ide.dap.enable "(require 'dap-ruby)";
      };

      yard-mode = {
        enable = true;
        hook = [ "(ruby-ts-mode . yard-mode)" ];
      };
    };
  };
}
