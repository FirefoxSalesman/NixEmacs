{ pkgs, lib, config, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.markdown = {
    enable = lib.mkEnableOption "Enables markdown support";
    evil = lib.mkEnableOption "Adds some evil keybinds. Symex support is behind this toggle";
  };

  config = lib.mkIf ide.languages.markdown.enable {
    programs.emacs.init.usePackage = {
      markdown = {
        enable = true;
        defer = true;
        extraPackages = if ide.eglot.enable || ide.lsp.enable then [pkgs.marksman] else [];
        eglot = ide.eglot.enable;
        lsp = ide.lsp.enable;
        mode = [''("\\.md\\'" . gfm-mode)''];
      };
      
      evil-markdown = {
        enable = ide.languages.markdown.evil;
        defer = true;
        symex = ide.symex;
        hook = [
          "(markdown-mode . evil-markdown-mode)"
          "(markdown-mode . outline-minor-mode)"
        ];
      };
    };
  };
}
