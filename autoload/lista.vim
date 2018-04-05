function! lista#start(...) abort
  let options = extend({
        \ 'resume': 0,
        \ 'query': '',
        \}, a:0 ? a:1 : {},
        \)
  if options.resume && exists('b:lista_context')
    let context = b:lista_context
  else
    let context = lista#context#new()
    let context.query = options.query
  endif
  let accepted = lista#filter#start(context)
  if accepted && context.cursor <= len(context.indices)
    let b:lista_context = context
    let index = context.indices[context.cursor - 1]
    call cursor(index + 1, col('.'), 0)
    normal! zvzz
  endif
endfunction
