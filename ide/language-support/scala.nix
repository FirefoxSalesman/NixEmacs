{ pkgs, config, lib, ... }:
# This module is blatantly stolen from doom emacs

let ide = config.programs.emacs.init.ide;
in {
  options = {
    programs.emacs.init.ide.languages.scala.enable = lib.mkEnableOption
      "Enables scala support. You will need to bring your own copy of sbt in order to use sbt-mode";
  };

  config = lib.mkIf ide.languages.scala.enable {
    programs.emacs.init.usePackage = {
      scala-ts-mode = {
        enable = true;
        extraPackages = if ide.lsp-bridge.enable || ide.lspce.enable
        || ide.lsp.enable || ide.eglot.enable then
          [ pkgs.metals ]
        else
          [ ];
        mode = [ ''"\\.scala\\'"'' ];
        eglot = lib.mkIf ide.eglot.enable ''"metals"'';
        lsp = ide.lsp.enable;
        lspce = ide.lspce.enable;
        symex = ide.symex;
        config = lib.mkIf ide.lspce.enable ''(nix-emacs-lspce-add-server-program "scala" "metals")'';
      };

      sbt-mode = {
        enable = true;
        after = [ "scala-ts-mode" ];
      };
    };
  };
}
