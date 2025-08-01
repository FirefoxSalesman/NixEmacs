{ pkgs, lib, ... }:

{
  imports = [
    ./treesitter.nix

    ./python.nix
    ./hy.nix
    ./java.nix
    ./emacs-lisp.nix
    ./gradle.nix
    ./clojure.nix
    ./scala.nix
    ./kotlin.nix
    ./nix.nix
    ./html.nix
    ./css.nix
    ./javascript.nix
    ./typescript.nix
    ./purescript.nix
    ./coffeescript.nix
    ./pug.nix
    ./json.nix
    ./toml.nix
    ./haskell.nix
    ./c.nix
    ./bash.nix
    ./r.nix
    ./prolog.nix
    ./zenscript.nix
    ./rust.nix
    ./lua.nix
    ./fennel.nix
    ./plantuml.nix
    ./erlang.nix
    ./sql.nix
    ./forth.nix
    ./go.nix
    ./markdown.nix
    ./zig.nix
    ./latex.nix
    ./csharp.nix
    ./ruby.nix
    ./common-lisp.nix
    ./scheme.nix
    ./racket.nix
    ./xml.nix
  ];

  options.programs.emacs.init.ide = {
    evil = lib.mkEnableOption "enables evil support in all languages that support it";
    breadcrumb = lib.mkEnableOption "Enables the breadcrumb header";
    hoverDoc = lib.mkEnableOption "Enables hover documentation";
    symex = lib.mkEnableOption "enables symex support in all languages that support it";
    lsp.enable = lib.mkEnableOption "enables lsp-mode support in all languages that support it";
    eglot.enable = lib.mkEnableOption "enables eglot support in all languages that support it";
    lspce.enable = lib.mkEnableOption "enables lspce support in all languages that support it";
  };
}
