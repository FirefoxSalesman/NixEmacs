{
  pkgs,
  config,
  lib,
  ...
}:
# This module is blatantly stolen from doom emacs

let
  ide = config.programs.emacs.init.ide;
in
{
  options = {
    programs.emacs.init.ide.languages.scala.enable =
      lib.mkEnableOption "Enables scala support. You will need to bring your own copy of sbt in order to use sbt-mode";
  };

  config.programs.emacs.init = lib.mkIf ide.languages.scala.enable {
    ide.treesitter.wantTreesitter = true;
    usePackage = {
      scala-ts-mode = {
        enable = true;
        extraPackages =
          if ide.lsp-bridge.enable || ide.lspce.enable || ide.lsp.enable || ide.eglot.enable then
            [ pkgs.metals ]
          else
            [ ];
        mode = [ ''"\\.scala\\'"'' ];
        eglot = lib.mkIf ide.eglot.enable ''"metals"'';
        lsp = ide.lsp.enable;
        symex = ide.symex;
        lspce = lib.mkIf ide.lspce.enable ''"scala" "metals"'';
      };

      sbt-mode = {
        enable = true;
        after = [ "scala-ts-mode" ];
      };
    };
  };
}
