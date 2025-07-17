{ pkgs, lib, config, ... }:

let ide = config.programs.emacs.init.ide;
in {
  options.programs.emacs.init.ide.languages.markdown = {
    enable = lib.mkEnableOption "Enables markdown support";
    evil = lib.mkEnableOption
      "Adds some evil keybinds. Symex support is behind this toggle";
  };

  config = lib.mkIf ide.languages.markdown.enable {
    programs.emacs.init.usePackage = {
      markdown = {
        enable = true;
        defer = true;
        extraPackages =
          if ide.eglot.enable || ide.lspce.enable || ide.lsp.enable then
            [ pkgs.marksman ]
          else if ide.lsp-bridge.enable then
            [ pkgs.vale-ls ]
          else
            [ ];
        eglot = ide.eglot.enable;
        lspce = ide.lspce.enable;
        lsp = ide.lsp.enable;
        lsp-bridge = ide.lsp-bridge.enable;
        mode = [ ''("\\.md\\'" . gfm-mode)'' ];
        config = lib.mkIf ide.lspce.enable ''
          (with-eval-after-load 'lspce
                                (dolist (mode ("gfm" "markdown"))
                                        (add-to-list 'lspce-server-programs (list mode "marksman" "server"))))
        '';
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
