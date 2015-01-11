let s:man_tag_depth = 0

let s:man_sect_arg = ""
let s:man_find_arg = "-w"
try
  if !has("win32") && $OSTYPE !~ 'cygwin\|linux' && system('uname -s') =~ "SunOS" && system('uname -r') =~ "^5"
    let s:man_sect_arg = "-s"
    let s:man_find_arg = "-l"
  endif
catch /E145:/
  " Ignore the error in restricted mode
endtry

function! man#get_page(...)
  if a:0 >= 2
    let sect = a:1
    let page = a:2
  elseif a:0 >= 1
    let sect = ""
    let page = a:1
  else
    return
  endif

  " To support:  nmap K :Man <cword>
  if page == '<cword>'
    let page = expand('<cword>')
  endif

  if sect != "" && !s:manpage_exists(sect, page)
    let sect = ""
  endif
  if !s:manpage_exists(sect, page)
    echohl ErrorMSG | echo "No manual entry for '".page."'." | echohl NONE
    return
  endif
  exec "let s:man_tag_buf_".s:man_tag_depth." = ".bufnr("%")
  exec "let s:man_tag_lin_".s:man_tag_depth." = ".line(".")
  exec "let s:man_tag_col_".s:man_tag_depth." = ".col(".")
  let s:man_tag_depth = s:man_tag_depth + 1

  " Use an existing "man" window if it exists, otherwise open a new one.
  if &filetype != "man"
    let thiswin = winnr()
    exec "norm! \<C-W>b"
    if winnr() > 1
      exec "norm! " . thiswin . "\<C-W>w"
      while 1
        if &filetype == "man"
          break
        endif
        exec "norm! \<C-W>w"
        if thiswin == winnr()
          break
        endif
      endwhile
    endif
    if &filetype != "man"
      new
      setlocal nonumber foldcolumn=0
    endif
  endif
  silent exec "edit $HOME/".page.".".sect."~"
  " Avoid warning for editing the dummy file twice
  setlocal buftype=nofile noswapfile

  setlocal modifiable nonumber norelativenumber nofoldenable
  silent keepj norm! 1GdG
  let $MANWIDTH = winwidth(0)
  silent exec "r!/usr/bin/man ".s:get_cmd_arg(sect, page)." | col -b"
  " Remove blank lines from top and bottom.
  while getline(1) =~ '^\s*$'
    silent keepj norm! ggdd
  endwhile
  while getline('$') =~ '^\s*$'
    silent keepj norm! Gdd
  endwhile
  silent keepj norm! gg
  setlocal filetype=man nomodifiable
  setlocal bufhidden=hide
  setlocal nobuflisted
endfunction

function! man#pre_get_page(cnt)
  if a:cnt == 0
    let old_isk = &iskeyword
    setlocal iskeyword+=(,)
    let str = expand("<cword>")
    let &l:iskeyword = old_isk
    let page = substitute(str, '(*\(\k\+\).*', '\1', '')
    let sect = substitute(str, '\(\k\+\)(\([^()]*\)).*', '\2', '')
    if match(sect, '^[0-9 ]\+$') == -1
      let sect = ""
    endif
    if sect == page
      let sect = ""
    endif
  else
    let sect = a:cnt
    let page = expand("<cword>")
  endif
  call man#get_page(sect, page)
endfunction

function! man#pop_page()
  if s:man_tag_depth > 0
    let s:man_tag_depth = s:man_tag_depth - 1
    exec "let s:man_tag_buf=s:man_tag_buf_".s:man_tag_depth
    exec "let s:man_tag_lin=s:man_tag_lin_".s:man_tag_depth
    exec "let s:man_tag_col=s:man_tag_col_".s:man_tag_depth
    exec s:man_tag_buf."b"
    exec s:man_tag_lin
    exec "norm ".s:man_tag_col."|"
    exec "unlet s:man_tag_buf_".s:man_tag_depth
    exec "unlet s:man_tag_lin_".s:man_tag_depth
    exec "unlet s:man_tag_col_".s:man_tag_depth
    unlet s:man_tag_buf s:man_tag_lin s:man_tag_col
  endif
endfunction

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

" vim:set ft=vim et sw=2:
