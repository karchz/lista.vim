let s:HASH = sha256(expand('<sfile>:p'))

function! lista#filter#start(context) abort
  let a:context.cursor = line('.')
  let bufnr = bufnr('%')
  let bufhidden = &bufhidden
  let &bufhidden = 'hide'
  execute 'keepalt keepjumps edit' fnameescape(bufname)
  let bufname = printf('lista://%s', bufname('%'))
  execute printf('cnoremap <silent><buffer> <Plug>(lista-accept) %s<CR>', s:HASH)
  cnoremap <silent><buffer><expr> <Plug>(lista-prev-line) <SID>move_to_prev_line()
  cnoremap <silent><buffer><expr> <Plug>(lista-next-line) <SID>move_to_next_line()
  cnoremap <silent><buffer><expr> <Plug>(lista-prev-matcher) <SID>switch_to_prev_matcher()
  cnoremap <silent><buffer><expr> <Plug>(lista-next-matcher) <SID>switch_to_next_matcher()
  cnoremap <silent><buffer><expr> <Plug>(lista-switch-ignorecase) <SID>switch_ignorecase()
  setlocal buftype=nofile bufhidden=wipe undolevels=-1
  setlocal noswapfile nobuflisted
  setlocal filetype=lista

  let b:context = a:context
  let timer = timer_start(
        \ a:context.interval,
        \ funcref('s:timer_callback', [bufnr('%')]),
        \ { 'repeat': -1 },
        \)
  try
    call s:print_content(a:context.indices, a:context.content)
    call cursor(a:context.cursor, 1, 0)
    redraw
    return (input(a:context.prompt, a:context.query)[-64:] ==# s:HASH)
  finally
    call timer_stop(timer)
    execute 'keepalt keepjumps buffer' bufnr
    let &bufhidden = bufhidden
    redraw
  endtry
endfunction

function! s:print_content(indices, content) abort
  if empty(a:indices)
    silent keepjumps %delete _
    return
  endif
  let digit = len(len(a:content) . '')
  let format = printf('%%%dd %%s', digit)
  let content = map(
        \ copy(a:indices),
        \ { _, v -> printf(format, v + 1, a:content[v]) },
        \)
  call setline(1, content)
  execute printf('silent! keepjumps %d,$delete _', len(a:indices) + 1)
endfunction

function! s:timer_callback(bufnr, ...) abort
  if getcmdtype() !=# '@' || a:bufnr isnot# bufnr('%')
    return
  endif
  let query = getcmdline()
  if query ==# b:context.query
    return
  endif
  let ignorecase = b:context.ignorecase
  let matcher = b:context.matchers[b:context.matcher]
  let content = b:context.content
  let pattern = matcher.get_pattern(query, ignorecase)
  let indices = matcher.get_indices(content, query, ignorecase)
  " Update content
  call s:print_content(indices, content)
  " Update highlight
  if empty(pattern)
    silent nohlsearch
  else
    silent! execute printf(
          \ '/%s\%%(%s\)/',
          \ ignorecase ? '\c' : '\C',
          \ pattern
          \)
  endif
  " Update context
  let b:context.query = query
  let b:context.indices = indices
  let b:context.cursor = max([min([b:context.cursor, len(indices)]), 1])
  " Update statusline
  let &l:statusline = s:statusline()
  " Update cursor and redraw
  call cursor(b:context.cursor, 1, 0)
  redraw
endfunction

function! s:statusline() abort
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
        \ b:context.matchers[b:context.matcher].name,
        \ b:context.ignorecase ? 'ignore' : 'normal',
        \ len(b:context.indices),
        \ len(b:context.content),
        \)
endfunction

function! s:move_to_prev_line() abort
  let size = max([len(b:context.indices), 1])
  if b:context.cursor is# 1
    let b:context.cursor = b:context.wrap_around ? size : 1
  else
    let b:context.cursor -= 1
  endif
  call cursor(b:context.cursor, 1, 0)
  redraw
  call feedkeys(" \<C-h>", 'n')   " Stay TERM cursor on cmdline
  return ''
endfunction

function! s:move_to_next_line() abort
  let size = max([len(b:context.indices), 1])
  if b:context.cursor is# size
    let b:context.cursor = b:context.wrap_around ? 1 : size
  else
    let b:context.cursor += 1
  endif
  call cursor(b:context.cursor, 1, 0)
  redraw
  call feedkeys(" \<C-h>", 'n')   " Stay TERM cursor on cmdline
  return ''
endfunction

function! s:switch_to_prev_matcher() abort
  let size = len(b:context.matchers)
  if b:context.matcher is# 0
    let b:context.matcher = size - 1
  else
    let b:context.matcher -= 1
  endif
  let &l:statusline = s:statusline()
  redrawstatus
  call feedkeys(" \<C-h>", 'n')   " Stay TERM cursor on cmdline
  return ''
endfunction

function! s:switch_to_next_matcher() abort
  let size = len(b:context.matchers)
  if b:context.matcher is# (size - 1)
    let b:context.matcher = 0
  else
    let b:context.matcher += 1
  endif
  let &l:statusline = s:statusline()
  redrawstatus
  call feedkeys(" \<C-h>", 'n')   " Stay TERM cursor on cmdline
  return ''
endfunction

function! s:switch_ignorecase() abort
  let b:context.ignorecase = !b:context.ignorecase
  let &l:statusline = s:statusline()
  redrawstatus
  call feedkeys(" \<C-h>", 'n')   " Stay TERM cursor on cmdline
  return ''
endfunction
