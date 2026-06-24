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
  options.programs.emacs.init.ide.languages.erlang.enable =
    lib.mkEnableOption "enables erlang support";

  config.programs.emacs.init = lib.mkIf ide.languages.erlang.enable {
    ide = {
      treesitter.wantTreesitter = true;
      treesit-fold.enabledModes = lib.mkIf ide.treesit-fold.enable [ "erlang-ts-mode" ];
    };

    tools.apheleia.modeFormatters.erlang-ts-mode = lib.mkIf (
      config.programs.emacs.init.tools.apheleia.enable && (ide.eglot.enable || ide.lsp.enable)
    ) (lib.mkDefault (if ide.eglot.enable then "eglot" else "lsp"));

    usePackage.erlang-ts = {
      enable = true;
      mode = [ ''("\\.erl\\'" . erlang-ts-mode)'' ];
      extraPackages =
        if ide.lsp-bridge.enable || ide.eglot.enable || ide.lspce.enable || ide.lsp.enable then
          [ pkgs.beamMinimal28Packages.erlang-ls ]
        else
          [ ];
      eglot = ide.eglot.enable;
      lsp = ide.lsp.enable;
      symex = ide.symex;
      lspce = lib.mkIf ide.lspce.enable ''"erlang" "erlang_ls" "--transport stdio"'';
      config = lib.mkIf ide.dap.enable "(require 'dap-erlang)";
    };
  };
}
