if exists('b:current_syntax')
  finish
endif

syntax clear
syntax match ListaBase /.*/
syntax match ListaLineNr /^\s*\d\+ /

function! s:define_highlights() abort
  highlight default link ListaStatuslineFile        Comment
  highlight default link ListaStatuslineMiddle      None
  highlight default link ListaStatuslineMatcher     Statement
  highlight default link ListaStatuslineIndicator   Tag
  highlight default link ListaBase   Comment
  highlight default link ListaLineNr LineNr
endfunction

augroup lista_syntax_internal
  autocmd! * <buffer>
  autocmd ColorScheme * call s:define_highlights()
augroup END

call s:define_highlights()
let b:current_syntax = 'lista'
