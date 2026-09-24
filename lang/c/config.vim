" C: clangd LSP, kernel-style formatting, highlight options.
" Spacing lives in after/ftplugin/c.vim.

" Treat .h as C, not C++.
let g:c_syntax_for_h = 1

" vim-c-cpp-modern
let g:cpp_function_highlight = 1
let g:cpp_member_highlight = 1
let g:cpp_attributes_highlight = 1

" Linux kernel style, used when the project has no .clang-format of its own.
let s:kernel_style = {
      \ 'BasedOnStyle': 'LLVM',
      \ 'IndentWidth': 8,
      \ 'TabWidth': 8,
      \ 'UseTab': 'Always',
      \ 'ContinuationIndentWidth': 8,
      \ 'ColumnLimit': 80,
      \ 'BreakBeforeBraces': 'Linux',
      \ 'IndentCaseLabels': 'false',
      \ 'AllowShortIfStatementsOnASingleLine': 'false',
      \ 'AllowShortLoopsOnASingleLine': 'false',
      \ 'AllowShortFunctionsOnASingleLine': 'None',
      \ 'AllowShortBlocksOnASingleLine': 'false',
      \ 'PointerAlignment': 'Right',
      \ 'SpaceAfterCStyleCast': 'false',
      \ 'SortIncludes': 'false',
      \ }

" vim-clang-format
let g:clang_format#detect_style_file = 1
let g:clang_format#style_options = s:kernel_style

if executable('clangd')
  let s:fallback = '{' . join(map(items(s:kernel_style), 'v:val[0] . ": " . v:val[1]'), ', ') . '}'
  augroup vimesimal_lsp_c
    autocmd!
    autocmd User lsp_setup call lsp#register_server({
          \ 'name': 'clangd',
          \ 'cmd': {server_info -> ['clangd', '--background-index',
          \         '--header-insertion=never', '--fallback-style=' . s:fallback]},
          \ 'allowlist': ['c', 'cpp'],
          \ })
  augroup END
endif

" Jump between foo.c and foo.h
function! s:alternate() abort
  let l:ext = expand('%:e') ==# 'h' ? 'c' : 'h'
  execute 'edit' fnameescape(expand('%:r') . '.' . l:ext)
endfunction

function! s:c_maps() abort
  nnoremap <buffer><silent> <leader>cf :ClangFormat<CR>
  xnoremap <buffer><silent> <leader>cf :ClangFormat<CR>
  nnoremap <buffer><silent> <leader>a  :call <SID>alternate()<CR>
endfunction

augroup vimesimal_c
  autocmd!
  autocmd FileType c call s:c_maps()
augroup END
