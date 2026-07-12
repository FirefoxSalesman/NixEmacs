{
  pkgs,
  config,
  lib,
  ...
}:

let
  tools = config.programs.emacs.init.tools;
  keybinds = config.programs.emacs.init.keybinds;
in
{
  options.programs.emacs.init.tools.dired = {
    enable = lib.mkEnableOption "Enable dired improvements.";
    narrow = lib.mkEnableOption "Enable dired-narrow.";
    posframe = lib.mkEnableOption "Enable dired-posframe.";
    async = lib.mkEnableOption "Let dired move files asynchronously.";
    dirvish = {
      enable = lib.mkEnableOption "Use dirvish to prettify dired. Largely borrowed from Doom.";
      previews = lib.mkEnableOption "Use dirvish-peek to give previews on find-file & similar functions.";
    };
  };

  config.programs.emacs.init = lib.mkIf tools.dired.enable {
    hasOn = lib.mkIf tools.dired.dirvish.enable true;
    usePackage = {
      dired = {
        enable = true;
        hook = [
          "(dired-mode . (lambda () (dired-omit-mode) ${
            if tools.dired.dirvish.enable then "" else "(hl-line-mode) (setq-local visible-cursor nil)"
          }))"
        ];
        # These options are all borrowed from Prot.
        setopt = {
          dired-recursive-deletes = lib.mkDefault "'always";
          dired-recursive-copies = lib.mkDefault "'always";
          dired-listing-switches = lib.mkDefault ''"-agho --group-directories-first"'';
          dired-kill-when-opening-new-dired-buffer = lib.mkDefault true;
          dired-auto-revert-buffer = lib.mkDefault "#'dired-directory-changed-p";
          dired-create-destination-dirs = lib.mkDefault "'always";
        };
        generalOne.global-leader."d" = lib.mkIf keybinds.leader-key.enable '''("dired" . dired)'';
        bindLocal.ctl-x-map."C-j" = lib.mkDefault "dired-jump";
      };

      wdired = {
        enable = true;
        generalTwoConfig.":n".dired-mode-map."w" = lib.mkIf keybinds.evil.enable (
          lib.mkDefault "'wdired-change-to-wdired-mode"
        );
        bindLocal.dired-mode-map."w" = lib.mkIf (!keybinds.evil.enable) (
          lib.mkDefault "wdired-change-to-wdired-mode"
        );
      };

      diredfl = {
        enable = true;
        hook = [ "(dired-mode . diredfl-mode)" ];
      };

      dired-narrow = lib.mkIf (tools.dired.narrow && !tools.dired.dirvish.enable) {
        enable = true;
        generalTwo.":n".dired-mode-map."M-n" = lib.mkIf keybinds.evil.enable (
          lib.mkDefault "'dired-narrow-fuzzy"
        );
        bindLocal.dired-mode-map."M-n" = lib.mkIf (!keybinds.evil.enable) (
          lib.mkDefault "dired-narrow-fuzzy"
        );
      };

      dired-posframe = lib.mkIf tools.dired.posframe {
        enable = true;
        generalTwo.":n".dired-mode-map."M-t" = lib.mkIf keybinds.evil.enable (
          lib.mkDefault "'dired-posframe-mode"
        );
        bindLocal.dired-mode-map."M-t" = lib.mkIf (!keybinds.evil.enable) (
          lib.mkDefault "dired-posframe-mode"
        );
      };

      dired-hide-dotfiles = {
        enable = true;
        hook = [ "(dired-mode . dired-hide-dotfiles-mode)" ];
        generalTwoConfig.":n".dired-mode-map."H" = lib.mkIf keybinds.evil.enable (
          lib.mkDefault "'dired-hide-dotfiles-mode"
        );
        bindLocal.dired-mode-map."H" = lib.mkIf (!keybinds.evil.enable) (
          lib.mkDefault "dired-hide-dotfiles-mode"
        );
      };

      async = lib.mkIf tools.dired.async {
        enable = true;
        config = ''
          (autoload 'dired-async-mode "dired-async.el" nil t)
          (dired-async-mode)
        '';
      };

      dirvish = lib.mkIf tools.dired.dirvish.enable {
        enable = true;
        extraPackages = with pkgs; [
          vips
          mediainfo
        ];
        afterCall = [ "on-first-input-hook" ];
        generalOne.global-leader."T" = lib.mkIf keybinds.leader-key.enable (lib.mkDefault "'dirvish-side");
        bindLocal.dirvish-mode-map = lib.mkIf (!keybinds.evil.enable) {
          "M-n" = lib.mkIf tools.dired.narrow (lib.mkDefault "'dirvish-narrow");
          "M-m" = lib.mkDefault "'dirvish-mark-menu";
          "f" = lib.mkDefault "'dirvish-file-info-menu";
          "y" = lib.mkDefault "'dirvish-yank";
          "S" = lib.mkDefault "'dirvish-quicksort";
          "F" = lib.mkDefault "'dirvish-layout-toggle";
          "z" = lib.mkDefault "'dirvish-history-jump";
          "C-i" = lib.mkDefault "'dirvish-subtree-toggle";
          "M-b" = lib.mkDefault "'dirvish-history-go-backward";
          "M-f" = lib.mkDefault "'dirvish-history-go-forward";
          "M-e" = lib.mkDefault "'dirvish-emerge-menu";
          "C-w l" = lib.mkDefault "'dirvish-copy-file-true-path";
          "C-w n" = lib.mkDefault "'dirvish-copy-file-name";
          "C-w p" = lib.mkDefault "'dirvish-copy-file-path";
          "s s" = lib.mkDefault "'dirvish-symlink";
          "s S" = lib.mkDefault "'dirvish-relative-symlink";
          "s h" = lib.mkDefault "'dirvish-hardlink";
        };
        generalTwoConfig.":n".dirvish-mode-map = lib.mkIf keybinds.evil.enable {
          "M-n" = lib.mkIf tools.dired.narrow (lib.mkDefault "'dirvish-narrow");
          "M-m" = lib.mkDefault "'dirvish-mark-menu";
          "f" = lib.mkDefault "'dirvish-file-info-menu";
          "p" = lib.mkDefault "'dirvish-yank";
          "S" = lib.mkDefault "'dirvish-quicksort";
          "F" = lib.mkDefault "'dirvish-layout-toggle";
          "z" = lib.mkDefault "'dirvish-history-jump";
          "g${keybinds.evil.keys.backward}" = lib.mkDefault "'dirvish-subtree-up";
          "g${keybinds.evil.keys.forward}" = lib.mkDefault "'dirvish-subtree-toggle";
          "C-i" = lib.mkDefault "'dirvish-subtree-toggle";
          "[h" = lib.mkDefault "'dirvish-history-go-backward";
          "]h" = lib.mkDefault "'dirvish-history-go-forward";
          "[e" = lib.mkDefault "'dirvish-emerge-next-group";
          "]e" = lib.mkDefault "'dirvish-emerge-previous-group";
          "M-e" = lib.mkDefault "'dirvish-emerge-menu";
          "y" = lib.mkDefault '''(:ignore t :which-key "yank")'';
          "yl" = lib.mkDefault "'dirvish-copy-file-true-path";
          "yn" = lib.mkDefault "'dirvish-copy-file-name";
          "yp" = lib.mkDefault "'dirvish-copy-file-path";
          "s" = lib.mkDefault '''(:ignore t :which-key "symlinks")'';
          "ss" = lib.mkDefault "'dirvish-symlink";
          "sS" = lib.mkDefault "'dirvish-relative-symlink";
          "sh" = lib.mkDefault "'dirvish-hardlink";
        };
        setopt =
          let
            dirvishTypes = [
              "'dirvish"
              "'dirvish-side"
            ];
          in
          {
            dirvish-reuse-session = "'open";
            dirvish-attributes =
              if config.programs.emacs.init.aesthetics.icons.enable then
                [
                  "'file-size"
                  "'nerd-icons"
                  "'subtree-state"
                ]
              else
                [
                  "'file-size"
                  "'subtree-state"
                ];
            dirvish-hide-details = dirvishTypes;
            dirvish-hide-cursor = dirvishTypes;
            dirvish-use-mode-line = false;
          };
        config = ''
          (dirvish-override-dired-mode)
          (advice-add #'dired--find-file :override #'dirvish--find-entry)
          (advice-add #'dired-noselect :around #'dirvish-dired-noselect-a)
          (advice-add #'dirvish-side :after (local! window-size-fixed t))
          ${
            if tools.goldenRatio then
              ''
                (add-to-list
                 #'golden-ratio-inhibit-functions
                 (lambda ()
                   (string-prefix-p " *SIDE :: " (buffer-name (current-buffer)))))
              ''
            else
              ""
          }
          (with-eval-after-load 'dirvish-yank
            (defun dirvish-yank--apply (method dest)
              "Apply yank METHOD to DEST."
              (setq dest (expand-file-name (or dest (dired-current-directory))))
              (let ((srcs
                     (or (and (not
                               (member
                                dirvish-yank-sources '(all session buffer)))
                              (functionp dirvish-yank-sources)
                              (funcall dirvish-yank-sources))
                         (dirvish-yank--get-srcs dirvish-yank-sources)
                         (user-error "DIRVISH[yank]: no marked files"))))
                (dirvish-yank-default-handler method srcs dest))))
          ${if tools.dired.dirvish.previews then "(dirvish-peek-mode)" else ""}
          ${
            if tools.exwm.enable then
              ''
                (dolist (ext '("xcf" "odt" "doc" "docx" "odp" "pptx" "xlsx"))
                  (add-to-list 'dirvish-preview-disabled-exts ext))
              ''
            else
              ""
          }
        '';
      };
    };
  };
}
