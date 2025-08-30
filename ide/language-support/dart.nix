{ config, lib, ... }:

let ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.dart = {
    enable = lib.mkEnableOption "Enables dart support. You'll need to install the language server yourself, as I can't find it in nixpkgs";
    flutter = lib.mkEnableOption "Enables flutter support";
  };

  config.programs.emacs.init.usePackage = lib.mkIf ide.languages.dart.enable {
    dart-mode = {
      enable = true;
      eglot = ide.eglot.enable;
      lsp = ide.lsp.enable;
      lspce = ide.lspce.enable;
      config = lib.mkIf ide.lspce.enable ''(with-eval-after-load 'lspce (add-to-list 'lspce-server-programs (list "dart" "dart" "language-server")))'';
    };

    flutter = lib.mkIf ide.languages.dart.flutter {
      enable = true;
      after = ["dart-mode"];
    };

    hover = lib.mkIf ide.languages.dart.flutter {
      enable = true;
      after = ["dart-mode"];
    };

    lsp-dart = lib.mkIf ide.lsp.enable {
      enable = true;
      after = ["lsp-mode"];
    };
  };
}
