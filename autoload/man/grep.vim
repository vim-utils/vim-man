" man#grep#run {{{1

function! man#grep#run(bang, ...)
  " argument handling and sanitization
  if a:0 ==# 1
    " just the pattern is provided
    let grep_case_insensitive = 0
    " defaulting section to 1
    let section = '1'
    let pattern = a:1

  elseif a:0 ==# 2
    " section + pattern OR grep `-i` flag + pattern
    if a:1 ==# '-i'
      " grep `-i` flag + pattern
      let grep_case_insensitive = 1
      " defaulting section to 1
      let section = '1'
      let pattern = a:1
    else
      " section + pattern
      let grep_case_insensitive = 0
      let section = man#helpers#extract_permitted_section_value(a:1)
      if section ==# ''
        " don't run an expensive grep on *all* sections if a user made a typo
        return man#helpers#error('Unknown man section '.a:1)
      endif
      let pattern = a:2
    endif

  elseif a:0 ==# 3
    " grep `-i` flag + section + pattern
    if a:1 ==# '-i'
      let grep_case_insensitive = 1
    else
      return man#helpers#error('Unknown Mangrep argument '.a:1)
    endif
    let section = man#helpers#extract_permitted_section_value(a:2)
    if section ==# ''
      " don't run an expensive grep on *all* sections if a user made a typo
      return man#helpers#error('Unknown man section '.a:2)
    endif
    let pattern = a:3

  elseif a:0 >=# 4
    return man#helpers#error('Too many arguments')
  endif
  " argument handling end

  let manpath = man#helpers#manpath()
  if manpath =~# '^\s*$'
    return
  endif
  " create new quickfix list
  call setqflist([], ' ')
  if has('nvim')
    let path_glob = man#helpers#get_path_glob(manpath, section, '*', ' ')
    call s:grep_nvim_strategy(a:bang, grep_case_insensitive, pattern, path_glob)
  elseif exists('g:loaded_dispatch')
    let path_glob = man#helpers#get_path_glob(manpath, section, '*', ' ')
    call man#grep#dispatch#run(a:bang, grep_case_insensitive, pattern, path_glob)
  else
    let path_glob = man#helpers#get_path_glob(manpath, section, '', ',')
    let matching_files = man#helpers#expand_path_glob(path_glob, '*')
    call s:grep_basic_strategy(a:bang, grep_case_insensitive, pattern, matching_files)
  endif
endfunction

" }}}
" neovim JobActivity autocmd {{{1

if has('nvim')
  augroup manGrep
    au!
    au JobActivity mangrep call man#grep#handle_async_output()
  augroup END
endif

" }}}
" s:grep_nvim_strategy {{{1

" state of the current job
let s:job_number = 0
let s:grep_not_bang = 0
let s:grep_opened_first_result = 0

function! s:grep_nvim_strategy(bang, insensitive, pattern, path_glob)
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
" man#grep#handle_async_output (neovim) {{{1

function! man#grep#handle_async_output()
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

      let buf_num = s:create_empty_buffer_for_manpage(man_name, section)
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

" }}}
" s:grep_basic_strategy {{{1

function! s:grep_basic_strategy(bang, insensitive, pattern, files)
  let $MANWIDTH = man#helpers#manwidth()
  let insensitive_flag = a:insensitive ? '-i' : ''
  for file in a:files
    let output_manfile  = '/usr/bin/man '.file.' | col -b |'
    let trim_whitespace = "sed '1 {; /^\s*$/d; }' |"
    let grep = 'grep '.insensitive_flag.' -n -E '.a:pattern
    let matches = systemlist(output_manfile . trim_whitespace . grep)
    if v:shell_error ==# 0
      " found matches
      call s:add_matches_to_quickfixlist(file, matches)
    endif
  endfor
  " by convention jumps to the first result unless mangrep is invoked with bang (!)
  if a:bang ==# 0
    cc 1
  endif
endfunction

" adds grep matches for a single manpage
function! s:add_matches_to_quickfixlist(file_path, matches)
  let man_name = man#helpers#strip_dirname_and_extension(a:file_path)
  let section = matchstr(fnamemodify(a:file_path, ':h:t'), '^\(man\|cat\)\zs.*')
  let buf_num = s:create_empty_buffer_for_manpage(man_name, section)
  for result in a:matches
    let line_num = matchstr(result, '^\d\+')
    " trimmed line content
    let line_text = matchstr(result, '^[^:]\+:\s*\zs.\{-}\ze\s*$')
    call setqflist([{'bufnr': buf_num, 'lnum': line_num, 'text': line_text}], 'a')
  endfor
endfunction

" }}}
" man#quickfix_get_page {{{1

function! man#grep#quickfix_get_page()
  let manpage_name = get(b:, 'man_name')
  let manpage_section = get(b:, 'man_section')
  set nobuflisted
  " TODO: switch to existing 'man' window or create a split
  call man#helpers#set_manpage_buffer_name(manpage_name, manpage_section)
  call man#helpers#load_manpage_text(manpage_name, manpage_section)
endfunction

" }}}
" grep helpers {{{1

function! s:create_empty_buffer_for_manpage(name, section)
  if bufnr(a:name.'('.a:section.')') >=# 0
    " buffer already exists
    return bufnr(a:name.'('.a:section.')')
  endif
  let buffer_num = bufnr(a:name.'('.a:section.')', 1)
  " saving manpage name and section as buffer variable, so they're
  " easy to get later when in the buffer
  call setbufvar(buffer_num, 'man_name', a:name)
  call setbufvar(buffer_num, 'man_section', a:section)
  exec 'au BufEnter <buffer='.buffer_num.'> call man#grep#quickfix_get_page()'
  return buffer_num
endfunction

" }}}
" man#grep#command {{{1

" TODO: can this whole command be simplified?
function! man#grep#command(path_glob, insensitive_flag, pattern)
  let do_glob = 'ls '.a:path_glob.' 2>/dev/null |'

  " NOTE: had a bug here: if the file is too long, xargs (on OS X) won't
  " perform good interpolation with '{}' strings. The last {}
  " occasionally didn't get replaced and there remained a literal '{}'

  " xargs is used to feed manpages one-by-one
  let xargs = 'xargs -I{} -n1 sh -c "'

  " inner variables execute within a shell started by xargs
  let inner_output_manfile  = '/usr/bin/man {} 2>/dev/null|col -b|'

  " if the first manpage line is blank, remove it (stupid semicolons are required)
  let inner_trim_whitespace = "sed '1 {;/^\s*$/d;}'|"
  let inner_grep            = 'grep '.a:insensitive_flag.' -nE '.a:pattern.'|'

  " prepending filename to each line of grep output, followed by a !
  let inner_append_filename = "sed 's,^,{}!,'"
  let end_quot = '"'

  return do_glob.xargs.inner_output_manfile.inner_trim_whitespace.inner_grep.inner_append_filename.end_quot
endfunction

" }}}
" vim:set ft=vim et sw=2:
