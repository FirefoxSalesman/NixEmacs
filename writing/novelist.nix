{ config, lib, ... }:

{
  options.programs.emacs.init.writing.novelist = lib.mkEnableOption "Enables org-novelist";

  config.programs.emacs.init.usePackage.org-novelist = lib.mkIf config.programs.emacs.init.writing.novelist {
    enable = true;
    command = ["org-novelist-mode" "org-novelist-new-story"];
    generalTwoConfig.local-leader.org-novelist-mode-map = lib.mkIf config.programs.emacs.init.keybinds.leader-key.enable {
      "c" = '''(:ignore t :which-key "character")'';
      "cn" = '''(org-novelist-new-character :which-key "new")'';
      "cr" = '''(org-novelist-rename-character :which-key "rename")'';
      "cd" = '''(org-novelist-destroy-character :which-key "destroy")'';
      "h" = '''(:ignore t :which-key "chapter")'';
      "hn" = '''(org-novelist-new-chapter :which-key "new")'';
      "hr" = '''(org-novelist-rename-chapter :which-key "rename")'';
      "hd" = '''(org-novelist-destroy-chapter :which-key "destroy")'';
      "p" = '''(:ignore t :which-key "place")'';
      "pn" = '''(org-novelist-new-place :which-key "new")'';
      "pr" = '''(org-novelist-rename-place :which-key "rename")'';
      "pd" = '''(org-novelist-destroy-place :which-key "destroy")'';
      "r" = '''(:ignore t :which-key "prop")'';
      "rn" = '''(org-novelist-new-prop :which-key "new")'';
      "rr" = '''(org-novelist-rename-prop :which-key "rename")'';
      "rd" = '''(org-novelist-destroy-prop :which-key "destroy")'';
      "e" = '''(org-novelist-export-story :which-key "export")'';
    };
  };
}
