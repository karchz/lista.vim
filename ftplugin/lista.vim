if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

" setlocal signcolumn=no
setlocal cursorline
setlocal nolist nowrap nospell nofoldenable nonumber

cmap <buffer> <CR>  <Plug>(lista-accept)
cmap <buffer> <C-k> <Plug>(lista-prev-line)
cmap <buffer> <C-j> <Plug>(lista-next-line)
cmap <buffer> <Up> <Plug>(lista-prev-line)
cmap <buffer> <Down> <Plug>(lista-next-line)
