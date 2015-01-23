" strategy to utilize vim-dispatch's plugin async jobs for :Mangrep command
"
" man#grep#dispatch {{{1

function! man#grep#dispatch#run(bang, insensitive, pattern, path_glob)
  let insensitive_flag = a:insensitive ? '-i' : ''
  let command = man#grep#command(a:path_glob, insensitive_flag, a:pattern)
  " run a Make command, but do not overrwrite user-set compiler
  call s:set_compiler(command)
  Make
  call s:restore_compiler()
endfunction

" }}}
" s:set_compiler {{{1

" does everything a regular call to :compiler would do
function! s:set_compiler(command)
  let cpo_save = &cpo
  set cpo-=C
  " save variables for later restore
  let s:makeprg = &makeprg
  let s:efm = &errorformat
  let &makeprg = a:command
  let &errorformat = '%f!%l:%m'
  let &cpo = cpo_save
endfunction

" }}}
" s:restore_compiler {{{1

function! s:restore_compiler()
  let cpo_save = &cpo
  set cpo-=C
  let &makeprg = s:makeprg
  let &errorformat = s:efm
  let &cpo = cpo_save
endfunction

" }}}

" vim:set ft=vim et sw=2:
