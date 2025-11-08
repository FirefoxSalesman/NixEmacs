{
  pkgs,
  config,
  lib,
  ...
}:

let
  ide = config.programs.emacs.init.ide;
  completions = config.programs.emacs.init.completions;
in
{
  options.programs.emacs.init.ide.languages.bash.enable = lib.mkEnableOption "enables bash support";

  config.programs.emacs.init = lib.mkIf ide.languages.bash.enable {
    completions.tempel.templates.bash-ts-mode = lib.mkIf completions.tempel.enable {
      bang = ''"#!/bin/sh" n q'';
      safebang = ''"#!/bin/sh" n "set -euo pipefail" n q'';
    };
    ide = {
      treesitter.wantTreesitter = true;
      treesit-fold.enabledModes = lib.mkIf ide.treesit-fold.enable [ "bash-ts-mode" ];
    };
    usePackage.bash-ts-mode = {
      enable = true;
      babel = lib.mkIf ide.languages.org.enable "shell";
      extraPackages =
        if ide.lsp-bridge.enable || ide.lspce.enable || ide.lsp.enable || ide.eglot.enable then
          with pkgs; [ nodePackages.bash-language-server ]
        else
          [ ];
      mode = [ ''"\\.sh\\'"'' ];
      eglot = ide.eglot.enable;
      lsp = ide.lsp.enable;
      symex = ide.symex;
      lspce = lib.mkIf ide.lspce.enable '''("sh" "bash") "bash-language-server" "start"'';
    };
  };
}
