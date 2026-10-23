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
  options.programs.emacs.init.ide.languages.markdown = {
    enable = lib.mkEnableOption "Enables markdown support";
    aesthetics.appear = lib.mkEnableOption "Enables markdown-ts-appear";
  };

  config.programs.emacs.init.usePackage = lib.mkIf ide.languages.markdown.enable {
    markdown-ts-mode = {
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
      mode = [ ''("\\.md\\'")'' ];
      lspce = lib.mkIf ide.lspce.enable '''("gfm" "markdown") "marksman" "server"'';
      config = lib.mkIf keybinds.evil.enable ''
        (evil-declare-motion 'markdown-ts-move-to-next-code-block)
        (evil-declare-motion 'markdown-ts-move-to-previous-code-block)
      '';
      generalTwo.":m".markdown-ts-mode-map = lib.mkIf keybinds.evil.enable {
        "]c" = "'markdown-ts-move-to-next-code-block";
        "[c" = "'markdown-ts-move-to-previous-code-block";
        "]h" = "'outline-next-heading";
        "[h" = "'outline-previous-heading";
        "M-${keybinds.evil.keys.up}" = "'outline-move-subtree-up";
        "M-${keybinds.evil.keys.down}" = "'outline-move-subtree-down";
        "M-${keybinds.evil.keys.backward}" = "'markdown-ts-promote";
        "M-${keybinds.evil.keys.forward}" = "'markdown-ts-demote";
      };
    };

    markdown-ts-appear = {
      enable = true;
      defer = true;
      hook = [ "(markdown-ts-mode . markdown-ts-appear-mode)" ];
    };
  };
}
