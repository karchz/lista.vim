let s:custom = {
      \ 'mappings': {
      \   '<C-t>': '<Plug>(lista-filter-prev-line)',
      \   '<C-g>': '<Plug>(lista-filter-next-line)',
      \   '<C-^>': '<Plug>(lista-filter-next-matcher)',
      \   '<C-6>': '<Plug>(lista-filter-next-matcher)',
      \   '<C-_>': '<Plug>(lista-filter-switch-ignorecase)',
      \ }
      \}

function! lista#custom#get() abort
  return s:custom
endfunction

function! lista#custom#mapping(lhs, rhs) abort
  let s:custom.mappings[a:lhs] = a:rhs
endfunction
