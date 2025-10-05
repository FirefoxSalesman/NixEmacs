{ config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
  keybinds = config.programs.emacs.init.keybinds;
  completions = config.programs.emacs.init.completions;
in
{
  options.programs.emacs.init.writing.denote = lib.mkEnableOption "Enables denote";

  config.programs.emacs.init.usePackage = lib.mkIf config.programs.emacs.init.writing.denote {
    denote = {
      enable = true;
      defer = true;
      hook = ["(dired-mode . denote-dired-mode-in-directories)"];
      setopt = {
	denote-directory = lib.mkDefault ''(expand-file-name "denote" org-directory)'';
	denote-file-type = lib.mkDefault (
	  if ide.languages.org.enable then "'org" else
if ide.languages.markdown.enable then
if ide.languages.yaml.enable then "'markdown-yaml" else "'markdown-toml"
else "'text"
	);
	denote-dired-directories = lib.mkDefault ["denote-directory"];
      };
      generalOne.global-leader = lib.mkIf keybinds.leader-key.enable {
	"of" = "'denote-open-or-create";
	"or" = '''(denote-rename-file :whick-key "denote rename")'';
	"oi" = '''(denote-link :which-key "link to note")'';
      };
      config = lib.mkIf completions.smallExtras.enable "(consult-denote-mode)";
    };

    consult-denote = lib.mkIf completions.smallExtras.enable {
      enable = true;
      command = ["consult-denote-mode"];
      generalOne.global-leader."os" = lib.mkIf keybinds.leader-key.enable "'consult-denote-grep";
      setopt.consult-denote-grep-command = "'consult-ripgrep";
    };

    denote-org = lib.mkIf ide.languages.org.enable {
      enable = true;
      generalOne.global-leader."oh" = lib.mkIf keybinds.leader-key.enable "'denote-org-link-to-heading";
    };
  };
}
