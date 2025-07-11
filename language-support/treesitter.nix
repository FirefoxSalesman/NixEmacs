{ pkgs, lib, config, ... } :

let
  lang = config.programs.emacs.init.ide.languages;
in
{
  config = lib.mkIf (lang.python.enable || lang.hy.enable || lang.java.enable || lang.gradle.enable || lang.clojure.enable || lang.scala.enable || lang.kotlin.enable || lang.nix.enable || lang.web.enable || lang.pug.enable || lang.javascript.enable || lang.typescript.enable || lang.json.enable || lang.toml.enable || lang.haskell.enable || lang.c.enable || lang.bash.enable || lang.r.enable || lang.prolog.enable || lang.zenscript.enable || lang.rust.enable || lang.lua.enable || lang.fennel.enable || lang.plantuml.enable || lang.erlang.enable || lang.sql.enable || lang.forth.enable || lang.go.enable || lang.markdown.enable || lang.zig.enable || lang.latex.enable || lang.csharp.enable || lang.ruby.enable || lang.common-lisp.enable || lang.scheme.enable || lang.racket.enable || lang.xml.enable) {
    programs.emacs.init.usePackage = {
      treesit-auto = {
        enable = true;
        custom.treesit-auto-install = "'prompt";
        init = "(mp-setup-install-grammars)";
        config = "(global-treesit-auto-mode)";
        # stolen from mickey petersen
        extraConfig = ''
        :preface (defun mp-setup-install-grammars ()
                "Install Tree-sitter grammars if they are absent."
                (interactive)
                (dolist (grammar
                         '(;(xml "https://github.com/ObserverOfTime/tree-sitter-xml")
                           (kotlin "https://github.com/fwcd/tree-sitter-kotlin")
                           (haskell "https://github.com/tree-sitter/tree-sitter-haskell")
                           (toml "https://github.com/ikatyang/tree-sitter-toml")
                           (json5 "https://github.com/Joakker/tree-sitter-json5")
                           (elisp "https://github.com/Wilfred/tree-sitter-elisp")))
                  (add-to-list 'treesit-language-source-alist grammar)
                  ;; Only install `grammar' if we don't already have it
                  ;; installed. However, if you want to *update* a grammar then
                  ;; this obviously prevents that from happening.
                  (unless (treesit-language-available-p (car grammar))
                    (treesit-install-language-grammar (car grammar)))))
  '';
      };

      tree-sitter = {
        enable = true;
        afterCall = ["on-first-file-hook"];
        config = ''
        (global-tree-sitter-mode)
        (dolist (mode '((java-ts-mode . java)
          (kotlin-ts-mode . kotlin)
          (html-ts-mode . html)
		      (lua-ts-mode . lua)
		      (go-ts-mode . go)
		      (python-ts-mode . python)
		      (scala-ts-mode . scala)
		      (js-ts-mode . javascript)
		      (typescript-ts-mode . typescript)
		      ;;(haskell-ts-mode . haskell)
		      (json-ts-mode . json)
		      (gfm-mode . markdown)
		      (ruby-ts-mode . ruby)
		      (csharp-ts-mode . c-sharp)
		      (rust-ts-mode . rust)
		      (css-ts-mode . css)
		      (c-ts-mode . c)
		      (racket-repl-mode . racket)
		      (ess-r-mode . r)
		      (inferior-ess-r-mode . r)
		      (erlang-ts-mode . erlang)
          (toml-ts-mode . toml)
		      (julia-ts-mode . julia)))
        (add-to-list 'tree-sitter-major-mode-language-alist mode))
      '';
      };

      tree-sitter-langs = {
        enable = true;
        custom.tree-sitter-langs-grammar-dir = ''"~/.cache/emacs/tree-sitter"'';
        afterCall = ["global-tree-sitter-mode-hook"];
      };
    };
  };
}
