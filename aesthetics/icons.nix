{ config, lib, ... }:

let
  aesthetics = config.programs.emacs.init.aesthetics;
  completions = config.programs.emacs.init.completions;
  tools = config.programs.emacs.init.tools;
in
{
  options.programs.emacs.init.aesthetics.icons = {
    enable = lib.mkEnableOption "Enables icons in various emacs modes.";
    forceInstallAllTheIcons = lib.mkEnableOption "Forcibly installs all-the-icons, even if no package that this framework supports would take advantage of it.";
    forceInstallNerdIcons = lib.mkEnableOption "Forcibly installs nerd-icons even if no package that this framework supports would take advantage of it.";
  };

  config.programs.emacs.init.usePackage = lib.mkIf aesthetics.icons.enable {
    nerd-icons =
      lib.mkIf
        (
          aesthetics.icons.forceInstallNerdIcons
          || completions.smallExtras.enable
          || tools.dired.enable
          || completions.corfu.enable
          || completions.company.posframe
          || completions.helm.enable
          || completions.ivy.enable
        )
        {
          enable = true;
          command = [
            "nerd-icons-octicon"
            "nerd-icons-faicon"
            "nerd-icons-flicon"
            "nerd-icons-wicon"
            "nerd-icons-mdicon"
            "nerd-icons-codicon"
            "nerd-icons-devicon"
            "nerd-icons-ipsicon"
            "nerd-icons-pomicon"
            "nerd-icons-powerline"
          ];
        };

    all-the-icons = lib.mkIf aesthetics.icons.forceInstallAllTheIcons {
      enable = true;
    };

    nerd-icons-completion = lib.mkIf completions.smallExtras.enable {
      enable = true;
      hook = [ "(marginalia-mode . nerd-icons-completion-marginalia-setup)" ];
    };

    nerd-icons-dired = lib.mkIf tools.dired.enable {
      enable = true;
      hook = [ "(dired-mode . nerd-icons-dired-mode)" ];
    };

    nerd-icons-corfu = lib.mkIf completions.corfu.enable {
      enable = true;
      config = "(add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter)";
      after = [ "corfu" ];
    };

    helm-icons = lib.mkIf completions.helm.enable {
      enable = true;
      hook = [ "(helm-mode . helm-icons-mode)" ];
      custom.helm-icons-provider = "'nerd-icons";
    };

    nerd-icons-ivy-rich = lib.mkIf completions.ivy.enable {
      enable = true;
      after = [ "ivy-rich" ];
      config = "(nerd-icons-ivy-rich-mode)";
    };
  };
}
