{ pkgs, config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.perl.enable = lib.mkEnableOption "Enables perl support";
  config = lib.mkIf ide.languages.perl.enable {
    programs.emacs.init.usePackage.perl-mode = {
      enable = true;
      mode = [''"\\.pl\\'"''];
      extraPackages = if ide.eglot || ide.lsp then [pkgs.perl540Packages.PerlLanguageServer] else [];
      symex = ide.symex;
      eglot = ide.eglot;
      lsp = ide.lsp;
    };
  };
}
