{ pkgs, lib, config, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.scheme = {
    enable = lib.mkEnableOption "Enables scheme support, stolen from doom emacs. You will need to install your own scheme interpreter";
    chez = lib.mkEnableOption "Installs geiser-chez";
    chicken = lib.mkEnableOption "Installs geiser-chicken";
    gambit = lib.mkEnableOption "Installs geiser-gambit";
    gauche = lib.mkEnableOption "Installs geiser-gauche";
    guile = lib.mkEnableOption "Installs geiser-guile";
    kawa = lib.mkEnableOption "Installs geiser-kawa. Because I couldn't find a copy of kawa in the nix repos, you'll have to install it yourself.";
    mit = lib.mkEnableOption "Installs geiser-mit";
    stklos = lib.mkEnableOption "Installs geiser-stklos. Because I couldn't find a copy of kawa in the nix repos, you'll have to install it yourself.";
  };

  config = lib.mkIf ide.languages.scheme.enable {
    programs.emacs.init.usePackage = {
      scheme = {
        enable = true;
        mode = [''"\\.scm\\'"''];
        symex = ide.symex;
        init = ''(setq auto-mode-alist (delete '("\\.rkt\\'" . scheme-mode) auto-mode-alist))'';
        config = ''(setq auto-mode-alist (delete '("\\.rkt\\'" . scheme-mode) auto-mode-alist))'';
      };

      geiser = {
        enable = true;
        defer = true;
        hook = ["(scheme-mode . geiser-mode)"];
        custom = {
          geiser-autodoc-identifier-format = lib.mkDefault ''"%s → %s"'';
          geiser-repl-per-project-p = lib.mkDefault "t";
          geiser-repl-query-on-kill = lib.mkDefault "t";
        };
      };

      macrostep-geiser = {
        enable = true;
        hook = [
          "(geiser-mode . macrostep-geiser-setup)"
          "(geiser-repl-mode . macrostep-geiser-setup)"
        ];
      };

      geiser-chez = {
        enable = ide.languages.scheme.chez;
        after = ["geiser"];
        custom.geiser-chez-binary = lib.mkDefault ''"${pkgs.chez}/bin/scheme"'';
      };

      geiser-chicken = {
        enable = ide.languages.scheme.chicken;
        after = ["geiser"];
        custom.geiser-chicken-binary = lib.mkDefault ''"${pkgs.chicken}/bin/csi"'';
      };

      geiser-gambit = {
        enable = ide.languages.scheme.gambit;
        after = ["geiser"];
        custom.geiser-gambit-binary = lib.mkDefault ''"${pkgs.gambit}/bin/gsi"'';
      };

      geiser-gauche = {
        enable = ide.languages.scheme.gauche;
        after = ["geiser"];
        custom.geiser-gauche-binary = lib.mkDefault ''"${pkgs.gauche}/bin/gosh"'';
      };
      
      geiser-guile = {
        enable = ide.languages.scheme.guile;
        after = ["geiser"];
        custom.geiser-guile-binary = lib.mkDefault ''"${pkgs.guile}/bin/guile"'';
      };

      geiser-kawa = {
        enable = ide.languages.scheme.kawa;
        after = ["geiser"];
      };

      geiser-mit = {
        enable = ide.languages.scheme.mit;
        after = ["geiser"];
        custom.geiser-mit-binary = lib.mkDefault ''"${pkgs.mitscheme}/bin/mit-scheme"'';
      };

      geiser-stklos = {
        enable = ide.languages.scheme.stklos;
        after = ["geiser"];
      };
    };
  };
}
