{ ... }:

{
  imports = [
    ./language-support
    ./lsp-support
    ./dap-support
    ./project-management
    ./syntax-checkers
    ./direnv.nix
    ./treesit-fold.nix
    ./magit.nix
  ];
}
