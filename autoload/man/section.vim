" load guard {{{1

if exists('g:autoloaded_man_section')
  finish
endif
let g:autoloaded_man_section = 1

" }}}
" man#section#move {{{1

function! man#section#move(direction, mode, count)
  norm! m'
  if a:mode ==# 'v'
    norm! gv
  endif
  let i = 0
  while i < a:count
    let i += 1
    " saving current position
    let line = line('.')
    let col  = col('.')
    let pos = search('^\a\+', 'W'.a:direction)
    " if there are no more matches, return to last position
    if pos == 0
      call cursor(line, col)
      return
    endif
  endwhile
endfunction

" }}}
" vim:set ft=vim et sw=2:
