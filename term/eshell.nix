{ pkgs, config, lib, ... }:

let
  terminals = config.programs.emacs.init.terminals;
  keybinds = config.programs.emacs.init.keybinds;
in
  {
    options.programs.emacs.init.terminals.eshell = lib.mkEnableOption "Enables eshell. Eat & some kind of in-buffer completion are also recommended.";

    config.programs.emacs.init.usePackage = lib.mkIf terminals.eshell {
      eshell = {
	enable = true;
	babel = "eshell";
	after = lib.mkIf keybinds.evil.enable ["evil-collection"];
	custom = {
	  eshell-buffer-maximum-lines = lib.mkDefault 100;
	  eshell-hist-ignoredups = lib.mkDefault true;
	  eshell-scroll-to-bottom-on-input = lib.mkDefault true;
	};
	hook = [
	  #Save command history when commands are entered
	  "(eshell-precommand . eshell-save-some-history)"
	  #pfetch
	  ''(eshell-banner-load . (lambda () (setopt eshell-banner-message (shell-command-to-string "${pkgs.pfetch}/bin/pfetch"))))''
	  ''(eshell-first-time-mode . (lambda () (add-to-list 'eshell-output-filter-functions 'eshell-truncate-buffer)
	    (setenv "TERM" "xterm")))''
	];
	generalOne.global-leader."t" = lib.mkIf keybinds.leader-key.enable "'eshell";
	generalOneConfig.eshell-mode-map = lib.mkIf keybinds.evil.enable {
	  "M-${keybinds.evil.keys.up}" = lib.mkDefault "'eshell-previous-matching-input-from-input";
	  "M-${keybinds.evil.keys.down}" = lib.mkDefault "'eshell-next-matching-input-from-input";
	};
	generalTwoConfig.local-leader.eshell-mode-map = lib.mkIf keybinds.evil.enable {
	  "e" = lib.mkDefault '''(eshell-insert-envvar :which-key "insert environment variable")'';
	  "b" = lib.mkDefault '''(eshell-insert-buffer-name :which-key "insert buffer name")'';
	};
	config = ''
	  (with-eval-after-load 'esh-opt
          (setopt eshell-destroy-buffer-when-process-dies t))
	'';
      };

      eshell-syntax-highlighting = {
	enable = true;
	hook = ["(eshell-mode . eshell-syntax-highlighting-global-mode)"];
      };

      fish-completion = {
	enable = true;
	extraPackages = [pkgs.fish pkgs.bash];
	hook = ["(eshell-mode . fish-completion-mode)"];
      };

      eshell-git-prompt = {
	enable = true;
	afterCall = ["eshell-mode"];
	config = ''(eshell-git-prompt-use-theme 'powerline)'';
      };
    } ;
  }
