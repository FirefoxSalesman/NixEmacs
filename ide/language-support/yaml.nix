{
  config,
  lib,
  pkgs,
  ...
}:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.yaml.enable = lib.mkEnableOption "Enables Yaml support";
  config.programs.emacs.init = {
    ide = {
      treesitter.wantTreesitter = true;
      treesit-fold.enabledModes = lib.mkIf ide.treesit-fold.enable [ "yaml-ts-mode" ];
    };

    tools.apheleia.modeFormatters.yaml-ts-mode = lib.mkIf (
      config.programs.emacs.init.tools.apheleia.enable && (ide.eglot.enable || ide.lsp.enable)
    ) (lib.mkDefault (if ide.eglot.enable then "eglot" else "lsp"));

    usePackage.yaml-ts-mode = lib.mkIf ide.languages.yaml.enable {
      enable = true;
      mode = [ ''"\\.yaml\\'"'' ];
      extraPackages = lib.mkIf (
        ide.eglot.enable || ide.lsp.enable || ide.lspce.enable || ide.lsp-bridge.enable
      ) [ pkgs.yaml-language-server ];
      symex = ide.symex;
      eglot = lib.mkIf ide.eglot.enable ''("yaml-language-server" "--stdio")'';
      lsp = ide.lsp.enable;
      lspce = lib.mkIf ide.lspce.enable ''"yaml" "yaml-language-server" "--stdio"'';
    };
  };
}
