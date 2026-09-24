" Global keymaps. Plugin keymaps live next to their config in plugin-config/.

let mapleader = "\<Space>"
let maplocalleader = ','

nnoremap <silent> <leader>w :write<CR>
nnoremap <silent> <leader>q :bdelete<CR>
nnoremap <silent> <leader>h :nohlsearch<CR>
nnoremap Y y$

" Windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Buffers
nnoremap <silent> <S-l> :bnext<CR>
nnoremap <silent> <S-h> :bprevious<CR>

" Keep selection while indenting; move selected lines
xnoremap < <gv
xnoremap > >gv
xnoremap <silent> J :move '>+1<CR>gv=gv
xnoremap <silent> K :move '<-2<CR>gv=gv
