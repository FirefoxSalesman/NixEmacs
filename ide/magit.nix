{ config, lib, ... }:

let
  keybinds = config.programs.emacs.init.keybinds;
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.magit = {
    enable = lib.mkEnableOption "Enables magit.";
    forge = lib.mkEnableOption "Enable forge for dealing with sites like github & gitlab. Borrowed from Doom.";
    todo = lib.mkEnableOption "Show project TODOs in magit.";
  };

  config.programs.emacs.init.usePackage = lib.mkIf ide.magit.enable {
    magit = {
      enable = true;
      setopt.magit-display-buffer-function = lib.mkDefault "#'magit-display-buffer-same-window-except-diff-v1";
      bindLocal.project-prefix-map = lib.mkIf ide.project {
        "v" = lib.mkDefault "magit-status";
        "c" = lib.mkDefault "magit-commit";
        "p" = lib.mkDefault "magit-pull";
        "P" = lib.mkDefault "magit-push";
        "b" = lib.mkDefault "magit-branch";
        "m" = lib.mkDefault "magit-merge";
      };
    };

    forge = lib.mkIf ide.magit.forge {
      enable = true;
      afterCall = [ "magit-status" ];
      command = [
        "forge-create-pullreq"
        "forge-create-issue"
      ];
      custom = {
        forge-add-default-keybindings = lib.mkDefault (!keybinds.evil.enable);
        forge-database-file = lib.mkDefault ''(concat user-emacs-directory "forge/forge-database.sqlite")'';
      };
      generalTwoConfig.":n".forge-topic-list-mode-map."q" = lib.mkIf keybinds.evil.enable (
        lib.mkDefault "'kill-current-buffer"
      );
      generalOneConfig = lib.mkIf (!keybinds.evil.enable) {
        magit-mode-map."C-c C-o" = lib.mkDefault "'forge-browse";
        magit-remote-section-map."C-c C-o" = lib.mkDefault "'forge-browse-remote";
        magit-branch-section-map."C-c C-o" = lib.mkDefault "'forge-browse-branch";
      };
    };

    code-review = lib.mkIf ide.magit.forge {
      enable = true;
      after = [ "forge" ];
      init = ''
        	(with-eval-after-load 'evil-collection-magit
                  (dolist (binding evil-collection-magit-mode-map-bindings)
                    (pcase-let* ((`(,states _ ,evil-binding ,fn) binding))
                      (dolist (state states)
                        (evil-collection-define-key state 'code-review-mode-map evil-binding fn))))
                  (evil-set-initial-state 'code-review-mode evil-default-state))
      '';
      config = ''
        	(transient-append-suffix 'magit-merge "d"
                  '("y" "Review pull request" +magit/start-code-review))
                (with-eval-after-load 'forge
                  (transient-append-suffix 'forge-dispatch "c u"
                    '("c r" "Review pull request" +magit/start-code-review)))
      '';
    };

    magit-todos = lib.mkIf ide.magit.todo {
      enable = true;
      after = [ "magit" ];
      config = "(magit-todos-mode)";
    };
  };
}
