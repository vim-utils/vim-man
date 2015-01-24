" load guard {{{1

if exists('g:autoloaded_man_completion')
  finish
endif
let g:autoloaded_man_completion = 1

" }}}
" man#completion#run {{{1

function! man#completion#run(A, L, P)
  let manpath = man#helpers#manpath()
  if manpath =~# '^\s*$'
    return []
  endif
  let section = s:get_manpage_section(a:L, a:P)
  let path_glob = man#helpers#get_path_glob(manpath, section, '', ',')
  let matching_files = man#helpers#expand_path_glob(path_glob, a:A)
  return s:strip_file_names(matching_files)
endfunction

" extracts the manpage section number (if there is one) from the command
function! s:get_manpage_section(line, cursor_position)
  " extracting section argument from the line
  let leading_line = strpart(a:line, 0, a:cursor_position)
  let section_arg = matchstr(leading_line, '^\s*\S\+\s\+\zs\S\+\ze\s\+')
  if !empty(section_arg)
    return man#helpers#extract_permitted_section_value(section_arg)
  endif
  " no section arg or extracted section cannot be used for man dir name globbing
  return ''
endfunction

" strips file names so they correspond manpage names
function! s:strip_file_names(matching_files)
  if empty(a:matching_files)
    return []
  else
    let matches = []
    let len = 0
    for manpage_path in a:matching_files
      " since already looping also count list length
      let len += 1
      call add(matches, man#helpers#strip_dirname_and_extension(manpage_path))
    endfor
    " remove duplicates from small lists (it takes noticeably longer
    " and is less relevant for large lists)
    return len > 500 ? matches : filter(matches, 'index(matches, v:val, v:key+1)==-1')
  endif
endfunction

" }}}
" vim:set ft=vim et sw=2:
