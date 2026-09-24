" fzf.vim: fuzzy files / grep / buffers.

if empty($FZF_DEFAULT_COMMAND) && executable('rg')
  let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --glob "!.git"'
endif

let g:fzf_layout = {'window': {'width': 0.9, 'height': 0.8, 'border': 'sharp'}}
let g:fzf_colors = {
      \ 'fg':      ['fg', 'Normal'],
      \ 'hl':      ['fg', 'Statement'],
      \ 'fg+':     ['fg', 'Normal'],
      \ 'bg+':     ['bg', 'CursorLine'],
      \ 'hl+':     ['fg', 'Statement'],
      \ 'info':    ['fg', 'Comment'],
      \ 'border':  ['fg', 'VertSplit'],
      \ 'prompt':  ['fg', 'Title'],
      \ 'pointer': ['fg', 'Title'],
      \ 'marker':  ['fg', 'String'],
      \ 'spinner': ['fg', 'Comment'],
      \ 'header':  ['fg', 'Comment'],
      \ }

nnoremap <silent> <leader>f :Files<CR>
nnoremap <silent> <leader>g :Rg<CR>
nnoremap <silent> <leader>b :Buffers<CR>
nnoremap <silent> <leader>/ :BLines<CR>
nnoremap <silent> <leader>r :History<CR>
