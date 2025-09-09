{
  pkgs,
  config,
  lib,
  ...
}:

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
        init = lib.mkDefault "(setq-default TeX-master nil)";
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
          TeX-auto-save = lib.mkDefault true;
          TeX-parse-self = lib.mkDefault true;
          reftex-plug-into-AUCTeX = lib.mkDefault true;
        };
        generalTwo.local-leader.LaTeX-mode-map =
          lib.mkIf config.programs.emacs.init.keybinds.leader-key.enable
            {
              "p" = lib.mkDefault '''(preview-at-point :which-key "preview")'';
              "u" = lib.mkDefault '''(preview-clearout-at-point :which-key "unpreview")'';
            };
      };

      bibtex-mode = {
        enable = true;
        mode = [ ''"\\.bib\\'"'' ];
        lsp = ide.lsp.enable;
        eglot = ide.eglot.enable;
      };

      latex = {
        enable = true;
        package = epkgs: epkgs.auctex;
	hook = ["(LaTeX-mode . (lambda () (treesit-parser-create 'latex)))"];
        extraPackages =
          if ide.eglot.enable || ide.lsp.enable || ide.lspce.enable || ide.lsp-bridge.enable then
            if ide.languages.latex.preferTexlab then [ pkgs.texlab ] else [ pkgs.texlivePackages.digestif ]
          else
            [ ];
        babel = lib.mkIf ide.languages.org.enable "latex";
        mode = [ ''("\\.tex\\'" . LaTeX-mode)'' ];
        lsp = ide.lsp.enable;
        eglot = ide.eglot.enable;
        lspce = lib.mkIf ide.lspce.enable ''
          '("plain-tex" "latex" "context" "texinfo" "bibtex" "tex") "${
            if ide.languages.latex.preferTexlab then "texlab" else "digestif"
          }"
        '';
	symex = ide.symex;
      };

      magic-latex-buffer = {
        enable = ide.languages.latex.magicLatexBuffer;
        hook = [ "(LaTeX-mode . magic-latex-buffer)" ];
      };

      cdlatex = {
        enable = ide.languages.latex.cdlatex;
        hook = [
          "('LaTeX-mode . turn-on-cdlatex)"
          "('org-mode . org-cdlatex-mode)"
        ];
      };

      lsp-bridge.custom.lsp-bridge-tex-lsp-server = lib.mkIf ide.lsp-bridge.enable (
        if ide.languages.latex.preferTexlab then ''"texlab"'' else ''"digestif"''
      );
    };
  };
}
