" lightline: statusline with LSP diagnostic counts.
" Slanted separators match kitty's tab bar (needs a Nerd Font).

let g:lightline = {
      \ 'colorscheme': 'vimesimal',
      \ 'active': {
      \   'left':  [['mode', 'paste'], ['readonly', 'filename', 'modified']],
      \   'right': [['lineinfo'], ['percent'], ['lsp', 'filetype', 'fileencoding']],
      \ },
      \ 'component_function': {'lsp': 'VimesimalLspStatus'},
      \ 'separator':    {'left': "", 'right': ""},
      \ 'subseparator': {'left': "", 'right': ""},
      \ }

function! VimesimalLspStatus() abort
  if !get(g:, 'lsp_loaded', 0)
    return ''
  endif
  let l:counts = lsp#get_buffer_diagnostics_counts()
  let l:parts = []
  for [l:key, l:sign] in [['error', '✗'], ['warning', '!'], ['information', 'i'], ['hint', '·']]
    if get(l:counts, l:key, 0) > 0
      call add(l:parts, l:sign . l:counts[l:key])
    endif
  endfor
  return join(l:parts, ' ')
endfunction

augroup vimesimal_statusline
  autocmd!
  autocmd User lsp_diagnostics_updated silent! call lightline#update()
augroup END
