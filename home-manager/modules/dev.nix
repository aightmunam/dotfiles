# General development tools: languages, runtimes, and dev conveniences that are
# not tied to one editor/terminal or to the AI toolchain.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    tldr        # Better man pages
    duf         # Better df
    direnv      # per-directory env (hooked directly in .zshrc)
    go
    jq
    lua
    pyenv
    tree-sitter
    yq
  ];
}
