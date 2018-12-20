if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

" setlocal signcolumn=no
setlocal cursorline
setlocal nolist nowrap nospell nofoldenable nonumber

cmap <buffer> <CR>  <Plug>(lista-accept)
cmap <buffer> <C-t> <Plug>(lista-prev-line)
cmap <buffer> <C-g> <Plug>(lista-next-line)
cmap <buffer> <C-^> <Plug>(lista-next-matcher)
cmap <buffer> <C-6> <Plug>(lista-next-matcher)
cmap <buffer> <C-_> <Plug>(lista-switch-ignorecase)
