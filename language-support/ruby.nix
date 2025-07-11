{ pkgs, lib, config, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.ruby.enable = lib.mkEnableOption "Enables ruby support";
  
  # most of what you see here has been stolen from doom emacs
  config = lib.mkIf ide.languages.ruby.enable {
    programs.emacs.init.usePackage = {
      ruby-ts-mode = {
        enable = true;
        mode = [''"\\.\\(?:a?rb\\|aslsx\\)\\'"'' ''"/\\(?:Brew\\|Fast\\)file\\'"''];
        extraPackages = if ide.eglot.enable || ide.lsp.enable then [pkgs.rubyPackages.solargraph] else [];
        eglot = ide.eglot.enable;
        lsp = ide.lsp.enable;
        symex = ide.symex;
        custom.ruby-insert-encoding-magic-comment = lib.mkDefault "nil";
      };

      yard-mode = {
        enable = true;
        hook = ["(ruby-ts-mode . yard-mode)"];
      };
    };
  };
}
