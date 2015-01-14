" variable initialization {{{1

let s:man_tag_depth = 0

let s:man_sect_arg = ''
let s:man_find_arg = '-w'
try
  if !has('win32') && $OSTYPE !~ 'cygwin\|linux' && system('uname -s') =~ 'SunOS' && system('uname -r') =~ '^5'
    let s:man_sect_arg = '-s'
    let s:man_find_arg = '-l'
  endif
catch /E145:/
  " Ignore the error in restricted mode
endtry

" }}}
" man#get_page {{{1

function! man#get_page(split_type, ...)
  if a:0 == 1
    let sect = ''
    let page = a:1
  elseif a:0 >= 2
    let sect = a:1
    let page = a:2
  else
    return
  endif

  " To support:  nmap K :Man <cword>
  if page == '<cword>'
    let page = expand('<cword>')
  endif

  if sect != '' && !s:manpage_exists(sect, page)
    let sect = ''
  endif
  if !s:manpage_exists(sect, page)
    echohl ErrorMSG | echo "No manual entry for '".page."'." | echohl NONE
    return
  endif

  call s:update_man_tag_variables()
  call s:get_new_or_existing_man_window(a:split_type)
  call s:set_manpage_buffer_name(page, sect)
  call s:load_manpage_text(page, sect)
endfunction

" }}}
" man#get_page_from_cword {{{1

function! man#get_page_from_cword(cnt)
  if a:cnt == 0
    " trying to determine manpage section from a word like this 'printf(3)'
    let old_isk = &iskeyword
    setlocal iskeyword+=(,)
    let str = expand('<cword>')
    let &l:iskeyword = old_isk
    let page = substitute(str, '(*\(\k\+\).*', '\1', '')
    let sect = substitute(str, '\(\k\+\)(\([^()]*\)).*', '\2', '')
    if sect !~# '^[0-9 ]\+$' || sect == page
      let sect = ''
    endif
  else
    let sect = a:cnt
    let page = expand('<cword>')
  endif
  call man#get_page('horizontal', sect, page)
endfunction

" }}}
" man#pop_page {{{1

function! man#pop_page()
  if s:man_tag_depth <= 0
    return
  endif
  let s:man_tag_depth -= 1
  let buffer = s:man_tag_buf_{s:man_tag_depth}
  let line   = s:man_tag_lin_{s:man_tag_depth}
  let column = s:man_tag_col_{s:man_tag_depth}
  " jumps to exact buffer, line and column
  exec buffer.'b'
  exec line
  exec 'norm! '.column.'|'
  unlet s:man_tag_buf_{s:man_tag_depth}
  unlet s:man_tag_lin_{s:man_tag_depth}
  unlet s:man_tag_col_{s:man_tag_depth}
endfunction

" }}}
" man#section_movement {{{1

function! man#section_movement(direction, mode, count)
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
    let pos = search('^\S\+', 'W'.a:direction)
    " if there are no more matches, return to last position
    if pos == 0
      call cursor(line, col)
      return
    endif
  endwhile
endfunction

" }}}
" man#command_completion {{{1

function! man#command_completion(A, L, P)
  let manpath = s:get_manpath()
  if manpath =~# '^\s*$'
    return []
  endif
  let section = s:get_manpage_section(a:L)
  let path_glob = s:get_path_glob(manpath, section)
  let matching_files = s:expand_path_glob(path_glob, a:A)
  return s:strip_file_names(matching_files)
endfunction

" extracts the manpage section number (if there is one) from the command
function! s:get_manpage_section(line)
  let matched_number = matchstr(a:line, '^\s*\S\+\s\+\zs\d\S*')
  " section numbers can be only single digits 1 to 9
  if matched_number =~# '^[1-9]$'
    return matched_number
  else
    return ''
  endif
endfunction

" fetches a colon separated list of paths where manpages are stored
function! s:get_manpath()
  " We don't expect manpath to change, so after first invocation it's
  " saved/cached in a script variable to speed things up on later invocations.
  if !exists('s:manpath')
    " perform a series of commands until manpath is found
    let s:manpath = system('manpath 2>/dev/null')
    if s:manpath ==# ''
      let s:manpath = system('man '.s:man_find_arg.' 2>/dev/null')
      if s:manpath ==# '' && exists('$MANPATH')
        let s:manpath = $MANPATH
      endif
    endif
    " strip trailing newline for output from the shell
    let s:manpath = substitute(s:manpath, '\n$', '', '')
  endif
  return s:manpath
endfunction

" creates a string containing shell globs suitable to finding matching manpages
function! s:get_path_glob(manpath, section)
  let section_part = empty(a:section) ? '*' : a:section
  let man_globs = substitute(a:manpath.':', ':', '/*man'.section_part.'/,', 'g')
  let cat_globs = substitute(a:manpath.':', ':', '/*cat'.section_part.'/,', 'g')
  " remove one unecessary comma from the end
  let cat_globs = substitute(cat_globs, ',$', '', '')
  return man_globs.cat_globs
endfunction

" path glob expansion to get filenames
function! s:expand_path_glob(path_glob, manpage_prefix)
  let manpage_part = empty(a:manpage_prefix) ? '*' : a:manpage_prefix.'*'
  return globpath(a:path_glob, manpage_part, 1, 1)
endfunction

" strips file names so they correspond manpage names
function! s:strip_file_names(matching_files)
  if empty(a:matching_files)
    return []
  else
    let matches = []
    for manpage_path in a:matching_files
      " first strips the directory name from the match, then the extension
      call extend(matches, [substitute(fnamemodify(manpage_path, ':t'), '\.\d\D*$', '', '')])
    endfor
    return matches
  endif
endfunction

" }}}
" helper functions {{{1

function! s:get_cmd_arg(sect, page)
  if a:sect == ''
    return a:page
  else
    return s:man_sect_arg.' '.a:sect.' '.a:page
  endif
endfunction

function! s:manpage_exists(sect, page)
  let where = system('/usr/bin/man '.s:man_find_arg.' '.s:get_cmd_arg(a:sect, a:page))
  if where !~# '^\s*/'
    " result does not look like a file path
    return 0
  else
    " found a manpage
    return 1
  endif
endfunction

function! s:remove_blank_lines_from_top_and_bottom()
  while getline(1) =~ '^\s*$'
    silent keepj norm! ggdd
  endwhile
  while getline('$') =~ '^\s*$'
    silent keepj norm! Gdd
  endwhile
  silent keepj norm! gg
endfunction

function! s:set_manpage_buffer_name(page, section)
  if a:section
    silent exec 'edit '.a:page.'('.a:section.')\ manpage'
  else
    silent exec 'edit '.a:page.'\ manpage'
  endif
endfunction

function! s:load_manpage_text(page, section)
  setlocal modifiable
  silent keepj norm! 1GdG
  let $MANWIDTH = winwidth(0)
  silent exec 'r!/usr/bin/man '.s:get_cmd_arg(a:section, a:page).' | col -b'
  call s:remove_blank_lines_from_top_and_bottom()
  setlocal filetype=man
  setlocal nomodifiable
endfunction

function! s:get_new_or_existing_man_window(split_type)
  if &filetype != 'man'
    let thiswin = winnr()
    exec "norm! \<C-W>b"
    if winnr() > 1
      exec 'norm! '.thiswin."\<C-W>w"
      while 1
        if &filetype == 'man'
          break
        endif
        exec "norm! \<C-W>w"
        if thiswin == winnr()
          break
        endif
      endwhile
    endif
    if &filetype != 'man'
      if a:split_type == 'vertical'
        vnew
      else
        new
      endif
    endif
  endif
endfunction

function! s:update_man_tag_variables()
  let s:man_tag_buf_{s:man_tag_depth} = bufnr('%')
  let s:man_tag_lin_{s:man_tag_depth} = line('.')
  let s:man_tag_col_{s:man_tag_depth} = col('.')
  let s:man_tag_depth += 1
endfunction

" }}}

" vim:set ft=vim et sw=2:
