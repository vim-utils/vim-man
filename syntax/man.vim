if exists('b:current_syntax')
  finish
endif

" Get the CTRL-H syntax to handle backspaced text
runtime! syntax/ctrlh.vim

syntax case ignore
syntax match manReference       '\f\+(\([1-9][a-z]\=\)\?)'
syntax match manTitle           '^\(\f\|:\|\s\)\+([0-9nlpo]\+[a-z]*).*'
syntax match manSectionHeading  '^[a-z][a-z ,-]*[a-z]$'
syntax match manSubHeading      '^\s\{3\}[a-z][a-z ,-]*[a-z]$'
syntax match manOptionDesc      '^\s*[+-][a-z0-9]\S*'
syntax match manLongOptionDesc  '^\s*--[a-z0-9-]\S*'
syntax match manHeaderFile      '\s<\f\+\.h>\s'
syntax match manURL `\v<(((https?|ftp|gopher)://|(mailto|file|news):)[^'  <>"]+|(www|web|w3)[a-z0-9_-]*\.[a-z0-9._-]+\.[^'  <>"]+)[a-zA-Z0-9/]`
" syntax match  manHistory         '^[a-z].*last change.*$'

" below syntax elements valid for manpages 2 & 3 only
if getline(1) =~ '^\(\f\|:\|\s\)\+([23][px]\?)'
  syntax include @cCode syntax/c.vim
  syntax match manCFuncDefinition  display '\<\h\w*\>\s*('me=e-1 contained
  syntax match manCError           display '^\s\+\[E\u\+\]' contained
  syntax region manSynopsis start='^\(LEGACY \)\?SYNOPSIS'hs=s+8 end='^\u[A-Z ]*$'me=e-12 keepend contains=manSectionHeading,@cCode,manCFuncDefinition,manHeaderFile
  syntax region manErrors   start='^ERRORS'hs=s+6 end='^\u[A-Z ]*$'me=e-30 keepend contains=manReference,manSectionHeading,manSubHeading,manHeaderFile,manCError
endif

hi def link manTitle           Title
hi def link manSectionHeading  Statement
hi def link manOptionDesc      Constant
hi def link manLongOptionDesc  Constant
hi def link manReference       PreProc
hi def link manSubHeading      Function
hi def link manCFuncDefinition Function
hi def link manHeaderFile      String
hi def link manURL             Underlined
hi def link manCError          Identifier

let b:current_syntax = 'man'

" vim:set ft=vim et sw=2:
