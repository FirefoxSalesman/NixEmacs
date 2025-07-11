{ pkgs, config, lib, ... } :
# This module is blatantly stolen from doom emacs

let
  ide = config.programs.emacs.init.ide;
in
{
  options = {
    programs.emacs.init.ide.languages.scala.enable = lib.mkEnableOption "Enables scala support. You will need to bring your own copy of sbt in order to use sbt-mode";
  };

  config = lib.mkIf ide.languages.scala.enable {
    programs.emacs.init.usePackage = {
      scala-ts-mode = {
        enable = true;
        extraPackages = if ide.lsp.enable || ide.eglot.enable then [pkgs.metals] else [];
        mode = [''"\\.scala\\'"''];
        eglot = ide.eglot.enable;
        lsp = ide.lsp.enable;
        symex = ide.symex;
        config = ''
          (with-eval-after-load 'eglot
            (add-to-list 'eglot-server-programs '((scala-ts-mode) . ("metals"))))
        '';
      };

      sbt-mode = {
        enable = true;
        after = ["scala-ts-mode"];
      };
    };
  };
}
