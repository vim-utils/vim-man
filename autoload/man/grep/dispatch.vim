" strategy to utilize vim-dispatch's plugin async jobs for :Mangrep command
"
" load guard {{{1

if exists('g:autoloaded_man_grep_dispatch')
  finish
endif
let g:autoloaded_man_grep_dispatch = 1

" }}}
" man#grep#dispatch {{{1

function! man#grep#dispatch#run(bang, insensitive, pattern, path_glob)
  let insensitive_flag = a:insensitive ? '-i' : ''
  let command = man#grep#command(a:path_glob, insensitive_flag, a:pattern)
  " run a Make command, but do not overrwrite user-set compiler
  call s:set_compiler(command)
  Make!
  call s:restore_compiler()
  let s:enable_mangrep_buffer_creation = 1
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
  let &errorformat = '%*[^!]/man%t/%f!%l:%m,%*[^!]/cat%t/%f!%l:%m'
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
" manGrepDispatch autocommand {{{1

augroup manGrepDispatch
  au!
  " sets up buffers to open manpages when quickfixlist is opened with :Copen
  au QuickFixCmdPost cgetfile call s:create_buffers_for_quicklist_entries()

  " disable quickfix buffer manipulation when another vim-dispatch command is run
  au QuickFixCmdPre dispatch-make let s:enable_mangrep_buffer_creation = 0
augroup END

function! s:create_buffers_for_quicklist_entries()
  if !s:enable_mangrep_buffer_creation
    return
  endif
  for entry in getqflist()
    let buffer_num = entry['bufnr']
    let section = entry['type']
    if buffer_num ==# 0 || !empty(getbufvar(buffer_num, 'man_name'))
      " early exit, buffer_num is wrong or buffer already set
      continue
    else
      let name = man#helpers#strip_extension(bufname(buffer_num))
      call man#grep#setup_manpage_buffer(buffer_num, name, section)
    endif
  endfor
endfunction

" }}}

" vim:set ft=vim et sw=2:
