function! lista#context#new() abort
  let context = {
        \ 'query': '',
        \ 'cursor': 1,
        \ 'content': getline(1, '$'),
        \ 'indices': range(0, line('$') - 1),
        \ 'matcher': g:lista#context#matcher,
        \ 'matchers': g:lista#context#matchers,
        \ 'ignorecase': g:lista#context#ignorecase,
        \ 'prompt': g:lista#context#prompt,
        \ 'wrap_around': g:lista#context#wrap_around,
        \}
  return context
endfunction

let g:lista#context#matcher = get(g:, 'lista#context#matcher', 0)
let g:lista#context#matchers = get(g:, 'lista#context#matchers', [
      \ lista#matcher#all(),
      \ lista#matcher#fuzzy(),
      \])
let g:lista#context#ignorecase = get(g:, 'lista#context#ignorecase', &ignorecase)
let g:lista#context#prompt = get(g:, 'lista#context#prompt', '# ')
let g:lista#context#wrap_around = get(g:, 'lista#context#wrap_around', 1)
