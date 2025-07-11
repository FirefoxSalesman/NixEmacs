{ pkgs, config, lib, ... }:
# This module is blatantly stolen from doom emacs

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.kotlin.enable = lib.mkEnableOption "enables kotlin support";

  config = lib.mkIf ide.languages.kotlin.enable {
    programs.emacs.init.usePackage.kotlin-ts-mode = {
      enable = true;
      mode = [''"\\.kt\\'"''];
      extraPackages = if ide.eglot.enable || ide.lsp.enable then [pkgs.kotlin-language-server] else [];
      symex = ide.symex;
      eglot = ide.eglot.enable;
      lsp = ide.lsp.enable;
      # Kotlin's language server takes a very long time to initialize on a new project
      # https://github.com/fwcd/kotlin-language-server/issues/510
      custom.eglot-connect-timeout = lib.mkDefault "999999";
    };
  };
}
