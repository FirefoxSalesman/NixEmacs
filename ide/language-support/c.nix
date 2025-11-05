{
  pkgs,
  lib,
  config,
  ...
}:

let
  ide = config.programs.emacs.init.ide;
  completions = config.programs.emacs.init.completions;
in
{
  options.programs.emacs.init.ide.languages.c = {
    enable = lib.mkEnableOption "enables c/c++ support";
    preferClangd = lib.mkEnableOption "uses clang instead of ccls";
  };

  config.programs.emacs.init = lib.mkIf completions.tempel.enable {
    ide.treesitter.wantTreesitter = true;
    completions.tempel.templates.c-ts-mode = {
      doc = ''"/**" n> " * " q n " */"'';
      "if" = ''"if (" p ") {" n> q n "}"'';
      for = ''"for (int i = " p "; i < " p "; i++) {" n> q n "}"'';
      while = ''"while (" p ") {" n> q n "}"'';
      stdio = ''"#include <stdio.h>"'';
      stdlib = ''"#include <stdlib.h>"'';
      string = ''"#include <string.h>"'';
      unistd = ''"#include <unistd.h>"'';
      mpi = ''"#include <mpi.h>"'';
      math = ''"#include <math.h>"'';
      define = ''"#define " p'';
      function = ''p " " p " (" p ") {" n> q n "}"'';
      main = ''"int main (int argc, char **argv) {" n> q n "}" '';
    };
    usePackage = {
      c-ts-mode = {
        enable = true;
        babel = lib.mkIf ide.languages.org.enable "C";
        extraPackages = lib.mkIf (
          ide.lsp-bridge.enable || ide.lspce.enable || ide.lsp.enable || ide.eglot.enable
        ) (if ide.languages.c.preferClangd then [ pkgs.clang-tools ] else [ pkgs.ccls ]);
        bindLocal.c-ts-mode-map."RET" = ''
          (lambda ()
          	(interactive)
                  (if (nix-emacs/in-node "comment")
                       (progn (newline) (insert " * "))
                            (newline)))'';
        mode = [ ''"\\.c\\'"'' ];
        eglot = ide.eglot.enable;
        lsp = ide.lsp.enable;
        symex = ide.symex;
        lspce = lib.mkIf ide.lspce.enable ''"C" "${
          if ide.languages.c.preferClangd then "clangd" else "ccls"
        }"'';
      };

      ccls = lib.mkIf (ide.lsp.enable && !ide.languages.c.preferClangd) {
        enable = true;
        after = [ "lsp-mode" ];
      };

      lsp-bridge.setopt.lsp-bridge-c-lsp-server = lib.mkIf ide.lsp-bridge.enable (
        if !ide.languages.c.preferClangd then ''"ccls"'' else ''"clangd"''
      );
    };
  };
}
