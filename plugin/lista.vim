if exists('g:loaded_lista')
  finish
endif
let g:loaded_lista = 1

command! Lista call lista#start()
command! ListaResume call lista#start({ 'resume': 1 })
command! ListaCursorWord call lista#start({ 'query': expand('<cword>') })
