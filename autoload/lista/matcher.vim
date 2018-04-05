function! lista#matcher#all() abort
  return {
        \ 'name': 'all',
        \ 'get_pattern': funcref('s:all_get_pattern'),
        \ 'get_indices': funcref('s:all_get_indices'),
        \}
endfunction

function! lista#matcher#fuzzy() abort
  return {
        \ 'name': 'fuzzy',
        \ 'get_pattern': funcref('s:fuzzy_get_pattern'),
        \ 'get_indices': funcref('s:fuzzy_get_indices'),
        \}
endfunction

function! s:escape_pattern(str) abort
  return escape(a:str, '^$~.*[]\')
endfunction

" all
function! s:all_get_pattern(query, ignorecase) abort
  if a:ignorecase
    return join(map(split(tolower(a:query), ' '), 's:escape_pattern(v:val)'), '\|')
  else
    return join(map(split(a:query, ' '), 's:escape_pattern(v:val)'), '\|')
  endif
endfunction

function! s:all_get_indices(items, query, ignorecase) abort
  if len(a:items) is# 0
    return []
  endif
  let indices = range(0, len(a:items) - 1)
  let query = a:ignorecase ? tolower(a:query) : a:query
  let Wrap = a:ignorecase ? function('tolower') : { v -> v }
  for term in split(query, ' ')
    call filter(
          \ indices,
          \ { _, v -> stridx(Wrap(a:items[v]), term) isnot# -1 },
          \)
  endfor
  return indices
endfunction

" fuzzy
function! s:fuzzy_get_pattern(query, ignorecase) abort
  let chars = map(
        \ split(a:ignorecase ? tolower(a:query) : a:query, '\zs'),
        \ 's:escape_pattern(v:val)'
        \)
  let patterns = map(chars, { _, v -> printf('%s[^%s]\{-}', v, v)})
  return join(patterns, '')
endfunction

function! s:fuzzy_get_indices(items, query, ignorecase) abort
  if len(a:items) is# 0
    return []
  endif
  let pattern = (a:ignorecase ? '\c' : '\C') . s:fuzzy_get_pattern(a:query, a:ignorecase)
  let indices = range(0, len(a:items) - 1)
  return filter(
        \ indices,
        \ { _, v -> a:items[v] =~# pattern }
        \)
endfunction
