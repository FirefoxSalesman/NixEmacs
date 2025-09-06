{
  pkgs,
  lib,
  config,
  ...
}:

let
  ide = config.programs.emacs.init.ide;
  keybinds = config.programs.emacs.init.keybinds;
in
{
  options.programs.emacs.init.ide.languages.markdown.enable =
    lib.mkEnableOption "Enables markdown support";

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
        lsp = ide.lsp.enable;
        mode = [ ''("\\.md\\'" . gfm-mode)'' ];
        lspce = lib.mkIf ide.lspce.enable '''("gfm" "markdown") "marksman" "server"'';
      };

      evil-markdown = lib.mkIf keybinds.evil.enable {
        enable = true;
        defer = true;
        symex = ide.symex;
        hook = [
          "(markdown-mode . evil-markdown-mode)"
          "(markdown-mode . outline-minor-mode)"
        ];
        custom.evil-markdown-movement-bindings = ''
          '((up . "${keybinds.evil.keys.up}")
            (down . "${keybinds.evil.keys.down}")
            (left . "${keybinds.evil.keys.backward}")
            (right . "${keybinds.evil.keys.forward}"))
        '';
      };
    };
  };
}
