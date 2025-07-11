{ pkgs, config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.erlang.enable = lib.mkEnableOption "enables erlang support";

  config = lib.mkIf ide.languages.erlang.enable {
    programs.emacs.init.usePackage.erlang-ts = {
      enable = true;
      mode = [''("\\.erl\\'" . erlang-ts-mode)''];
      extraPackages = if ide.eglot.enable || ide.lsp.enable then [pkgs.beamMinimal28Packages.erlang-ls] else [];
      eglot = ide.eglot.enable;
      lsp = ide.lsp.enable;
      symex = ide.symex;
    };
  };
}
