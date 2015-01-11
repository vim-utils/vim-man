if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" Ensure Vim is not recursively invoked (man-db does this)
" when doing ctrl-[ on a man page reference.
if exists("$MANPAGER")
  let $MANPAGER = ""
endif

" allow dot and dash in manual page name.
setlocal iskeyword+=\.,-

" Add mappings, unless the user didn't want this.
if !exists("no_plugin_maps") && !exists("no_man_maps")
  if !hasmapto('<Plug>ManBS')
    nmap <buffer> <LocalLeader>h <Plug>ManBS
  endif
  nnoremap <buffer> <Plug>ManBS :%s/.\b//g<CR>:setlocal nomod<CR>''

  nnoremap <buffer> <c-]> :call man#pre_get_page(v:count)<CR>
  nnoremap <buffer> <c-t> :call man#pop_page()<CR>
endif

let b:undo_ftplugin = "setlocal iskeyword<"

" vim:set ft=vim et sw=2:
