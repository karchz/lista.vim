function! lista#matcher#all#new() abort
  return {
        \ 'name': 'all',
        \ 'pattern': funcref('s:pattern'),
        \ 'filter': funcref('s:filter'),
        \}
endfunction


function! s:escape_pattern(str) abort
  return escape(a:str, '^$~.*[]\')
endfunction

function! s:pattern(query, ignorecase) abort
  if a:ignorecase
    return join(map(split(tolower(a:query), ' '), 's:escape_pattern(v:val)'), '\|')
  else
    return join(map(split(a:query, ' '), 's:escape_pattern(v:val)'), '\|')
  endif
endfunction

function! s:filter(items, query, ignorecase) abort
  if len(a:items) is# 0
    return []
  endif
  let indices = range(0, len(a:items) - 1)
  let query = a:ignorecase ? tolower(a:query) : a:query
  let Wrap = a:ignorecase ? function('tolower') : { v -> v }
  for term in split(query, ' ')
    call filter(
          \ indices,
          \ 'stridx(Wrap(a:items[v:val]), term) isnot# -1',
          \)
  endfor
  return indices
endfunction
