{ lib, config, ... }:

let
  lang = config.programs.emacs.init.ide.languages;
  makeGrammars =
    vs:
    lib.concatStringsSep "\n" (
      lib.optionals (vs != { }) (lib.mapAttrsToList (n: v: ''(${n} "${v}")'') vs)
    );
in
{
  options.programs.emacs.init.ide.treesitterGrammars = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = { };
    description = "Grammars for treesit-auto to install.";
  };

  config =
    lib.mkIf
      (
        lang.python.enable
        || lang.hy.enable
        || lang.java.enable
        || lang.gradle.enable
        || lang.clojure.enable
        || lang.scala.enable
        || lang.kotlin.enable
        || lang.nix.enable
        || lang.web.enable
        || lang.pug.enable
        || lang.javascript.enable
        || lang.typescript.enable
        || lang.json.enable
        || lang.toml.enable
        || lang.haskell.enable
        || lang.c.enable
        || lang.bash.enable
        || lang.r.enable
        || lang.prolog.enable
        || lang.zenscript.enable
        || lang.rust.enable
        || lang.lua.enable
        || lang.fennel.enable
        || lang.plantuml.enable
        || lang.erlang.enable
        || lang.sql.enable
        || lang.forth.enable
        || lang.go.enable
        || lang.markdown.enable
        || lang.zig.enable
        || lang.latex.enable
        || lang.csharp.enable
        || lang.ruby.enable
        || lang.common-lisp.enable
        || lang.scheme.enable
        || lang.racket.enable
        || lang.xml.enable
        || lang.org.enable
        || lang.vimscript.enable
        || lang.julia.enable
        || lang.emacs-lisp.enable
        || lang.purescript.enable
        || lang.swift.enable
        || lang.svelte.enable
        || lang.org.enable
      )
      {
        programs.emacs.init = {
          prelude = ''
            (defmacro treesit! (lang)
                  "Creates a lanbda that sets up the treesitter parser for lang."
                  `(lambda () (treesit-parser-create ,lang)))
          '';
          usePackage.treesit-auto = {
            enable = true;
            custom.treesit-auto-install = "'prompt";
            init = "(mp-setup-install-grammars)";
            config = "(global-treesit-auto-mode)";
            # stolen from mickey petersen
            preface = ''
              (defun mp-setup-install-grammars ()
              "Install Tree-sitter grammars if they are absent."
              (interactive)
              (dolist (grammar
                '(${makeGrammars config.programs.emacs.init.ide.treesitterGrammars}))
                (add-to-list 'treesit-language-source-alist grammar)
                  ;; Only install `grammar' if we don't already have it
                  ;; installed. However, if you want to *update* a grammar then
                  ;; this obviously prevents that from happening.
                  (unless (treesit-language-available-p (car grammar))
                    (treesit-install-language-grammar (car grammar)))))
            '';
          };
        };
      };
}
