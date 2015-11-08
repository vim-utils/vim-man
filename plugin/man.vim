if exists('g:loaded_vim_utils_man') && g:loaded_vim_utils_man
  finish
endif
let g:loaded_vim_utils_man = 1

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:vim_man_cmd')
  let g:vim_man_cmd='/usr/bin/man'
endif

if !exists('g:man_split_type')
  let g:man_split_type = 'horizontal'
endif

command! -nargs=* -bar -complete=customlist,man#completion#run Man  call man#get_page(g:man_split_type, <f-args>)
command! -nargs=* -bar -complete=customlist,man#completion#run Sman call man#get_page('horizontal', <f-args>)
command! -nargs=* -bar -complete=customlist,man#completion#run Vman call man#get_page('vertical',   <f-args>)
command! -nargs=* -bar -complete=customlist,man#completion#run Tman call man#get_page('tab',        <f-args>)

command! -nargs=+ -bang Mangrep call man#grep#run(<bang>0, <f-args>)

" map a key to open a manpage for word under cursor, example: map ,k <Plug>(Man)
nnoremap <silent> <Plug>(Man)  :<C-U>call man#get_page_from_cword(g:man_split_type, v:count)<CR>
nnoremap <silent> <Plug>(Sman) :<C-U>call man#get_page_from_cword('horizontal', v:count)<CR>
nnoremap <silent> <Plug>(Vman) :<C-U>call man#get_page_from_cword('vertical',   v:count)<CR>

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set ft=vim et sw=2:
