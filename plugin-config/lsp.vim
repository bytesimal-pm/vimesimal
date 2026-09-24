" vim-lsp: diagnostics + navigation. Servers are registered per language in
" lang/<name>/config.vim.

let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_virtual_text_enabled = 1
let g:lsp_diagnostics_virtual_text_align = 'after'
let g:lsp_diagnostics_virtual_text_prefix = ' ‹ '
let g:lsp_diagnostics_signs_error = {'text': '✗'}
let g:lsp_diagnostics_signs_warning = {'text': '!'}
let g:lsp_diagnostics_signs_information = {'text': 'i'}
let g:lsp_diagnostics_signs_hint = {'text': '·'}
let g:lsp_document_highlight_enabled = 1
let g:lsp_format_sync_timeout = 1000

function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  setlocal tagfunc=lsp#tagfunc
  nmap <buffer> gd <Plug>(lsp-definition)
  nmap <buffer> gD <Plug>(lsp-declaration)
  nmap <buffer> gr <Plug>(lsp-references)
  nmap <buffer> gi <Plug>(lsp-implementation)
  nmap <buffer> gy <Plug>(lsp-type-definition)
  nmap <buffer> K  <Plug>(lsp-hover)
  nmap <buffer> [d <Plug>(lsp-previous-diagnostic)
  nmap <buffer> ]d <Plug>(lsp-next-diagnostic)
  nmap <buffer> <leader>rn <Plug>(lsp-rename)
  nmap <buffer> <leader>ca <Plug>(lsp-code-action-float)
  nmap <buffer> <leader>d  <Plug>(lsp-document-diagnostics)
  nmap <buffer> <leader>o  <Plug>(lsp-document-symbol-search)
  nmap <buffer> <leader>S  <Plug>(lsp-workspace-symbol-search)
endfunction

augroup vimesimal_lsp
  autocmd!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
