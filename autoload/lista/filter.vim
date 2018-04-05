let s:HASH = sha256(expand('<sfile>:p'))

function! lista#filter#start(context) abort
  let b:lista_context = a:context
  let state = lista#state#store()
  let timer = timer_start(
        \ g:lista#filter#interval,
        \ funcref('s:timer_callback'),
        \ { 'repeat': -1 },
        \)
  " Define <Plug> mappings
  execute printf('cnoremap <silent><buffer> <Plug>(lista-filter-accept) %s<CR>', s:HASH)
  cnoremap <silent><buffer><expr> <Plug>(lista-filter-prev-line) <SID>move_to_prev_line()
  cnoremap <silent><buffer><expr> <Plug>(lista-filter-next-line) <SID>move_to_next_line()
  cnoremap <silent><buffer><expr> <Plug>(lista-filter-prev-matcher) <SID>switch_to_prev_matcher()
  cnoremap <silent><buffer><expr> <Plug>(lista-filter-next-matcher) <SID>switch_to_next_matcher()
  cnoremap <silent><buffer><expr> <Plug>(lista-filter-switch-ignorecase) <SID>switch_ignorecase()
  cmap <buffer> <CR> <Plug>(lista-filter-accept)
  " Define custom mappings
  let custom_mappings = lista#custom#get().mappings
  for [lhs, rhs] in items(custom_mappings)
    execute printf('cmap <buffer> %s %s', lhs, rhs)
  endfor
  " Options
  setlocal buftype=nowrite noreadonly modifiable nofoldenable cursorline
  setlocal filetype=lista
  " Start prompt
  let accepted = 0
  try
    return (input(a:context.prompt, a:context.query)[-64:] ==# s:HASH)
  finally
    call timer_stop(timer)
    call setline(1, a:context.content)
    call lista#state#restore(state)
    cunmap <buffer> <Plug>(lista-filter-accept)
    cunmap <buffer> <Plug>(lista-filter-prev-line)
    cunmap <buffer> <Plug>(lista-filter-next-line)
    cunmap <buffer> <Plug>(lista-filter-prev-matcher)
    cunmap <buffer> <Plug>(lista-filter-next-matcher)
    cunmap <buffer> <CR>
    for lhs in keys(custom_mappings)
      execute printf('cunmap <buffer> %s', lhs)
    endfor
  endtry
endfunction

function! s:timer_callback(...) abort
  let context = b:lista_context
  let query = getcmdline()
  let matcher = context.matchers[context.matcher]
  let content = context.content
  let pattern = matcher.get_pattern(query, context.ignorecase)
  let indices = matcher.get_indices(content, query, context.ignorecase)
  " Update content
  if len(indices)
    call setline(1, map(copy(indices), { _, v -> content[v] }))
    execute printf('silent! keepjumps %d,$delete _', len(indices) + 1)
  else
    silent keepjumps %delete _
  endif
  " Update highlight
  if empty(pattern)
    silent nohlsearch
  else
    silent! execute printf(
          \ '/%s\%%(%s\)',
          \ context.ignorecase ? '\c' : '\C',
          \ pattern
          \)
  endif
  " Update context
  let context.query = query
  let context.indices = indices
  let context.cursor = max([min([context.cursor, len(indices)]), 1])
  " Update statusline
  let &l:statusline = s:statusline(context)
  " Update cursor and redraw
  call cursor(context.cursor, 1, 0)
  redraw
endfunction

function! s:statusline(context) abort
  let statusline = [
        \ '%%#ListaStatuslineFile# %s ',
        \ '%%#ListaStatuslineMiddle#%%=',
        \ '%%#ListaStatuslineMatcher# Matcher: %s (C-^ to switch) ',
        \ '%%#ListaStatuslineMatcher# Case: %s (C-_ to switch) ',
        \ '%%#ListaStatuslineIndicator# %d/%d',
        \]
  return printf(
        \ join(statusline, ''),
        \ expand('%'),
        \ a:context.matchers[a:context.matcher].name,
        \ a:context.ignorecase ? 'ignore' : 'normal',
        \ len(a:context.indices),
        \ len(a:context.content),
        \)
endfunction

function! s:move_to_prev_line() abort
  let context = b:lista_context
  let size = max([len(context.indices), 1])
  if context.cursor is# 1
    let context.cursor = context.wrap_around ? size : 1
  else
    let context.cursor -= 1
  endif
  call cursor(context.cursor, 1, 0)
  redraw
  call feedkeys(" \<C-h>", 'n')   " Stay TERM cursor on cmdline
  return ''
endfunction

function! s:move_to_next_line() abort
  let context = b:lista_context
  let size = max([len(context.indices), 1])
  if context.cursor is# size
    let context.cursor = context.wrap_around ? 1 : size
  else
    let context.cursor += 1
  endif
  call cursor(context.cursor, 1, 0)
  redraw
  call feedkeys(" \<C-h>", 'n')   " Stay TERM cursor on cmdline
  return ''
endfunction

function! s:switch_to_prev_matcher() abort
  let context = b:lista_context
  let size = len(context.matchers)
  if context.matcher is# 0
    let context.matcher = size - 1
  else
    let context.matcher -= 1
  endif
  let &l:statusline = s:statusline(context)
  redrawstatus
  call feedkeys(" \<C-h>", 'n')   " Stay TERM cursor on cmdline
  return ''
endfunction

function! s:switch_to_next_matcher() abort
  let context = b:lista_context
  let size = len(context.matchers)
  if context.matcher is# (size - 1)
    let context.matcher = 0
  else
    let context.matcher += 1
  endif
  let &l:statusline = s:statusline(context)
  redrawstatus
  call feedkeys(" \<C-h>", 'n')   " Stay TERM cursor on cmdline
  return ''
endfunction

function! s:switch_ignorecase() abort
  let context = b:lista_context
  let context.ignorecase = !context.ignorecase
  let &l:statusline = s:statusline(context)
  redrawstatus
  call feedkeys(" \<C-h>", 'n')   " Stay TERM cursor on cmdline
  return ''
endfunction


let g:lista#filter#interval = get(g:, 'lista#filter#interval', 100)
