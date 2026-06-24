{ config, lib, ... }:

let
  tools = config.programs.emacs.init.tools;
  makeModeFormatters =
    vs:
    lib.concatStringsSep "\n" (
      lib.optionals (vs != { }) (lib.mapAttrsToList (mode: formatter: "(${mode} . ${formatter})") vs)
    );
  makeFormattersHelper =
    formatter:
    if lib.isList formatter then "'(${lib.concatMapStrings (k: ''"${k}" '') formatter})" else formatter;
  makeFormatters =
    vs:
    lib.concatStringsSep "\n" (
      lib.optionals (vs != { }) (
        lib.mapAttrsToList (
          name: formatter: "(setf (alist-get '${name} apheleia-formatters) ${makeFormattersHelper formatter})"
        ) vs
      )
    );
in
{
  options.programs.emacs.init.tools.apheleia = {
    enable = lib.mkEnableOption "Enables apheleia.";
    autoFormat = lib.mkEnableOption "Auto-format buffers on save with apheleia.";
    modeFormatters = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Aphelia formatters for each major mode";
    };
    formatters = lib.mkOption {
      type = lib.types.attrsOf (lib.types.either lib.types.str (lib.types.listOf lib.types.str));
      default = { };
      description = "Aphelia formatters & their commands";
    };
  };

  config.programs.emacs.init.usePackage.apheleia = lib.mkIf tools.apheleia.enable {
    enable = true;
    ghookf = lib.mkIf tools.apheleia.autoFormat [ "('on-first-file 'apheleia-global-mode)" ];
    config = ''
      (defmacro make-apheleia-formatter (name &rest body)
        "Return a function that can be used as an apheleia formatter.
      NAME is the name of the function, BODY is every action taken on the scratch buffer before the callback."
        `(cl-defun
          ,name
          (&key buffer scratch callback &allow-other-keys)
          "Copy BUFFER to SCRATCH, then format scratch, then call CALLBACK."
          (with-current-buffer scratch
            ,@body
            (funcall callback))))

      ${makeFormatters tools.apheleia.formatters}

      (dolist (pair '(${makeModeFormatters tools.apheleia.modeFormatters}))
        (add-to-list 'apheleia-mode-alist pair))
    '';
    generalOne.global-leader."F" =
      lib.mkIf config.programs.emacs.init.keybinds.leader-key.enable "'apheleia-format-buffer";
  };
}
