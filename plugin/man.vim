if exists('g:loaded_man') && g:loaded_man
  finish
endif
let g:loaded_man = 1

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=* -bar -complete=customlist,man#command_completion Man  call man#get_page('horizontal', <f-args>)
command! -nargs=* -bar -complete=customlist,man#command_completion Sman call man#get_page('horizontal', <f-args>)
command! -nargs=* -bar -complete=customlist,man#command_completion Vman call man#get_page('vertical',   <f-args>)

" map a key to open a manpage for word under cursor, example: map ,k <Plug>(Man)
nnoremap <silent> <Plug>(Man) :<C-U>call man#get_page_from_cword(0)<CR>

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set ft=vim et sw=2:
