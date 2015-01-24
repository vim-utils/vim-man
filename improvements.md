### Improvements

This file contains a list of improvements over `man.vim` that comes with
vim. For a full list of changes you might want to check
[CHANGELOG.md](CHANGELOG.md).

- `:Vman` command that opens a manpage in a vertical split
- command line completion for `:Man` and `:Vman` commands
- `:Mangrep` command for grepping through manpages
- `:Man` (without arguments) opens the current file as a manpage (works only for
  `nroff` files)
- `[[` and `]]` for navigating manpage sections
- improvements to manpage syntax highlighting
- docs
- faster plugin loading (uses vim's autoloading)
- a lot of bugfixes
