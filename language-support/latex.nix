{ pkgs, config, lib, ... } :

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.latex = {
    enable = lib.mkEnableOption "enables LaTeX support"; 
    magicLatexBuffer = lib.mkEnableOption "use magic-latex-buffer to prettify";
    cdlatex = lib.mkEnableOption "Enable cdlatex in latex and org modes";
    preferTexlab = lib.mkEnableOption "Use texlab instead of digestif";
  };

  config = lib.mkIf ide.languages.latex.enable {
    # Infinitely many thanks to David Wilson for this one
    programs.emacs.init.usePackage = {
      tex = {
        enable = ide.languages.latex.magicLatexBuffer;
        package = epkgs: epkgs.auctex;
        init = lib.mkDefault ''(setq-default TeX-master nil)'';
        custom = {
          reftex-label-alist = lib.mkDefault '''(("\\poemtitle" ?P "poem:" "\\ref{%s}" nil ("poem" "poemtitle")))'';
          reftex-format-cite-function = lib.mkDefault ''
            '(lambda (key fmt)
              (let ((cite (replace-regexp-in-string "%l" key fmt))
                   (if ( or (= ?~ (string-to-char fmt))
                      (member (preceding-char) '(?\ ?\t |/n ?~)))
                       cite
                 (concat "~" cite)))))
          '';
          TeX-auto-save = lib.mkDefault "t";
          TeX-parse-self = lib.mkDefault "t";
          reftex-plug-into-AUCTeX = lib.mkDefault "t";
        };
      };

      bibtex-mode = {
        enable = true;
        mode = [''"\\.bib\\'"''];
        lsp = ide.lsp.enable;
        eglot = ide.eglot.enable;
        symex = ide.symex;
      };

      latex = {
        enable = true;
        package = epkgs: epkgs.auctex;
        extraPackages = if ide.eglot.enable || ide.lsp.enable then
          if ide.languages.latex.preferTexlab then [pkgs.texlab] else [pkgs.texlivePackages.digestif]
                        else [];
        mode = [''("\\.tex\\'" . LaTeX-mode)''];
        symex = ide.symex;
        lsp = ide.lsp.enable;
        eglot = ide.eglot.enable;
      };
      
      magic-latex-buffer = {
        enable = ide.languages.latex.magicLatexBuffer;
        hook = ["(LaTeX-mode . magic-latex-buffer)"];
      };

      cdlatex = {
        enable = ide.languages.latex.cdlatex;
        hook = [
          "('LaTeX-mode . turn-on-cdlatex)"
          "('org-mode . org-cdlatex-mode)"
        ];
      };
    };
  };
}
