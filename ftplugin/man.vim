if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

" Ensure Vim is not recursively invoked (man-db does this)
" when doing ctrl-] on a man page reference.
if exists('$MANPAGER')
  let $MANPAGER = ''
endif

" buffer local options {{{1

" allow dot and dash in manual page name.
setlocal iskeyword+=\.,-

setlocal nonumber
setlocal norelativenumber
setlocal foldcolumn=0
setlocal nofoldenable
setlocal nolist

" tabs in man pages are 8 spaces
setlocal tabstop=8

" scratch buffer options
setlocal buftype=nofile
setlocal bufhidden=hide
setlocal nobuflisted
setlocal noswapfile

" }}}
" mappings {{{1

nnoremap <silent> <buffer> K           :call man#get_page_from_cword('horizontal', v:count)<CR>
" all tag mappings are defined for completeness and they all perform the same action
nnoremap <silent> <buffer> <C-]>       :call man#get_page_from_cword('horizontal', v:count)<CR>
nnoremap <silent> <buffer> g<C-]>      :call man#get_page_from_cword('horizontal', v:count)<CR>
nnoremap <silent> <buffer> g]          :call man#get_page_from_cword('horizontal', v:count)<CR>
nnoremap <silent> <buffer> <C-W>]      :call man#get_page_from_cword('horizontal', v:count)<CR>
nnoremap <silent> <buffer> <C-W><C-]>  :call man#get_page_from_cword('horizontal', v:count)<CR>
nnoremap <silent> <buffer> <C-W>g<C-]> :call man#get_page_from_cword('horizontal', v:count)<CR>
nnoremap <silent> <buffer> <C-W>g]     :call man#get_page_from_cword('horizontal', v:count)<CR>
nnoremap <silent> <buffer> <C-W>}      :call man#get_page_from_cword('horizontal', v:count)<CR>
nnoremap <silent> <buffer> <C-W>g}     :call man#get_page_from_cword('horizontal', v:count)<CR>

nnoremap <silent> <buffer> <C-T> :call man#pop_page()<CR>

nnoremap <silent> <buffer> [[ :<C-U>call man#section#move('b', 'n', v:count1)<CR>
nnoremap <silent> <buffer> ]] :<C-U>call man#section#move('' , 'n', v:count1)<CR>
xnoremap <silent> <buffer> [[ :<C-U>call man#section#move('b', 'v', v:count1)<CR>
xnoremap <silent> <buffer> ]] :<C-U>call man#section#move('' , 'v', v:count1)<CR>

nnoremap <silent> <buffer> q :q<CR>
nnoremap <buffer> g/ /^\s*\zs

" }}}

let b:undo_ftplugin = 'setlocal iskeyword<'

" vim:set ft=vim et sw=2:
