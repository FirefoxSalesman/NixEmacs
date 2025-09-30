{ config, lib, ... }:

let
  terminals = config.programs.emacs.init.terminals;
in
{
  options.programs.emacs.init.terminals.coterm = {
    enable = lib.mkEnableOption "Improves comint buffers by enabling comint-mode.";
    coterm-program = lib.mkOption {
      type = lib.types.str;
      default = "bash";
      description = ''
	The program to run when opening a comint terminal with run-coterm.
      '';
    };
  };

  config.programs.emacs.init.usePackage.coterm = lib.mkIf terminals.coterm.enable {
    enable = true;
    command = ["run-coterm"];
    preface = ''
      (defun run-coterm ()
        "Opens a comint terminal with coterm-program."
        (interactive)
	(comint-run "${terminals.coterm.coterm-program}"))
    '';
    generalOne.global-leader."t" = "'run-coterm";
    after = ["comint"];
    config = "(coterm-mode)";
    bindLocal.comint-mode-map."C-;" = lib.mkDefault "coterm-char-mode-cycle";
  };
}
