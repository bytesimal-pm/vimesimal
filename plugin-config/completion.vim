" asyncomplete: popup suggestions while typing (LSP + buffer words + paths).

let g:asyncomplete_auto_popup = 1
let g:asyncomplete_auto_completeopt = 0
let g:asyncomplete_popup_delay = 100

" auto-pairs' own <CR> map would clobber ours; we chain it below instead.
let g:AutoPairsMapCR = 0

function! s:cr() abort
  if pumvisible()
    return asyncomplete#close_popup()
  endif
  return "\<CR>" . (exists('*AutoPairsReturn') ? "\<C-r>=AutoPairsReturn()\<CR>" : '')
endfunction

inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <silent><expr> <CR> <SID>cr()
imap <C-Space> <Plug>(asyncomplete_force_refresh)

augroup vimesimal_complete
  autocmd!
  autocmd User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
        \ 'name': 'buffer',
        \ 'allowlist': ['*'],
        \ 'priority': 1,
        \ 'completor': function('asyncomplete#sources#buffer#completor'),
        \ 'config': {'max_buffer_size': 5000000},
        \ }))
  autocmd User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
        \ 'name': 'file',
        \ 'allowlist': ['*'],
        \ 'priority': 10,
        \ 'completor': function('asyncomplete#sources#file#completor'),
        \ }))
augroup END
