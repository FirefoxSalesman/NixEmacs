{ config, lib, ... }:

let
  writing = config.programs.emacs.init.writing;
  ide = config.programs.emacs.init.ide;
  keybinds = config.programs.emacs.init.keybinds;
  completions = config.programs.emacs.init.completions;
  hookIf = condition: hook: if condition then "(${hook}-mode . citar-capf-setup)" else "";
in
{
  options.programs.emacs.init.writing.citar =
    lib.mkEnableOption "Enables citar as your bibliography system";
  config.programs.emacs.init.usePackage = lib.mkIf writing.citar {
    citar = {
      enable = true;
      config = ''
        ${if writing.denote then "(citar-denote-mode)" else ""}
        ${if writing.orgRoam then "(citar-org-roam-mode)" else ""}
      '';
      hook = [
        (hookIf ide.languages.latex.enable "LaTeX")
        (hookIf ide.languages.markdown.enable "gfm")
        (hookIf ide.languages.org.enable "org")
      ];
      setopt = {
        org-cite-insert-processor = lib.mkDefault "'citar";
        org-cite-follow-processor = lib.mkDefault "'citar";
        org-cite-activate-processor = lib.mkDefault "'citar";
        org-cite-global-bibliography = "citar-bibliography";
      };
    };

    citar-embark = lib.mkIf completions.smallExtras.embark {
      enable = true;
      after = [
        "citar"
        "embark"
      ];
      config = ''(citar-embark-mode)'';
      setopt.citar-at-point-function = lib.mkDefault "'embark-act";
    };

    citar-denote = lib.mkIf writing.denote {
      enable = true;
      command = [ "citar-denote-mode" ];
      generalOne.global-leader = keybinds.leader-key.enable {
        "on" = '''(citar-create-note :which-key "new citar note")'';
        "oo" = '''(citar-denote-open-note :which-key "open citar note")'';
        "ol" = "'citar-denote-link-reference";
        "ow" = "'citar-denote-find-citation";
      };
    };

    citar-org-roam = lib.mkIf writing.orgRoam {
      enable = true;
      command = [ "citar-org-roam-mode" ];
      generalOne.global-leader = keybinds.leader-key.enable {
        "on" = '''(citar-create-note :which-key "new citar note")'';
        "oo" = '''(citar-open-notes :which-key "open citar note")'';
      };
    };
  };
}
