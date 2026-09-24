" vimesimal — entry point
"
"   core/           global options, keymaps, plugin list
"   plugin-config/  settings for global plugins
"   colors/         global theme
"   lang/<name>/    per-language plugins.vim + config.vim
"   after/ftplugin/ per-language spacing / indent style

set nocompatible

" Repo root, resolved through the ~/.vimrc symlink.
let g:vimesimal = fnamemodify(resolve(expand('<sfile>:p')), ':h')

" Make sure the repo is on the runtimepath (it already is when ~/.vim links
" here; this covers `vim -u path/to/vimrc`).
if index(map(split(&runtimepath, ','), 'resolve(expand(v:val))'), g:vimesimal) < 0
  let &runtimepath = g:vimesimal . ',' . &runtimepath . ',' . g:vimesimal . '/after'
endif

function! s:source(pattern) abort
  for l:file in sort(glob(g:vimesimal . '/' . a:pattern, 0, 1))
    execute 'source' fnameescape(l:file)
  endfor
endfunction

call s:source('core/options.vim')
call s:source('core/keymaps.vim')
call s:source('core/plugins.vim')
call s:source('plugin-config/*.vim')
call s:source('lang/*/config.vim')

silent! colorscheme vimesimal
