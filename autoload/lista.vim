function! lista#start(...) abort
  let context = a:0 ? a:1 : lista#context#new()
  if lista#filter#start(context)
        \ && context.cursor <= len(context.indices)
    return {
          \ 'index': context.indices[context.cursor - 1],
          \ 'items': map(
          \   copy(context.indices),
          \   { _, v -> [v, context.content[v]] }
          \ )
          \}
  else
    return { 'index': -1, 'items': [] }
  endif
endfunction
