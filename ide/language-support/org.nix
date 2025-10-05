{ config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
  keybinds = config.programs.emacs.init.keybinds;
in
{
  options.programs.emacs.init.ide.languages.org = {
    enable = lib.mkEnableOption "Enables support for org mode. Borrows a great deal from emacs from scratch & doom emacs";
    aesthetics = {
      enable = lib.mkEnableOption "Enables org-modern & org-modern indent";
      headerFont = lib.mkOption {
        type = lib.types.str;
        default = "Liberation Serif";
        description = "The font to use for org headers. Defaults to Liberation Serif, since that's on most machines & I don't know what I'm doing";
      };
    };
    captureTemplates = {
      enable = lib.mkEnableOption "Enables doom's org-capture templates";
      todoFile = lib.mkOption {
        type = lib.types.str;
        default = "tasks.org";
        description = "The file in your org-directory to put todo entries for your agenda in";
      };
      notesFile = lib.mkOption {
        type = lib.types.str;
        default = "notes.org";
        description = "The file in your org-directory to put your notes in";
      };
      journalFile = lib.mkOption {
        type = lib.types.str;
        default = "journal.org";
        description = "The file in your org-directory to put your journal entries in";
      };
    };
  };

  config = lib.mkIf ide.languages.org.enable {
    programs.emacs.init = {
      ide.treesitter.treesitterGrammars."org" =
        lib.mkIf ide.symex "https://github.com/emiasims/tree-sitter-org";
      usePackage = {
        org = {
          enable = true;
          mode = [ ''("\\.org\\'" . org-mode)'' ];
          symex = ide.symex;
          deferIncrementally = [
            "calendar"
            "find-func"
            "format-spec"
            "org-macs"
            "org-compat"
            "org-faces"
            "org-entities"
            "org-list"
            "org-pcomplete"
            "org-src"
            "org-footnote"
            "org-macro"
            "ob"
            "org"
            "org-agenda"
            "org-capture"
          ];
          babel = "org";
          setopt = {
            org-confirm-babel-evaluate = lib.mkDefault false;
            org-src-fontify-natively = lib.mkDefault true;
            org-src-tab-acts-natively = lib.mkDefault true;
            org-log-done = lib.mkDefault false;
            org-log-into-drawer = lib.mkDefault true;
            org-hide-emphasis-markers = lib.mkIf ide.languages.org.aesthetics.enable (lib.mkDefault true);
            org-ellipsis = lib.mkIf ide.languages.org.aesthetics.enable (lib.mkDefault ''" ▾"'');

            # Settings from doom
            org-indirect-buffer-display = lib.mkDefault "'current-window";
            org-enforce-todo-dependencies = lib.mkDefault true;
            org-imenu-depth = lib.mkDefault 6;
            org-tags-column = lib.mkDefault 0;
            org-startup-folded = lib.mkDefault false;
            org-agenda-inhibit-startup = lib.mkDefault true;
            org-agenda-window-setup = lib.mkDefault "'current-window";
            org-agenda-skip-unavailable-files = lib.mkDefault true;
            org-agenda-span = lib.mkDefault 10;
            org-agenda-start-on-weekday = lib.mkDefault false;
            org-agenda-start-day = lib.mkDefault ''"-3d"'';
            org-refile-targets = lib.mkDefault ''
              '((nil :maxlevel . 3)
                (org-agenda-files :maxlevel . 3))
            '';
            org-refile-use-outline-path = lib.mkDefault "'file";
            org-outline-path-complete-in-steps = lib.mkDefault false;
            org-src-preserve-indentation = lib.mkDefault true;
            org-link-elisp-confirm-function = lib.mkDefault false;
            org-src-window-setup = lib.mkDefault "'other-window";
            org-babel-lisp-eval-fn = lib.mkIf ide.languages.common-lisp.enable (lib.mkDefault "#'sly-eval");
            org-modules = lib.mkDefault "'(ol-bibtex)";
            org-agenda-files = lib.mkIf ide.languages.org.captureTemplates.enable (
              lib.mkDefault ''(list (expand-file-name "${ide.languages.org.captureTemplates.todoFile}" org-directory))''
            );
            org-default-notes-file = lib.mkIf ide.languages.org.captureTemplates.enable (
              lib.mkDefault ''(expand-file-name "${ide.languages.org.captureTemplates.notesFile}" org-directory)''
            );
            # borrowed from doom
            org-capture-bookmark = lib.mkIf ide.languages.org.captureTemplates.enable (lib.mkDefault false);
            org-capture-templates = lib.mkIf ide.languages.org.captureTemplates.enable (
              lib.mkDefault ''
                '(("t" "Personal todo" entry
                   (file org-default-todo-file)
                   "* TODO [ ] %?\n%i\n%a" :prepend t)
                  ("n" "Personal notes" entry
                   (file org-default-notes-file)
                   "* %u %?\n%i\n%a" :prepend t)
                  ("j" "Journal" entry
                   (file+olp+datetree org-default-journal-file)
                   "* %U %?\n%i\n%a" :prepend t)

                  ;; Will use {project-root}/{todo,notes,changelog}.org, unless a
                  ;; {todo,notes,changelog}.org file is found in a parent directory.
                  ;; Uses the basename from `+org-capture-todo-file',
                  ;; `+org-capture-changelog-file' and `+org-capture-notes-file'.
                  ("p" "Templates for projects")
                  ("pt" "Project-local todo" entry ; {project-root}/todo.org
                   (file nix-emacs-project-todo)
                   "* TODO %?\n%i\n%a" :prepend t)
                  ("pn" "Project-local notes" entry ; {project-root}/notes.org
                   (file nix-emacs-project-notes)
                   "* %U %?\n%i\n%a" :prepend t)
                  ("pc" "Project-local changelog" entry  ; {project-root}/changelog.org
                   (file+headline nix-emacs-project-changelog "Unreleased")
                   "* %U %?\n%i\n%a" :prepend t))
              ''
            );
          };
          generalOne.global-leader = lib.mkIf keybinds.leader-key.enable {
            "o" = lib.mkDefault '''(:ignore t :which-key "org")'';
            "op" = lib.mkDefault "'org-capture";
          };
          generalTwoConfig.local-leader.org-mode-map = lib.mkIf keybinds.leader-key.enable {
            "e" = lib.mkDefault '''(org-export-dispatch :which-key "export")'';
            "i" = lib.mkDefault '''(org-toggle-inline-images :which-key "show images")'';
            "b" = lib.mkDefault '''(org-edit-special :which-key "edit block")'';
          };
          hook = [ "(org-mode . org-indent-mode)" ];
          gfhookf = lib.mkIf ide.symex [ "('org-mode (treesit! 'org))" ];
          init = ''
            (defun nix-emacs-project-file (file)
              "Retrieves file from the root of the current project."
              (expand-file-name file (project-root (project-current))))
            (defun nix-emacs-project-todo ()
              "Retrieves the project's todo.org file. Borrowed from doom emacs"
              (nix-emacs-project-file "todo.org"))
            (defun nix-emacs-project-notes ()
              "Retrieves the project's notes.org file. Borrowed from doom emacs"
              (nix-emacs-project-file "notes.org"))
            (defun nix-emacs-project-changelog ()
              "Retrieves the project's changelog.org file. Borrowed from doom emacs"
              (nix-emacs-project-file "changelog.org"))
          '';
          config = ''
            (defvar org-default-todo-file (expand-file-name "${ide.languages.org.captureTemplates.todoFile}" org-directory))
            (defvar org-default-journal-file (expand-file-name "${ide.languages.org.captureTemplates.journalFile}" org-directory))
            (push '("conf-unix" . conf-unix) org-src-lang-modes)
            ;; borrowed from doom
            (plist-put org-format-latex-options :scale 1.5)
          '';
        };

        org-appear = lib.mkIf ide.languages.org.aesthetics.enable {
          enable = true;
          hook = [ "(org-mode . org-appear-mode)" ];
        };

        org-contrib = lib.mkIf ide.hoverDoc {
          enable = true;
          config = ''(ox-extras-activate '(ignore-headlines))'';
          deferIncrementally = [ "ox-extra" ];
        };

        org-modern = lib.mkIf ide.languages.org.aesthetics.enable {
          enable = true;
          ghookf = [
            "('org-mode '(org-modern-mode org-toggle-pretty-entities variable-pitch-mode visual-line-mode nix-emacs-org-font-setup))"
          ];
          setopt = {
            org-modern-star = "'replace";
            org-modern-hide-stars = "'leading";
          };
          init = ''
            (defun nix-emacs-org-font-setup ()
              "Sets up org fonts. Originates from Emacs from Scratch."
              ;;Set faces for heading levels
              (dolist (face '((org-document-title . 1.4)
                              (org-level-1 . 1.4)
                              (org-level-2 . 1.3)
                              (org-level-3 . 1.2)
                              (org-level-4 . 1.1)
                              (org-level-5 . 1.05)
                              (org-level-6 . 1.05)
                              (org-level-7 . 1.05)
                              (org-level-8 . 1.05)))
                      (set-face-attribute (car face) nil :font "${ide.languages.org.aesthetics.headerFont}" :weight 'regular :height (cdr face)))

              ;; Ensure that anything that should be fixed-pitch in Org files appears that way
              (dolist (face (list 'org-block 'org-table 'org-formula 'org-checkbox 'line-number 'line-number-current-line))
                (set-face-attribute face nil :inherit 'fixed-pitch))
              (dolist (face (list 'org-code 'org-table 'org-verbatim))
                (set-face-attribute face nil :inherit '(shadow fixed-pitch)))
              (dolist (face (list 'org-special-keyword 'org-meta-line))
                (set-face-attribute face nil :inherit '(font-lock-comment-face fixed-pitch))))
          '';
        };

        eldoc-box = lib.mkIf ide.hoverDoc {
          enable = true;
          hook = [ "(org-mode . eldoc-box-hover-mode)" ];
        };

        org-modern-indent = lib.mkIf ide.languages.org.aesthetics.enable {
          enable = true;
          afterCall = [ "org-mode-hook" ];
          config = ''(add-hook 'org-mode-hook 'org-modern-indent-mode 90)'';
        };

        evil-org = lib.mkIf config.programs.emacs.init.keybinds.evil.enable {
          enable = true;
          setopt.evil-org-movement-bindings = ''
            '((up . "${keybinds.evil.keys.up}")
              (down . "${keybinds.evil.keys.down}")
              (left . "${keybinds.evil.keys.backward}")
              (right . "${keybinds.evil.keys.forward}"))
          '';
          ghookf = [ "('org-mode 'evil-org-mode)" ];
          gfhookf = [ "('org-capture-mode 'evil-insert-state)" ];
          # stolen from doom
          generalTwoConfig.":n".org-mode-map = {
            "]h" = '''(org-forward-heading-same-level :which-key "next heading")'';
            "[h" = '''(org-backward-heading-same-level :which-key "prev heading")'';
            "]c" = '''(org-babel-next-src-block :which-key "next src block")'';
            "[c" = '''(org-babel-previous-src-block :which-key "prev src block")'';
            "]l" = '''(org-next-link :which-key "next link")'';
            "[l" = '''(org-previous-link :which-key "prev link")'';
          };
          init = ''
            (add-to-list 'evil-fold-list
                         `((org-mode)
                           :open org-cycle
                           :open-all nil
                           :close org-cycle
                           :close-all nil
                           :toggle org-cycle
                           :delete nil
                           :open-rec nil))        
          '';
          config = ''
            (with-eval-after-load 'evil-collection
              (when (equal evil-collection-unimpaired-want-repeat-mode-integration t)
                (evil-collection-unimpaired-defvar-keymap org-forward-heading-same-level-repeat-map
                  "h" #'org-forward-heading-same-level
                  "H" #'org-backward-heading-same-level)
                (evil-collection-unimpaired-defvar-keymap org-backward-heading-same-level-repeat-map
                  "h" #'org-backward-heading-same-level
                  "H" #'org-forward-heading-same-level)
                (evil-collection-unimpaired-defvar-keymap org-babel-next-src-block-repeat-map
                  "c" #'org-babel-next-src-block
                  "C" #'org-babel-previous-src-block)
                (evil-collection-unimpaired-defvar-keymap org-babel-previous-src-block-repeat-map
                  "c" #'org-babel-previous-src-block
                  "C" #'org-babel-next-src-block)
                (evil-collection-unimpaired-defvar-keymap org-next-link-repeat-map
                  "l" #'org-next-link
                  "L" #'org-previous-link)
                (evil-collection-unimpaired-defvar-keymap org-previous-link-repeat-map
                  "l" #'org-previous-link
                  "L" #'org-next-link)
                (dolist (cmd '(org-forward-heading-same-level
                               org-backward-heading-same-level
                               org-babel-next-src-block
                               org-babel-previous-src-block
                               org-next-link
                               org-previous-link))
                        (put cmd 'repeat-map (intern (format "%s-repeat-map" cmd))))))
          '';
        };

        evil-org-agenda = lib.mkIf keybinds.evil.enable {
          enable = true;
          config = ''(evil-org-agenda-set-keys)'';
          deferIncrementally = true;
          generalOne.global-leader."oa" = lib.mkIf keybinds.leader-key.enable (lib.mkDefault "'org-agenda");
          generalTwoConfig.":m".evil-org-agenda-mode-map = {
            "${keybinds.evil.keys.down}" = "'org-agenda-next-line";
            "${keybinds.evil.keys.up}" = "'org-agenda-previous-line";
            "b${keybinds.evil.keys.down}" = "'org-agenda-previous-item";
            "C-${keybinds.evil.keys.down}" = "'org-agenda-next-item";
            "C-${keybinds.evil.keys.up}" = "'org-agenda-previous-item";
            "S-${keybinds.evil.keys.down}" = "'org-agenda-priority-down";
            "S-${keybinds.evil.keys.up}" = "'org-agenda-priority-up";
            "M-${keybinds.evil.keys.down}" = "'org-agenda-drag-line-forward";
            "M-${keybinds.evil.keys.up}" = "'org-agenda-drag-line-backward";
          };
        };
      };
    };
  };
}
