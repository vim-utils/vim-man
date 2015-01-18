" man#grep#run {{{1

function! man#grep#run(...)
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
  let path_glob = man#helpers#get_path_glob(manpath, section)
  let matching_files = man#helpers#expand_path_glob(path_glob, '*')
  " create new quickfix list
  call setqflist([], ' ')
  call s:grep_man_files(grep_case_insensitive, pattern, matching_files)
endfunction

function! s:grep_man_files(insensitive, pattern, files)
  let $MANWIDTH = man#helpers#manwidth()
  let insensitive_flag = a:insensitive ? '-i' : ''
  for file in a:files
    let output_manfile  = '/usr/bin/man '.file.' | col -b |'
    let trim_whitespace = "sed '1 {\n /^[:space:]*$/d \n}' |"
    let grep = 'grep '.insensitive_flag.' -n -E '.a:pattern
    let matches = systemlist(output_manfile . trim_whitespace . grep)
    if v:shell_error ==# 0
      " found matches
      call s:add_matches_to_quickfixlist(a:pattern, file, matches)
    endif
  endfor
endfunction

" adds grep matches for a single manpage
function! s:add_matches_to_quickfixlist(pattern, file_path, matches)
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
