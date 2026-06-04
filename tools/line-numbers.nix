{
  lib,
  config,
  ...
}:

let
  tools = config.programs.emacs.init.tools;
in
{
  options.programs.emacs.init.tools.lineNumbers.enable =
    lib.mkEnableOption "Enables line numbers. Borrowed from Emacs from Scratch.";

  config.programs.emacs.init.usePackage.display-line-numbers = lib.mkIf tools.lineNumbers.enable {
    enable = true;
    setopt.display-line-numbers-width = 3;
    config = "(global-display-line-numbers-mode)";
    #Disable line numbers for some modes
    ghookf = [
      "('(org-mode term-mode dired-mode eww-mode eat-mode markdown-mode help-mode helpful-mode Info-mode Man-mode shell-mode pdf-view-mode elfeed-search-mode elfeed-show-mode eshell-mode racket-repl-mode sage-shell-mode nov-mode) (lambda () (display-line-numbers-mode 0)))"
    ];
  };
}
