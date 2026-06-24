{ config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.toml.enable = lib.mkEnableOption "enables toml support";

  config = lib.mkIf ide.languages.toml.enable {
    programs.emacs.init = {
      ide = {
        treesitter.treesitterGrammars.toml = "https://github.com/ikatyang/tree-sitter-toml";
        treesit-fold.enabledModes = lib.mkIf ide.treesit-fold.enable [ "toml-ts-mode" ];
      };

      tools.apheleia.modeFormatters.toml-ts-mode = lib.mkIf (
        config.programs.emacs.init.tools.apheleia.enable && (ide.eglot.enable || ide.lsp.enable)
      ) (lib.mkDefault (if ide.eglot.enable then "eglot" else "lsp"));

      usePackage.toml-ts-mode = {
        enable = true;
        mode = [ ''"\\.toml\\'"'' ];
        symex = ide.symex;
      };
    };
  };
}
