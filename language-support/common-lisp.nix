{ pkgs, lib, config, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.common-lisp.enable = lib.mkEnableOption "enables common lisp support, stolen from Doom Emacs";

  config = lib.mkIf ide.languages.common-lisp.enable {
    programs.emacs.init.usePackage = {
      sly = {
        enable = true;
        hook = ["(lisp-mode-local-vars . sly-editing-mode)"];
        custom = {
          inferior-lisp-program = lib.mkDefault ''"${pkgs.sbcl}/bin/sbcl"'';
          sly-kill-without-query-p = lib.mkDefault "t";
        };
      };

      sly-repl-ansi-color = {
        enable = true;
        defer = true;
        init = "(add-to-list 'sly-contribs 'sly-repl-ansi-color)";
      };

      sly-stepper = {
        enable = true;
        defer = true;
        init = "(add-to-list 'sly-contribs 'sly-stepper)";
      };
    };
  };
}
