{
  pkgs,
  config,
  lib,
  ...
}:
let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.godot.enable =
    lib.mkEnableOption "Enables godot support. If you wish to use the language server, the godot editor must be running. Does not support lspce or lsp-bridge.";
  config.programs.emacs.init = lib.mkIf ide.languages.godot.enable {
    ide.treesitter.treesitterGrammars.gdscript = "https://github.com/PrestonKnopp/tree-sitter-gdscript.git";
    usePackage.gdscript-ts-mode = {
      enable = true;
      package = epkgs: epkgs.gdscript-mode;
      extraPackages = with pkgs; [
        godot
        gdtoolkit_4
      ];
      symex = ide.symex;
      eglot = ide.eglot.enable;
      lsp = ide.lsp.enable;
      mode = [
        ''"\\.tscn\\'"''
        ''"\\.gd\\'"''
      ];
    };
  };
}
