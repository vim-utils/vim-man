# Changelog

### master

- add "guards" for the autoload files
- add syntax highlighting for files in FILES manpage section
- syntax highlighting for environment variables in ENVIRONMENT manpage section
- syntax bugfix: url's can't contain tab characters
- add instructions for creating `viman` command line script (@alx741)
- `q` mapping quits `vim-man` buffer
- `g/` mapping for easier option search

### v0.1.0, Jan 24, 2015

- split the main script into ftplugin, plugin and autoload directories
- remove tab characters from the source and whitespace cleanup
- remove script headers, give credits to the authors in the README
- drop support for vim versions 5 and 6
- use `keepjumps` so that jumplist is not messed up
- consistently use longer VimL keywords (function, command, syntax etc)
- improve error message shown when man page is not found
- move scratch buffer local options to ft file
- update manpage buffer name
- `:Vman` - opens a manpage in vertical split
- add `:Sman` (the same as `:Man`) for "interface" consistency
- `tabstop=8` for manpages
- add all tag mappings and map them to the same action
- [[ and ]] mappings for section movement
- remove the mapping "guards". If the user installed the plugin, they are most
  likely wanted.
- enable <bar> (in vim's command line) to follow man commands
- command line completion for `:Man`, `:Sman` and `:Vman` commands
- switch to different implementation for `strip_file_names` completion helper
  function. vim's `map()` function errors out for larger lists
- implement tests for completion "strip extension" function. Improve manpage
  filename stripping so it supports more cases.
- improve manpage section argument handling for completion
- $MANPATH environment variable has precedence when searching for manpath
- remove duplicates from `:Man` command completion list
- improve `[[` and `]]` mappings: manpage section can start only with letters
- bugfix: manTitle syntax highlighting for TCL man pages
- syntax highlighting for more functions in manpages
- improved syntax highlighting for 'LEGACY SYNOPSIS' manpage section
- `g:man_width` enables user to specify fixed manpage width
- `K` within man buffer also jumps to a manpage under cursor
- remove the default `<leader>K` mapping and enable users do define their own
  mapping to open a manpage for word under cursor
- enable converting `nroff` files to manpages with `:Man`, `:Sman` and `:Vman`
  commands
- add `<Plug>(Sman)` and `<Plug>(Vman)` mappings. `<Plug>(Sman)` is the same as
  `<Plug>(Man)` and `<Plug(Vman)` does a vertical split.
- implement `:Mangrep` command
- implement async `:Mangrep` with neovim
- `:Mangrep` now respects vim's bang convention
- add a vim-dispatch strategy for `:Mangrep`
- expand the README and add docs
