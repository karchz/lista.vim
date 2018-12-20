function! lista#context#new() abort
  let context = {
        \ 'query': '',
        \ 'number': &number,
        \ 'cursor': line('.'),
        \ 'content': getline(1, '$'),
        \ 'indices': range(0, line('$') - 1),
        \ 'matcher': g:lista#context#matcher,
        \ 'matchers': g:lista#context#matchers,
        \ 'ignorecase': g:lista#context#ignorecase,
        \ 'prompt': g:lista#context#prompt,
        \ 'wrap_around': g:lista#context#wrap_around,
        \ 'interval': g:lista#context#interval,
        \}
  return context
endfunction

let g:lista#context#matcher = get(g:, 'lista#context#matcher', 0)
let g:lista#context#matchers = get(g:, 'lista#context#matchers', [
      \ lista#matcher#all#new(),
      \ lista#matcher#fuzzy#new(),
      \])
let g:lista#context#ignorecase = get(g:, 'lista#context#ignorecase', &ignorecase)
let g:lista#context#prompt = get(g:, 'lista#context#prompt', '# ')
let g:lista#context#wrap_around = get(g:, 'lista#context#wrap_around', 1)
let g:lista#context#interval = get(g:, 'lista#context#interval', 50)
