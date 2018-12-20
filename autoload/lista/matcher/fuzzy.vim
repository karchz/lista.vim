function! lista#matcher#fuzzy#new() abort
  return {
        \ 'name': 'fuzzy',
        \ 'pattern': funcref('s:pattern'),
        \ 'filter': funcref('s:filter'),
        \}
endfunction

function! s:escape_pattern(str) abort
  return escape(a:str, '^$~.*[]\')
endfunction

function! s:pattern(query, ignorecase) abort
  let chars = map(
        \ split(a:ignorecase ? tolower(a:query) : a:query, '\zs'),
        \ 's:escape_pattern(v:val)'
        \)
  let patterns = map(chars, { _, v -> printf('%s[^%s]\{-}', v, v)})
  return join(patterns, '')
endfunction

function! s:filter(items, query, ignorecase) abort
  if len(a:items) is# 0
    return []
  endif
  let pattern = (a:ignorecase ? '\c' : '\C') . s:pattern(a:query, a:ignorecase)
  let indices = range(0, len(a:items) - 1)
  return filter(
        \ indices,
        \ 'a:items[v:val] =~# pattern',
        \)
endfunction
