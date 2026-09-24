" fern.vim: file tree drawer.

let g:fern#default_hidden = 1
let g:fern#renderer#default#collapsed_symbol = '▸ '
let g:fern#renderer#default#expanded_symbol = '▾ '
let g:fern#renderer#default#leaf_symbol = '  '

function! s:toggle_tree() abort
  execute 'Fern . -drawer -toggle' . (empty(expand('%')) ? '' : ' -reveal=%')
endfunction

function! s:fern_init() abort
  setlocal nonumber norelativenumber signcolumn=no nolist
  nmap <buffer> l <Plug>(fern-action-open-or-expand)
  nmap <buffer> h <Plug>(fern-action-collapse)
endfunction

nnoremap <silent> <leader>e :call <SID>toggle_tree()<CR>

augroup vimesimal_fern
  autocmd!
  autocmd FileType fern call s:fern_init()
augroup END
