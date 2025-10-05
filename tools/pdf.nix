{ pkgs, config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.tools.pdf = lib.mkEnableOption "Enables pdf-tools.";

  config.programs.emacs.init.usePackage.pdf-tools = lib.mkIf config.programs.emacs.init.tools.pdf {
    enable = true;
    defer = true;
    setopt = lib.mkIf ide.languages.latex.enable {
      # Makes PDFtools the default
      TeX-view-program-selection = lib.mkDefault ['''(output-pdf "PDF Tools")''];
      TeX-view-program-list = lib.mkDefault ['''("PDF Tools" TeX-pdf-tools-sync-view)''];
      TeX-source-correlate-start-server = lib.mkDefault false;
    };
    # Not actually sure if we need this
    config = ''
      (pdf-tools-install)
    '';
    init = ''
      (setq-default pdf-view-display-size 'fit-width)
      ${if ide.languages.latex.enable then "(with-eval-after-load 'latex (add-hook 'TeX-after-compilation-finished-functions #'TeX-revert-document-buffer))" else ""}
    '';
    magic = [''("%PDF" . pdf-view-mode)''];
  };
}
