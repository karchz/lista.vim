function! lista#state#store() abort
  return {
        \ 'bufnr': bufnr('%'),
        \ 'undo': s:undo_store(),
        \ 'mark': s:mark_store(),
        \ 'view': winsaveview(),
        \ 'buftype': &l:buftype,
        \ 'filetype': &l:filetype,
        \ 'modified': &l:modified,
        \ 'readonly': &l:readonly,
        \ 'modifiable': &l:modifiable,
        \ 'foldenable': &l:foldenable,
        \ 'cursorline': &l:cursorline,
        \}
endfunction

function! lista#state#restore(state) abort
  let state = a:state
  if bufnr('%') isnot# state.bufnr
    throw printf(
          \ 'lista: state of a buffer %s cannot be applied to a buffer %s',
          \ state.bufnr,
          \ bufnr('%'),
          \)
  endif
  call s:undo_restore(state.undo)
  call s:mark_restore(state.mark)
  call winrestview(state.view)
  let &l:buftype = state.buftype
  let &l:filetype = state.filetype
  let &l:modified = state.modified
  let &l:readonly = state.readonly
  let &l:modifiable = state.modifiable
  let &l:foldenable = state.foldenable
  let &l:cursorline = state.cursorline
endfunction


" undo
function! s:undo_store() abort
  let undofile = tempname()
  execute printf('silent wundo %s', fnameescape(undofile))
  return undofile
endfunction

function! s:undo_restore(undofile) abort
  execute printf('silent! rundo %s', fnameescape(a:undofile))
endfunction


" mark
function! s:mark_store() abort
  let records = split(execute('marks'), '\n')[1:]
  let marks = []
  let index = -1
  while 1
    let index = match(records, '^ [a-zA-Z''`\[\]<>]', index + 1)
    if index is# -1
      break
    endif
    let m = matchlist(
          \ records[index],
          \ '^\s\(.\)\s\+\(\d\+\)\s\+\(\d\+\)\s\(.*\)$',
          \)
    if m[1] !~# '[A-Z]' && getline(m[2] + 0) =~# '^\s*' . escape(m[4], '^$~.*[]\')
      call add(marks, {
            \ 'mark': m[1],
            \ 'lnum': m[2] + 0,
            \ 'col': m[3] + 0,
            \})
    endif
  endwhile
  return marks
endfunction

function! s:mark_restore(marks) abort
  for mark in a:marks
    call setpos('''' . mark.mark, [0, mark.lnum, mark.col, 0])
  endfor
endfunction
