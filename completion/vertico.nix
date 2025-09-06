{ pkgs, lib, config, ... }:

let
  completions = config.programs.emacs.init.completions;
  keybinds = config.programs.emacs.init.keybinds;
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.completions.vertico = {
    enable = lib.mkEnableOption "Enables vertico as a completion system. Many things are borrowed from Doom";
    embark = lib.mkEnableOption "Enables embark's completion actions. Borrowed from Karthink, the embark wiki, & Doom";
    evilConsultLine = lib.mkEnableOption "Evil's / runs consult-line. Borrowed from Noctuid's config. Only works with orderless";
  };

  config.programs.emacs.init = lib.mkIf completions.vertico.enable {
    hasOn = true;
    usePackage = {
      vertico = {
        enable = true;
        hook = ["(on-first-input . vertico-mode)"];
        custom.vertico-cycle = true;
        generalTwo.":n".vertico-map = lib.mkIf keybinds.evil.enable {
          "RET" = "'vertico-exit";
          "${keybinds.evil.keys.down}" = "'vertico-next";
          "${keybinds.evil.keys.up}" = "'vertico-previous";
        };
      };

      vertico-quick = lib.mkIf keybinds.avy.enable {
        enable = true;
        generalTwo.":n".vertico-map = lib.mkIf keybinds.evil.enable {
          "${keybinds.avy.evilModifierKey}-${keybinds.evil.keys.down}" = "'vertico-quick-jump";
          "${keybinds.avy.evilModifierKey}-${keybinds.evil.keys.up}" = "'vertico-quick-jump";
        };
        bindLocal.vertico-map."M-g f" = lib.mkIf (!keybinds.evil.enable) "vertico-quick-jump";
      };
      
      marginalia = {
        enable = true;
        hook = ["(on-first-input . marginalia-mode)"];
      };

      consult = {
        enable = true;
        defer = true;
        extraPackages = with pkgs; [
          fd
          ripgrep
        ];
        custom = {
          consult-line-numbers-widen = true;
          consult-async-min-input = "2";
          consult-async-refresh-delay = "0.15";
          consult-async-input-throttle = "0.2";
          consult-async-input-debounce = "0.1";
        };
        bindLocal = {
          help-map = {
            "C-a" = lib.mkDefault "consult-apropos";
            "i" = lib.mkDefault "consult-info";
            "M" = lib.mkDefault "consult-man";
          };
          ctl-x-map = {
            "M-:" = lib.mkDefault "consult-complex-command";
            "b" = lib.mkDefault "consult-buffer";
            "C-r" = lib.mkDefault "consult-recent-file";
            "t b" = lib.mkDefault "consult-buffer-other-tab";
          };
          ctl-x-5-map."b" = lib.mkDefault "consult-buffer-other-frame";
          ctl-x-4-map."b" = lib.mkDefault "consult-buffer-other-window";
          ctl-x-r-map."b" = lib.mkDefault "consult-bookmark";
          project-prefix-map."b" = lib.mkDefault "consult-project-buffer";
          mode-specific-map = {
            "m" = lib.mkDefault "consult-mode-command";
            "k" = lib.mkDefault "consult-kmacro";
          };
          goto-map = {
            "e" = lib.mkDefault "consult-compile-error";
            "r" = lib.mkDefault "consult-grep-match";
            "f" = lib.mkIf (!ide.flycheck.enable) (lib.mkDefault "consult-flymake");
            "g" = lib.mkDefault "consult-goto-line";
            "M-g" = lib.mkDefault "consult-goto-line";
            "o" = lib.mkDefault "consult-outline";
            "m" = lib.mkDefault (if keybinds.evil.enable then "evil-collection-consult-mark" else "consult-mark");
            "k" = lib.mkDefault (if keybinds.evil.enable then "evil-collection-consult-jump-list" else "consult-global-mark");
            "i" = lib.mkDefault "consult-imenu";
            "I" = lib.mkDefault "consult-imenu-multi";
          };
          search-map = {
            "d" = lib.mkDefault "consult-fd";
            "c" = lib.mkDefault "consult-locate";
            "g" = lib.mkDefault "consult-ripgrep";
            "G" = lib.mkDefault "consult-git-grep";
            "l" = lib.mkDefault "consult-line";
            "L" = lib.mkDefault "consult-line-multi";
            "k" = lib.mkDefault "consult-keep-lines";
            "e" = lib.mkDefault "consult-isearch-history";
            "u" = lib.mkDefault "consult-focus-lines";
          };
        };
        generalOne = {
          ":nmvo" = lib.mkIf (completions.vertico.evilConsultLine && completions.orderless) {
            "/" = lib.mkDefault "'consult-line";
            "?" = lib.mkDefault "'consult-line-multi";
          };
          global-leader = lib.mkIf keybinds.leader-key.enable {
            "b" = lib.mkDefault "'consult-bookmark";
            "i" = lib.mkDefault "'consult-imenu";
            "I" = lib.mkDefault "'consult-imenu-multi";
          };
        };
        generalTwo.local-leader = {
          org-mode-map."o" = lib.mkIf ide.languages.org.enable (lib.mkDefault '''(consult-org-heading :which-key "outline")'');
          markdown-mode-map."o" = lib.mkIf ide.languages.markdown.enable (lib.mkDefault '''(consult-outline :which-key "go to heading")'');
        };
        bind = {
          "M-#" = lib.mkDefault "consult-register-load";
          "M-'" = lib.mkDefault "consult-register-store";
          "C-M-#" = lib.mkDefault "consult-register";
          "M-y" = lib.mkDefault "consult-yank-pop";
        };
        custom.xref-show-xrefs-function = "#'consult-xref";
        config = lib.mkIf (keybinds.evil.enable && completions.orderless) ''
          (defun nix-emacs-save-search-history (pattern)
            "Gets history from pattern, & saves it where evil mode can find it"
            (add-to-history 'evil-search-forward-history pattern)
            (add-to-history 'search-ring pattern)
            (add-to-history 'regexp-search-ring pattern)
            (setq evil-ex-search-pattern (list pattern t t))
            (setq evil-ex-search-direction 'forward)
            (when evil-ex-search-persistent-highlight
              (evil-ex-search-activate-highlight evil-ex-search-pattern)))
          
          (defun noct-consult-line-evil-history (&rest _)
            "Add latest `consult-line' search pattern to the evil search history ring.
            This only works with orderless and for the first component of the search."
            (when (and (bound-and-true-p evil-mode)
                       (eq evil-search-module 'isearch))
              (nix-emacs-save-search-history (cadr (orderless-compile
  				              (car consult--line-history))))))
          
          (general-add-advice #'consult-line :after #'noct-consult-line-evil-history)
        '';
      };

      consult-flycheck = lib.mkIf ide.flycheck.enable {
        enable = true;
        bindLocal.goto-map."f" = lib.mkDefault "consult-flycheck";
      };

      consult-dir = {
        enable = true;
        config = "(add-to-list 'consult-dir-sources 'consult-dir--source-tramp-ssh t)";
        custom.consult-dir-project-list-function = lib.mkIf ide.projectile (lib.mkDefault "#'consult-dir-projectile-dirs");
        bindLocal.vertico-map = {
          "C-x C-d" = "consult-dir";
          "C-x C-j" = "consult-dir-jump-file";
        };
      };

      vertico-prescient = lib.mkIf completions.prescient {
        enable = true;
        hook = ["(minibuffer-mode . vertico-prescient-mode)"];
        custom = {
          vertico-prescient-enable-filtering = false;
          vertico-prescient-completion-styles = lib.mkDefault (if completions.orderless then "'(orderless prescient basic)" else "'(prescient basic)");
          vertico-prescient-enable-sorting = true;
        };
      };

      embark = lib.mkIf completions.vertico.embark {
        enable = true;
        command = ["embark-act"];
        bind."C-;" = "'embark-dwim";
        defer = true;
        bindLocal = {
          help-map."b" = "embark-bindings"; 
          minibuffer-local-map."C-;" = "embark-act";
        };
        generalTwo = lib.mkIf keybinds.evil.enable {
          ":nm".embark-collect-mode-map."q" = "'evil-record-macro";
          ":n".vertico-map.":" = "'embark-act";
        };
        custom = {
          # Replace key help with a completing-read interface
          prefix-help-command = "#'embark-prefix-help-command";
          which-key-use-C-h-commands = lib.mkIf keybinds.whichKey.enable false;
          embark-indicators = lib.mkIf keybinds.whichKey.enable ''
              '(embark-which-key-indicator
                embark-highlight-indicator
                embark-isearch-highlight-indicator)
            '';
        };
        init = lib.mkIf keybinds.whichKey.enable ''
          (defun embark-which-key-indicator ()
            "An embark indicator that displays keymaps using which-key.
                The which-key help message will show the type and value of the
                current target followed by an ellipsis if there are further
                targets."
            (lambda (&optional keymap targets prefix)
              (if (null keymap)
                  (which-key--hide-popup-ignore-command)
                (which-key--show-keymap
                 (if (eq (plist-get (car targets) :type) 'embark-become)
                     "Become"
                   (format "Act on %s '%s'%s"
                           (plist-get (car targets) :type)
                           (embark--truncate-target (plist-get (car targets) :target))
                           (if (cdr targets) "…" "")))
                 (if prefix
                     (pcase (lookup-key keymap prefix 'accept-default)
                       ((and (pred keymapp) km) km)
                       (_ (key-binding prefix 'accept-default)))
                   keymap)
                 nil nil t (lambda (binding)
                             (not (string-suffix-p "-argument" (cdr binding))))))))
          
          (defun embark-hide-which-key-indicator (fn &rest args)
            "Hide the which-key indicator immediately when using the completing-read prompter."
            (which-key--hide-popup-ignore-command)
            (let ((embark-indicators
                   (remq #'embark-which-key-indicator embark-indicators)))
              (apply fn args)))
          
          (advice-add #'embark-completing-read-prompter
                      :around #'embark-hide-which-key-indicator)
        '';
      };
      
      embark-consult = lib.mkIf completions.vertico.embark {
        enable = true;
        after = ["embark" "consult"];
        hook = ["(embark-collect-mode . consult-preview-at-point-mode)"];
      };

      consult-eglot = lib.mkIf ide.eglot.enable {
        enable = true;
        after = ["eglot"];
        bindLocal.eglot-mode-map."C-M-." = "consult-eglot-symbols" ;
      };
      
      consult-lsp = lib.mkIf ide.lsp.enable {
        enable = true;
        after = ["lsp-mode"];
        bindLocal.lsp-mode-map."C-M-." = "consult-lsp-symbols" ;
      };
    };
  };
}
