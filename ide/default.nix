{ ... }:

{
  imports = [
    ./language-support
    ./lsp-support
    ./dap-support
    ./project-management
    ./syntax-checkers
    ./citre.nix
    ./direnv.nix
    ./treesit-fold.nix
    ./magit.nix
  ];
}
