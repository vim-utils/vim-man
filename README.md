# man.vim

View man pages in vim. Grep for the man pages.

### Features and Usage

##### Viewing man pages

- `:Man printf` - open `printf(1)` man page in a split
- `:Vman 3 putc` - open `putc(3)` man page in a vertical split (read more
  [here](http://unix.stackexchange.com/a/3587/80379) on what the
  manual page numbers mean, they are really useful)
- `:Man pri<Tab>` - command completion for man page names
- `:Man 3 pri<Tab>` - completion "respects" the man page section argument
- `:Man 6 <Ctrl-D>` - list all man pages from section 6

##### When editing `nroff` files

- `:Man` - (without arguments) open a current `nroff` file as a man page

##### When inside a man page buffer

- `[[` and `]]` - jump to prev/next section heading
- `Ctrl-]` - jump to man page for a word under cursor (works nicely with
  specially highlighted references to other man pages i.e. `printf(3)`), also
  defined for other tag mappings like `g_Ctrl-]`, `Ctrl-W_Ctrl-]` etc.
- `K` - same as `Ctrl-]`
- `Ctrl-T` - jump \*back* to the previous man page
- `g/` - start option search (useful for quickly jumping to man page option
  description, example `--quiet` or `-q`)
- `gx` - open a link under cursor in a browser
  ([vim feature](http://vimdoc.sourceforge.net/htmldoc/pi_netrw.html#netrw-gx))
- `gf` - jump to a file under cursor
  ([vim feature](http://vimdoc.sourceforge.net/htmldoc/editing.html#gf),
  works nicely with C header files often found in section 2 and 3 man pages i.e.
  `<sys/socket.h>`)
- `q` - quit `vim-man` buffer

##### Using from the shell

You can use vim-man from the shell (instead of standard `man` program) using
the following script:

    #! /bin/sh
    vim -c "Man $1 $2" -c 'silent only'

Save it in `/usr/bin/` as a file named `viman`, give it execution
permission with:

    $ chmod +x /usr/bin/viman

Then from your shell you can read a DOC with:

    $ viman doc

Or you can use the alias `alias man=viman` so you can do (as usual):

    $ man doc

##### Searching/grepping man pages

Also see [About Mangrep](#about-mangrep)

- `:Mangrep 1 foobar` - search for "foobar" in all section 1 man pages
- `:Mangrep foobar` - same as `:Mangrep 1 foobar` (grepping all man sections
  by default would take too long)
- `:Mangrep * foobar` - force search \*all* man sections
- `:Mangrep -i 6 foobar` - case insensitive search
- `:Mangrep 6 '(foo|bar|baz)'` - regex search (`Mangrep` uses `grep -E`), just
  remember to quote the search pattern

##### Defining mappings in `.vimrc`

No mappings are defined by default.

- `map <leader>k <Plug>(Man)` - open man page for word under cursor in a horizontal
  split
- `map <leader>v <Plug>(Vman)` - open man page for word under cursor in a vertical
  split

### About Mangrep

This feature is still in beta.
Please help fix the [issues](https://github.com/vim-utils/vim-man/issues/).

`Mangrep` populates quickfix list with the results. While they should be
accurate, you might experience hiccups when opening those results.

Running `Mangrep`:

- the command runs in the background if you use neovim
- The command runs in the background if you have
  [vim-dispatch](https://github.com/tpope/vim-dispatch) installed. Access the
  results with
  [`:Copen` command](https://github.com/tpope/vim-dispatch#background-builds)
  (may be called before the process is finished).
- If you have vanilla vim the command will \*block* and make vim unusable
  until done (and it can take a while).<br/>
  Installing [vim-dispatch](https://github.com/tpope/vim-dispatch)
  is recommended. Or at least run `Mangrep` in another vim so your working vim
  instance stays usable.

### Installation

Just use your favorite plugin manager.

If you were previously using `man.vim` that comes with vim by default, please
remove this line `runtime! ftplugin/man.vim` from your `.vimrc`. It's known to
be causing [issues](https://github.com/vim-utils/vim-man/issues/23) with this
plugin.

### Contributing

Contributing and bug fixes are welcome. If you have an idea for a new feature
please get in touch by opening an issue so we can discuss it first.

### Credits

Vim by default comes with man page viewer, as decribed in
[find-manpage](http://vimdoc.sourceforge.net/htmldoc/usr_12.html#find-manpage).
This work is the improvement of vim's original man page plugin. The list of
improvements is [here](improvements.md).

These people created and maintain (or maintained) `man.vim` that comes with vim
itself:
* SungHyun Nam
* Gautam H. Mudunuri
* Johannes Tanzler

### License

Vim license, see `:help license`.
