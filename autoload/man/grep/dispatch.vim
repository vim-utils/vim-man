" strategy to utilize vim-dispatch's plugin async jobs for :Mangrep command
"
" man#grep#dispatch {{{1

function! man#grep#dispatch#run(bang, insensitive, pattern, path_glob)
  let bang = a:bang ? '!' : ''
  let insensitive_flag = a:insensitive ? '-i' : ''
  let command = man#grep#command(a:path_glob, insensitive_flag, a:pattern)
  call s:compiler(command)
  exec(':Make'.bang)
endfunction

" }}}
" s:compiler {{{1

" does everything a regular call to :compiler would do
function! s:compiler(command)
  let cpo_save = &cpo
  set cpo-=C

  let &makeprg = a:command
  let &errorformat='%f!%l:%m'

  let &cpo = cpo_save
endfunction

" }}}

" vim:set ft=vim et sw=2:
