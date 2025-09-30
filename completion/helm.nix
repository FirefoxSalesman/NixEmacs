{ pkgs, lib, config, ... }:

let
  completions = config.programs.emacs.init.completions;
  keybinds = config.programs.emacs.init.keybinds;
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.completions.helm = {
    enable = lib.mkEnableOption "Enables helm as your completion system. Largely borrowed from doom.";
    fuzzy = lib.mkEnableOption "Enables fuzzy search. Largely borrowed from doom.";
    swiperReplaceSearch = lib.mkEnableOption "Swiper replaces isearch/evil search. Some configuration stolen from noctuid.";
  };

  config.programs.emacs.init = lib.mkIf completions.helm.enable {
    hasOn = true;
    usePackage = {
      helm-mode = {
	enable = true;
	hook = ["(on-first-input . helm-mode)"];
	config = "(add-to-list 'helm-completing-read-handlers-alist (cons #'find-file-at-point nil))";
      };

      helm = {
	enable = true;
	after = ["helm-mode"];
	custom = {
	  helm-candidate-number-limit = lib.mkDefault 150;
	  helm-display-header-line = lib.mkDefault false;
	  helm-ff-auto-update-initial-value = lib.mkDefault false;
	  helm-find-files-doc-header = lib.mkDefault false;
	  helm-display-buffer-default-width = lib.mkDefault false;
	  helm-display-buffer-default-height = lib.mkDefault 0.25;
	  helm-imenu-execute-action-at-once-if-one = lib.mkDefault false;
	  helm-ff-lynx-style-map = lib.mkDefault false;
	  helm-apropos-fuzzy-match = lib.mkDefault completions.helm.fuzzy;
	  helm-bookmark-show-location = lib.mkDefault completions.helm.fuzzy;
	  helm-buffers-fuzzy-matching = lib.mkDefault completions.helm.fuzzy;
	  helm-ff-fuzzy-matching = lib.mkDefault completions.helm.fuzzy;
	  helm-file-cache-fuzzy-match = lib.mkDefault completions.helm.fuzzy;
	  helm-flx-for-helm-locate = lib.mkDefault completions.helm.fuzzy;
	  helm-imenu-fuzzy-match = lib.mkDefault completions.helm.fuzzy;
	  helm-lisp-fuzzy-completion = lib.mkDefault completions.helm.fuzzy;
	  helm-locate-fuzzy-match = lib.mkDefault completions.helm.fuzzy;
	  helm-projectile-fuzzy-match = lib.mkDefault completions.helm.fuzzy;
	  helm-recentf-fuzzy-match = lib.mkDefault completions.helm.fuzzy;
	  helm-semantic-fuzzy-match = lib.mkDefault completions.helm.fuzzy;
	  helm-completion-style = lib.mkDefault "'emacs";
	};
	bindLocal = {
	  help-map = {
	    "C-a" = lib.mkDefault "helm-apropos";
	  };
	  ctl-x-r-map = {
	    "b" = lib.mkDefault "helm-bookmarks";
	  };
	  ctl-x-map = {
	    "C-f" = lib.mkDefault "helm-find-files";
	    "b" = lib.mkDefault "helm-buffers-list";
	  };
	  ibuffer-mode-map = {
	    "C-x C-f" = lib.mkDefault "helm-find-files";
	  };
	  goto-map = {
	    "i" = lib.mkDefault "helm-imenu";
	  };
	};
	bind = {
	  "M-y" = lib.mkDefault "helm-show-kill-ring";
	  "M-x" = lib.mkDefault "helm-M-x";
	};
	config = ''(add-to-list 'completion-styles ${if completions.helm.fuzzy then "'flex" else "'helm"})'';
	generalTwoConfig.":nm".helm-map = lib.mkIf keybinds.evil.enable {
	  "${keybinds.evil.keys.up}" = "'helm-previous-line";
	  "${keybinds.evil.keys.down}" = "'helm-next-line";
	};
      };

      helm-rg = {
	enable = true;
	extraPackages = [pkgs.ripgrep];
	custom.helm-rg-display-buffer-normal-method = lib.mkDefault "#'pop-to-buffer";
	bindLocal = {
	  helm-rg-map."C-c C-e" = lib.mkDefault "helm-rg--bounce";
	  helm-rg--bounce-mode-map = {
	    "q" = lib.mkDefault "kill-current-buffer";
	    "C-c C-c" = lib.mkDefault "(lambda () (interactive) (helm-rg--bounce-dump) (kill-current-buffer))";
	    "C-x C-c" = lib.mkDefault "helm-rg--bounce-dump-current-file";
	    "C-c C-k" = lib.mkDefault "kill-current-buffer";
	  };
	};
      };

      helm-flx = lib.mkIf completions.helm.fuzzy {
	enable = true;
	hook = ["(helm-mode . helm-flx-mode)"];
      };

      swiper-helm = lib.mkIf completions.helm.swiperReplaceSearch {
	enable = true;
	bind."C-s" = lib.mkDefault "swiper-helm";
	generalOne.":nm" = lib.mkIf keybinds.evil.enable {
          "/" = lib.mkDefault "'swiper-helm";
          "?" = lib.mkDefault "'swiper-helm";
        };
      };

      helm-project = lib.mkIf ide.project {
	enable = true;
	extraPackages = [pkgs.silver-searcher];
	bindLocal = {
	  project-prefix-map = {
	    "C-p" = lib.mkDefault "helm-project";
	    "g" = lib.mkDefault "helm-project-grep-ag";
	    "b" = lib.mkDefault "helm-project-buffers";
	    "f" = lib.mkDefault "helm-project-files";
	    "S" = lib.mkDefault "helm-project-list-projects";
	  };
	  helm-project-map = {
	    "C-c s" = lib.mkDefault "helm-project-ag";
	  };
	};
      };

      helm-projectile = lib.mkIf ide.projectile {
	enable = true;
	command = ["helm-projectile-find-file" "helm-projectile-recentf" "helm-projectile-switch-project" "helm-projectile-switch-to-buffer"];
      };

      helm-lsp = lib.mkIf ide.lsp.preset {
	enable = true;
	command = ["helm-lsp-workspace-symbol" "helm-lsp-global-workspace-symbol"];
      };
    };
  };
}
