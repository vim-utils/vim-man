" strategy to utilize NeoVim's async jobs for :Mangrep command
"
" load guard {{{1

if exists('g:autoloaded_man_grep_nvim')
  finish
endif
let g:autoloaded_man_grep_nvim = 1

" }}}
" neovim current async job state {{{1

" these variables keep the state of neovim's current async job
let s:job_number = 0
let s:grep_not_bang = 0
let s:grep_opened_first_result = 0

" }}}
" neovim JobActivity autocmd {{{1

if has('nvim')
  augroup manGrepNvim
    au!
    au JobActivity mangrep call man#grep#nvim#handle_async_output()
  augroup END
endif

" }}}
" man#grep#nvim#run {{{1

function! man#grep#nvim#run(bang, insensitive, pattern, path_glob)
  echom 'Mangrep command started in background'

  " stop currently running Mangrep if any
  try
    call jobstop(s:job_number)
    let s:grep_opened_first_result = 0
  catch
  endtry

  " By convention, grep "jumps" to the first result unless the command is
  " invoked with bang (!)
  let s:grep_not_bang = a:bang > 0 ? 0 : 1

  let $MANWIDTH = man#helpers#manwidth()
  let insensitive_flag = a:insensitive ? '-i' : ''

  let command = man#grep#command(a:path_glob, insensitive_flag, a:pattern)
  let s:job_number = jobstart('mangrep', 'sh', ['-c', command])
endfunction

" }}}
" man#grep#nvim#handle_async_output {{{1

function! man#grep#nvim#handle_async_output()
  " we're not interested in the output of some lagging Mangrep process that
  " should've already been dead
  if s:not_currently_registered_job(v:job_data[0])
    return
  end

  if v:job_data[1] ==# 'stdout'
    for one_line in v:job_data[2]
      " line format: 'manpage_file_name!line_number:line_text'
      " example: '/usr/share/man/man1/echo.1!123: line match example'
      " ! (exclamation mark) is used as a delimiter between a filename and " line num
      let manpage_file_name = matchstr(one_line, '^[^!]\+')
      let line_number = matchstr(one_line, '^[^!]\+!\zs\d\+')
      let line_text = matchstr(one_line, '^[^!]\+![^:]\+:\s*\zs.\{-}\ze\s*$')

      " example input: '/usr/share/man/man1/echo.1'
      " get manpage name: 'echo' and man section '1'
      let man_name = man#helpers#strip_dirname_and_extension(manpage_file_name)
      let section = matchstr(fnamemodify(manpage_file_name, ':h:t'), '^\(man\|cat\)\zs.*')

      let buf_num = man#grep#create_empty_buffer(man_name, section)
      call setqflist([{'bufnr': buf_num, 'lnum': line_number, 'text': line_text}], 'a')

      " jump to first result if command not invoked with bang
      if s:grep_not_bang > 0 && s:grep_opened_first_result ==# 0
        let s:grep_opened_first_result = 1
        cc 1
        " TODO: for some reason cc 1 does not trigger autocmd for loading man
        " page into current buffer, so we're doing it manually
        call man#grep#quickfix_get_page()
        exec 'norm! '.line_number.'G'
      endif
    endfor
  elseif v:job_data[1] ==# 'exit'
    echom 'Mangrep command done'
  endif
endfunction

function! s:not_currently_registered_job(job_num)
  return a:job_num !=# s:job_number
endfunction

" }}}
