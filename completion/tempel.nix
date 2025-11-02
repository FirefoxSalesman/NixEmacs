{ config, lib, ... }:

let
  completions = config.programs.emacs.init.completions;
  handleTemplateContents =
    n:
    lib.concatStringsSep "\n  " (
      lib.mapAttrsToList (templateName: templateContents: "(${templateName} ${templateContents})") n
    );
in
{
  options.programs.emacs.init.completions.tempel = {
    enable = lib.mkEnableOption "Enable Temple for snippeting";
    templates = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
      default = { };
      example = {
        nix-mode.upackage = ''p "= {" n "  enable = true;" q "  }"'';
      };
      description = "User defined templates for Tempel.";
    };
  };

  config = lib.mkIf completions.tempel.enable {
    home.file.".config/emacs/templates.eld".text = ''
      ${lib.concatStringsSep "\n  " (
        lib.mapAttrsToList (
          mode: templates: "${mode}\n ${handleTemplateContents templates}"
        ) completions.tempel.templates
      )}
    '';

    programs.emacs.init.usePackage = {
      tempel = {
        enable = true;
        command = [ "tempel-complete" ];
        setopt.tempel-path = ''"~/.config/emacs/templates.eld"'';
      };

      tempel-collection = {
        enable = true;
        after = [ "tempel" ];
      };

      eglot-tempel = lib.mkIf config.programs.emacs.init.ide.eglot.enable {
        enable = true;
        after = [ "eglot" ];
        config = ''(eglot-tempel-mode)'';
      };
    };
  };
}
