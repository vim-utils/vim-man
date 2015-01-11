" Vim filetype plugin file
" Language: man
" Maintainer: SungHyun Nam <goweol@gmail.com>
" Last Change: 2013 Jul 17

if exists('g:loaded_man') && g:loaded_man
  finish
endif
let g:loaded_man = 1

let s:save_cpo = &cpo
set cpo&vim

if exists(":Man") != 2
  com -nargs=+ Man call man#get_page(<f-args>)
  nmap <Leader>K :call man#pre_get_page(0)<CR>
endif

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set ft=vim et sw=2:
