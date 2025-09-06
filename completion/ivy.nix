{ config, lib, ... }:

let
  completions = config.programs.emacs.init.completions;
  keybinds = config.programs.emacs.init.keybinds;
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.completions.ivy = {
    enable = lib.mkEnableOption "Enables ivy completions. Largely borrowed from doom.";
    swiperReplaceSearch = lib.mkEnableOption "Swiper replaces isearch/evil search. Some configuration stolen from noctuid";
    posframe = lib.mkEnableOption "Ivy uses a posframe for its completions";
  };

  config.programs.emacs.init = lib.mkIf completions.ivy.enable {
    hasOn = true;
    usePackage = {
      ivy = {
        enable = true;
        hook = ["(on-first-input . ivy-mode)"];
        custom = {
          ivy-sort-max-size = lib.mkDefault "7500";
          ivy-height = lib.mkDefault "17";
          ivy-fixed-height-minibuffer = lib.mkDefault (!completions.ivy.posframe);
          ivy-read-action-function = lib.mkDefault "#'ivy-hydra-read-action";
          ivy-read-action-format-function = lib.mkDefault "#'ivy-read-action-format-columns";
          ivy-use-virtual-buffers = lib.mkDefault false;
          ivy-virtual-abbreviate = lib.mkDefault "'full";
          ivy-on-del-error-function = lib.mkDefault "#'ignore";
          ivy-use-selectable-prompt = lib.mkDefault true;
        };
        generalOne.":nm".":" = lib.mkIf (keybinds.evil.enable && !completions.ivy.posframe) (lib.mkDefault "'ivy-posframe-dispatching-done");
      };

      ivy-rich = {
        enable = true;
        after = ["ivy"];
        custom = {
          ivy-rich-parse-remote-buffer = lib.mkDefault false;
          ivy-rich-switch-buffer-faces-alist = lib.mkDefault false;
        };
        config = ''
          (ivy-set-display-transformer 'internal-complete-buffer nil)
          (ivy-rich-mode 1)
          (ivy-rich-project-root-cache-mode 1)
        '';
      };

      counsel = {
        enable = true;
        after = ["ivy"];
        bindLocal = {
          help-map = {
            "C-a" = lib.mkDefault "counsel-apropos";
            "b" = lib.mkDefault "counsel-descbinds";
            "F" = lib.mkDefault "counsel-faces";
            "f" = lib.mkDefault "counsel-describe-function";
            "v" = lib.mkDefault "counsel-describe-variable";
            "s" = lib.mkDefault "counsel-describe-symbol";
            "i" = lib.mkDefault "counsel-info-lookup-symbol";
          };
          ctl-x-r-map."b" = lib.mkDefault "counsel-bookmark";
          ctl-x-map = {
            "C-f" = lib.mkDefault "counsel-find-file";
            "8 RET" = lib.mkDefault "counsel-unicode-char";
          };
          goto-map = {
            "i" = lib.mkDefault "counsel-imenu";
          };
          search-map = {
            "c" = lib.mkDefault "counsel-locate";
          };
          org-mode-map = {
            "C-c C-j" = lib.mkDefault "counsel-org-goto";
            "C-c C-q" = lib.mkDefault "counsel-org-tag";
          };
        };
        bind = {
          "M-x" = lib.mkDefault "counsel-M-x";
          "C-s" = lib.mkIf completions.ivy.swiperReplaceSearch (lib.mkDefault "counsel-grep-or-swiper");
          "M-y" = lib.mkDefault "counsel-yank-pop";
        };
        generalOne = {
          global-leader = lib.mkIf keybinds.leader-key.enable {
            "f" = lib.mkDefault "'counsel-find-file";
            "i" = lib.mkDefault "'counsel-imenu";
          };
          ":nm" = lib.mkIf (completions.ivy.swiperReplaceSearch && keybinds.evil.enable) {
            "/" = lib.mkDefault "'counsel-grep-or-swiper";
            "?" = lib.mkDefault "'counsel-grep-or-swiper";
          };
        };
        custom = {
          counsel-find-file-ignore-regexp = lib.mkDefault ''"\\(?:^[#.]\\)\\|\\(?:[#~]$\\)\\|\\(?:^Icon?\\)"'';
        };
        config = ''
          (setq ivy-initial-inputs-alist nil)
          ${if ide.projectile then "(add-to-list 'counsel-compile-root-functions #'projectile-project-root)" else ""}
          (dolist (fn '(counsel-rg counsel-find-file))
            (ivy-add-actions
             fn '(("p" (lambda (path) (with-ivy-window (insert (file-relative-name path default-directory))))
             "insert relative path")
             ("P" (lambda (path) (with-ivy-window (insert path)))
              "insert absolute path")
             ("l" (lambda (path) (with-ivy-window (insert (format "[[./%s]]" (file-relative-name path default-directory)))))
              "insert relative org-link")
             ("L" (lambda (path) (with-ivy-window (insert (format "[[%s]]" path))))
              "Insert absolute org-link"))))
          (ivy-add-actions 'counsel-file-jump (plist-get ivy--actions-list 'counsel-find-file))
          
          ${if completions.ivy.swiperReplaceSearch && keybinds.evil.enable then
               ''(defun nix-emacs-add-ivy-text-to-history ()
                   "Add the last ivy search to `regexp-search-ring'."
                   (add-to-history
                    'regexp-search-ring
                    (ivy--regex ivy-text)
                    regexp-search-ring-max))
               
                 (defun nix-emacs-evil-search-action ()
                   "Update evil search information based on last ivy search."
                   (when (and (bound-and-true-p evil-mode)
                              (eq evil-search-module 'evil-search))
                     (add-to-history 'evil-ex-search-history ivy-text)
                     (setq evil-ex-search-pattern (list ivy-text t t))
                     (setq evil-ex-search-direction 'forward)
                     (when evil-ex-search-persistent-highlight
                       (evil-ex-search-activate-highlight evil-ex-search-pattern))))
               
               
                 (general-add-hook 'counsel-grep-post-action-hook (list
                                                                   #'nix-emacs-match-beginning
                                                                   #'nix-emacs-add-ivy-text-to-history
                                                                   #'nix-emacs-evil-search-action))''
               else ""}
        '';
      };

      ivy-prescient = lib.mkIf completions.prescient {
        enable = true;
        hook = ["(ivy-mode . ivy-prescient-mode)"];
      };

      ivy-posframe = lib.mkIf completions.ivy.posframe {
        enable = true;
        hook = ["(ivy-mode . ivy-posframe-mode)"];
        custom = {
          ivy-posframe-border-width = lib.mkDefault "10";
          ivy-posframe-parameters = lib.mkDefault ''
            `((min-width . 90)
              (min-height . ,ivy-height))
          '';
        };
        generalOne.":nm".":" = lib.mkIf keybinds.evil.enable (lib.mkDefault "'ivy-posframe-dispatching-done");
      };

      counsel-projectile = lib.mkIf ide.projectile {
        enable = true;
        after = ["projectile"];
        config = ''
          (define-key [remap projectile-find-file] #'counsel-projectile-find-file)
          (define-key [remap projectile-find-dir] #'counsel-projectile-find-dir)
          (define-key [remap projectile-switch-to-buffer] #'counsel-projectile-switch-to-buffer)
          (define-key [remap projectile-grep] #'counsel-projectile-grep)
          (define-key [remap projectile-ag] #'counsel-projectile-ag)
          (define-key [remap projectile-switch-project] #'counsel-projectile-switch-project)
        '';
      };

      ivy-lsp = lib.mkIf ide.lsp.enable {
        enable = true;
        command = ["lsp-ivy-global-workspace-symbol"];
        after = ["lsp-mode"];
        bindLocal.lsp-mode-map."C-M-." = "lsp-ivy-workspace-symbol";
      };

      ivy-avy = lib.mkIf keybinds.avy.enable {
        enable = true;
        bindLocal.ivy-minibuffer-map."M-g f" = lib.mkIf (!keybinds.evil.enable) (lib.mkDefault "ivy-avy");
        generalTwo.":nm".ivy-minibuffer-map = lib.mkIf keybinds.evil.enable {
          "${keybinds.avy.evilModifierKey}-${keybinds.evil.keys.up}" = lib.mkDefault "'ivy-avy";
          "${keybinds.avy.evilModifierKey}-${keybinds.evil.keys.down}" = lib.mkDefault "'ivy-avy";
        };
      };
    };
  };
}
