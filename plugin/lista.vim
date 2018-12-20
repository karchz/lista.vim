if exists('g:loaded_lista')
  finish
endif
let g:loaded_lista = 1

function! s:Lista(options) abort
  let query = get(a:options, 'query', v:null)
  let resume = get(a:options, 'resume', 0)
  let context = resume && exists('b:lista_context')
        \ ? b:lista_context
        \ : lista#context#new()
  if query isnot# v:null
    let context.query = query
  endif
  let result = lista#start(context)
  if result.index isnot# -1
    call cursor(result.index + 1, col('.'), 0)
    normal! zvzz
  endif
endfunction

command! Lista call s:Lista({})
command! ListaResume call s:Lista({ 'resume': 1 })
command! ListaCursorWord call s:Lista({ 'query': expand('<cword>') })
