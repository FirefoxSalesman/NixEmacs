{ config, lib, ... }:

let
  completions = config.programs.emacs.init.completions;
  keybinds = config.programs.emacs.init.keybinds;
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.completions.company = {
    enable = lib.mkEnableOption "Enables company. Largely borrowed from Doom";
    posframe = lib.mkEnableOption "Company uses a posframe for its completions";
  };

  config.programs.emacs.init = lib.mkIf completions.company.enable {
    hasOn = true;
    usePackage = {
      company = {
        enable = true;
        hook = ["(on-first-input . global-company-mode)"];
        custom = {
          company-minimum-prefix-length = lib.mkDefault "2";
          company-tooltip-limit = lib.mkDefault "14";
          company-tooltip-align-annotations = lib.mkDefault true;
          company-require-match = lib.mkDefault "'never";
          company-global-modes = lib.mkDefault '''(not erc-mode
                                                       circe-mode
                                                       message-mode
                                                       help-mode
                                                       gud-mode
                                                       vterm-mode)
          '';
          company-frontends =  lib.mkDefault '''(company-pseudo-tooltip-frontend
                                                 company-echo-metadata-frontend)
          '';

          company-backends = lib.mkDefault "'(company-capf)";
          company-auto-commit = lib.mkDefault false;
          company-dabbrev-other-buffers = lib.mkDefault false;
          company-dabbrev-ignore-case = lib.mkDefault false;
          company-dabbrev-downcase = lib.mkDefault false;
        };
        gfhook = lib.mkIf keybinds.evil.enable ["('(evil-insert-state-exit-hook evil-emacs-state-exit-hook) 'company-abort)"];
        config = ''(with-eval-after-load 'eldoc
                                         (eldoc-add-command 'company-complete-selection
                                                            'company-complete-common
                                                            'company-capf
                                                            'company-abort))
                    ${if keybinds.evil.enable then ''
                      (with-eval-after-load 'evil-collection-company
                                            (evil-collection-define-key nil 'company-active-map
                                                                        (kbd "C-${keybinds.evil.keys.up}") 'company-select-previous-or-abort
                                                                        (kbd "C-${keybinds.evil.keys.down}") 'company-select-next-or-abort
                                            ))
                    '' else ""}
        '' ;
      };

      company-files = {
        enable = true;
        after = ["company"];
        config = ''(add-to-list 'company-files--regexps "file:\\(\\(?:\\.\\{1,2\\}/\\|~/\\|/\\)[^\]\n]*\\)")'';
      };

      company-box = lib.mkIf completions.company.posframe {
        enable = true;
        hook = ["(company-mode . company-box-mode)"];
      };

      evil-collection.custom.evil-collection-want-company-extended-keybinds = lib.mkIf keybinds.evil.enable (lib.mkDefault true);

      company-prescient = lib.mkIf completions.prescient {
        enable = true;
        hook = ["(global-company-mode . company-prescient-mode)"];
      };

      company-ledger = lib.mkIf ide.languages.ledger.enable {
        enable = true;
        after = ["company"];
        config = "(add-to-list 'company-backends 'company-ledger)";
      };
    };
  };
}
