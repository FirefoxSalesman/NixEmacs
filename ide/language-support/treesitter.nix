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
  options.programs.emacs.init.ide.treesitter = {
    wantTreesitter = lib.mkEnableOption "Enables the treesitter module";
    treesitterGrammars = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Grammars for treesit-auto to install.";
    };
  };

  config =
    lib.mkIf
      (
        config.programs.emacs.init.ide.treesitter.wantTreesitter
        || config.programs.emacs.init.ide.symex
        || (config.programs.emacs.init.treesitter.treesitterGrammars != { })
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
            setopt.treesit-auto-install = "'prompt";
            init = "(mp-setup-install-grammars)";
            config = "(global-treesit-auto-mode)";
            # stolen from mickey petersen
            preface = ''

              (defun nix-emacs/treesit-node-at-point-equals (type)
                "Return t if the type of the node at point is TYPE."
                (equal (treesit-node-type (treesit-node-at (marker-last-position (point-marker))))
              	 type))

              (defun nix-emacs/treesit-on-last-node-line? ()
                "Return t if point is on the last line of the current node."
                (equal (line-number-at-pos (marker-last-position (point-marker)))
              	 (line-number-at-pos (treesit-node-end
              			      (treesit-node-at
              			       (marker-last-position (point-marker)))))))

              (defun nix-emacs/in-node (type)
                "Return t if the point is inside a TYPE node."
                (and (nix-emacs/treesit-node-at-point-equals type)
                     (not (nix-emacs/treesit-on-last-node-line?))))

              (defun mp-setup-install-grammars ()
              "Install Tree-sitter grammars if they are absent."
              (interactive)
              (dolist (grammar
                '(${makeGrammars config.programs.emacs.init.ide.treesitter.treesitterGrammars}))
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
