" Global editor options. Languages override spacing in after/ftplugin/.

set encoding=utf-8
scriptencoding utf-8

" --- Terminal (kitty) -------------------------------------------------------
if has('termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif
let &t_Cs = "\e[4:3m"                     " undercurl
let &t_Ce = "\e[4:0m"
let &t_SI = "\e[6 q"                      " beam in insert
let &t_SR = "\e[4 q"                      " underline in replace
let &t_EI = "\e[2 q"                      " block in normal
set mouse=a
set ttymouse=sgr
set ttimeout ttimeoutlen=10
set timeoutlen=500
set updatetime=300
if has('unnamedplus')
  set clipboard=unnamedplus
endif

" --- Line -------------------------------------------------------------------
set number relativenumber
set cursorline cursorlineopt=both
set signcolumn=yes
set laststatus=2 noshowmode showcmd
set scrolloff=8 sidescrolloff=8
set nowrap
set list listchars=tab:│\ ,trail:·,nbsp:␣,extends:›,precedes:‹
set fillchars=vert:│,fold:\ ,eob:\

" --- Default spacing (overridden per language) ------------------------------
set expandtab tabstop=4 shiftwidth=4 softtabstop=4
set autoindent smarttab
set backspace=indent,eol,start

" --- Search -----------------------------------------------------------------
set incsearch hlsearch ignorecase smartcase

" --- Completion / command line ----------------------------------------------
set completeopt=menuone,noinsert,noselect,popup
set shortmess+=c
set wildmenu wildmode=longest:full,full wildoptions=pum
set pumheight=12

" --- Buffers, windows, files ------------------------------------------------
set hidden
set splitbelow splitright
set noswapfile nobackup nowritebackup
set undofile
let &undodir = g:vimesimal . '/undo//'
if !isdirectory(g:vimesimal . '/undo')
  call mkdir(g:vimesimal . '/undo', 'p')
endif
