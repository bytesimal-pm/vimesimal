" Global plugins (vim-plug). Language plugins are pulled in from
" lang/*/plugins.vim inside the same plug block.

let s:plug = g:vimesimal . '/autoload/plug.vim'
if empty(glob(s:plug))
  if executable('curl')
    silent execute '!curl -fsLo ' . shellescape(s:plug) . ' --create-dirs '
          \ . 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * ++once PlugInstall --sync
  endif
  if empty(glob(s:plug))
    filetype plugin indent on
    syntax enable
    finish
  endif
endif

call plug#begin(g:vimesimal . '/plugged')

" Auto suggest: LSP client + completion popup
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'prabirshrestha/asyncomplete-buffer.vim'
Plug 'prabirshrestha/asyncomplete-file.vim'

" Navigate
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'lambdalisue/fern.vim'

" Nest: indent guides + rainbow brackets
Plug 'Yggdroot/indentLine'
Plug 'luochen1990/rainbow'

" Line: statusline + git signs
Plug 'itchyny/lightline.vim'
Plug 'airblade/vim-gitgutter'

" Editing
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'jiangmiao/auto-pairs'

" Language plugins
for s:file in sort(glob(g:vimesimal . '/lang/*/plugins.vim', 0, 1))
  execute 'source' fnameescape(s:file)
endfor

call plug#end()
