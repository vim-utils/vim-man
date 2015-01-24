# man.vim

View man pages in vim.

### Features and Usage

Viewing manpages:

- `:Man printf` - open `printf(1)` manpage in a split
- `:Vman 3 putc` - open `putc(3)` manpage in a vertical split (read more
  [here](http://unix.stackexchange.com/a/3587/80379) on what the
  manpage numbers mean - they are really useful)
- `:Man pri<Tab>` - command completion for manpage names
- `:Man 3 pri<Tab>` - completion "respects" the manpage section argument
- `:Man 6 <Ctrl-D>` - list all manpages from section 6

When editing `nroff` files:

- `:Man` - (without arguments) open a current `nroff` file as a manpage

When inside a manpage buffer:

- `[[` and `]]` - jump to prev/next section heading
- `Ctrl-]` - jump to manpage for a word under cursor (works nicely with
  specially highlighted references to other manpages i.e. `printf(3)`), also
  defined for other tag mappings like `g_Ctrl-]`, `Ctrl-W_Ctrl-]` etc.
- `K` - same as `Ctrl-]`
- `Ctrl-T` - jump \*back* to the previous manpage
- `gx` - open a link under cursor in a browser
  ([vim feature](http://vimdoc.sourceforge.net/htmldoc/pi_netrw.html#netrw-gx))
- `gf` - jump to a file under cursor
  ([vim feature](http://vimdoc.sourceforge.net/htmldoc/editing.html#gf),
  works nicely with C header files often found in section 2 and 3 manpages i.e.
  `<sys/socket.h>`)

Searching/grepping manpages (also see [About Mangrep](#about-mangrep)):

- `:Mangrep 1 foobar` - search for "foobar" in all section 1 manpages
- `:Mangrep foobar` - same as `:Mangrep 1 foobar` (grepping all man sections
  by default would take too long)
- `:Mangrep * foobar` - force search \*all* man sections
- `:Mangrep -i 6 foobar` - case insensitive search
- `:Mangrep 6 (foo|bar|baz)` - regex search (`Mangrep` uses `grep -E`)

Defining these mappings is possible in `.vimrc` (none are defined by default):

- `map <leader>k <Plug>(Man)` - open manpage for word under cursor in a horizontal
  split
- `map <leader>v <Plug>(Vman)` - open manpage for word under cursor in a vertial
  split

### About Mangrep

This feature is still in beta.
Please help fix the [issues](https://github.com/bruno-/vim-man/issues/).

`Mangrep` populates quickfix list with the results. While they should be
accurate, you might experience hiccups when opening those results.

Running `Mangrep`:

- the command runs in the background if you're using neovim
- The command runs in the background if you have
  [vim-dispatch](https://github.com/tpope/vim-dispatch) installed. Access the
  results with
  [`:Copen` command](https://github.com/tpope/vim-dispatch#background-builds).
- If you have vanilla vim the command will \*block* and make vim unusable
  until done (and it can take a while).<br/>
  Installing [vim-dispatch](https://github.com/tpope/vim-dispatch)
  is recommended. Or at least run `Mangrep` in another vim so your working vim
  instance stays usable.

### Installation

* vim-plug<br/>
`Plug 'bruno-/vim-man'`

* Vundle<br/>
`Plugin 'bruno-/vim-man'`

* Pathogen<br/>
`git clone git://github.com/bruno-/vim-man.git ~/.vim/bundle/vim-man`

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
