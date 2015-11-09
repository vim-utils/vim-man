" load guard {{{1

if exists('g:autoloaded_man_grep')
  finish
endif
let g:autoloaded_man_grep = 1

" }}}
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
    " strategy for running :Mangrep with neovim's async job
    let path_glob = man#helpers#get_path_glob(manpath, section, '*', ' ')
    call man#grep#nvim#run(a:bang, grep_case_insensitive, pattern, path_glob)
  elseif exists('g:loaded_dispatch')

    " strategy for running :Mangrep with vim-dispatch async job
    let path_glob = man#helpers#get_path_glob(manpath, section, '*', ' ')
    call man#grep#dispatch#run(a:bang, grep_case_insensitive, pattern, path_glob)
  else

    " Run :Mangrep command in plain old vim. It blocks until the job is done.
    let path_glob = man#helpers#get_path_glob(manpath, section, '', ',')
    let matching_files = man#helpers#expand_path_glob(path_glob, '*')
    call man#grep#vanilla#run(a:bang, grep_case_insensitive, pattern, matching_files)
  endif
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
" man#grep#create_empty_buffer {{{1

function! man#grep#create_empty_buffer(name, section)
  let buffer_name = a:name.'('.a:section.')'
  if bufnr(buffer_name) >=# 0
    " buffer already exists
    return bufnr(buffer_name)
  endif
  let buffer_num = bufnr(buffer_name, 1)
  call man#grep#setup_manpage_buffer(buffer_num, a:name, a:section)
  return buffer_num
endfunction

" }}}
" man#grep#setup_manpage_buffer {{{1

" saving manpage name and section as buffer variable, so they're
" easy to get later when in the buffer
function! man#grep#setup_manpage_buffer(buffer_num, name, section)
  call setbufvar(a:buffer_num, 'man_name', a:name)
  call setbufvar(a:buffer_num, 'man_section', a:section)
  exec 'au BufEnter <buffer='.a:buffer_num.'> call man#grep#quickfix_get_page()'
endfunction

" }}}
" man#grep#command {{{1

" TODO: can this whole command be simplified?
function! man#grep#command(path_glob, insensitive_flag, pattern)
  let command = 'ls '.a:path_glob.' 2>/dev/null |'
  " xargs is used to feed manpages one-by-one
  let command .= 'xargs -I{} -n1 sh -c "manpage={};'
  " inner variables execute within a shell started by xargs
  let command .= g:vim_man_cmd.' \$manpage 2>/dev/null|col -b|'
  " if the first manpage line is blank, remove it (stupid semicolons are required)
  let command .= "sed '1 {;/^\s*$/d;}'|"
  let command .= 'grep '.a:insensitive_flag.' -nE '.a:pattern.'|'
  " prepending filename to each line of grep output, followed by a !
  let command .= 'sed "s,^,\$manpage!,"'
  let command .= '"'
  return command
endfunction

" }}}
" vim:set ft=vim et sw=2:
