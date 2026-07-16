{
  config,
  lib,
  pkgs,
  ...
}:

let
  init = config.programs.emacs.init;
in
{
  options.programs.emacs.init.ide.citre.enable =
    lib.mkEnableOption "Enables citre. It provides a way to peek at symbol definitions, & an alternate backend to xref for when you can't use lsps. Borrowed from John Weigley's config.";

  config.programs.emacs.init.usePackage.citre = lib.mkIf init.ide.citre.enable {
    enable = true;
    hook = [
      "(prog-mode . citre-mode)"
      (if init.keybinds.doomEscape.enable then "(doom-escape . citre-peek-abort)" else "")
    ];
    setopt = {
      citre-prompt-language-for-ctags-command = lib.mkDefault true;
      citre-use-project-root-when-creating-ctags = lib.mkDefault true;
      citre-ctags-program = lib.mkDefault ''"${pkgs.universal-ctags}/bin/ctags"'';
      citre-readtags-program = lib.mkDefault ''"${pkgs.universal-ctags}/bin/readtags"'';
    };
    custom.citre-peek-ace-keys = lib.mkDefault (
      lib.map (key: "'?${key}") config.programs.emacs.init.keybinds.avy.avyKeys
    );
    generalTwoConfig.local-leader.citre-mode-map = lib.mkIf init.keybinds.leader-key.enable {
      "p" = lib.mkDefault (if init.keybinds.avy.enable then "'citre-ace-peek" else "'citre-peek");
      "u" = lib.mkDefault "'citre-update-this-tags-file";
    };
    generalOneConfig.citre-peek-keymap = lib.mkIf init.keybinds.evil.enable {
      "M-${init.keybinds.evil.keys.down}" = "'citre-peek-next-line";
      "M-${init.keybinds.evil.keys.up}" = "'citre-peek-prev-line";
    };
  };
}
