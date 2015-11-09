" Stategy for running :Mangrep command in "vanilla" vim. It blocks vim until
" the command is done.
"
" load guard {{{1

if exists('g:autoloaded_man_grep_vanilla')
  finish
endif
let g:autoloaded_man_grep_vanilla = 1

" }}}
" man#grep#vanilla#run {{{1

function! man#grep#vanilla#run(bang, insensitive, pattern, files)
  let $MANWIDTH = man#helpers#manwidth()
  let insensitive_flag = a:insensitive ? '-i' : ''
  for file in a:files
    let output_manfile  = g:vim_man_cmd.' '.file.' | col -b |'
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

" }}}
" s:add_matches_to_quickfixlist {{{1

" adds grep matches for a single manpage
function! s:add_matches_to_quickfixlist(file_path, matches)
  let man_name = man#helpers#strip_dirname_and_extension(a:file_path)
  let section = matchstr(fnamemodify(a:file_path, ':h:t'), '^\(man\|cat\)\zs.*')
  let buf_num = man#grep#create_empty_buffer(man_name, section)
  for result in a:matches
    let line_num = matchstr(result, '^\d\+')
    " trimmed line content
    let line_text = matchstr(result, '^[^:]\+:\s*\zs.\{-}\ze\s*$')
    call setqflist([{'bufnr': buf_num, 'lnum': line_num, 'text': line_text}], 'a')
  endfor
endfunction

" }}}
