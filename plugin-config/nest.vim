" Nesting visuals.
" Tab-indented code gets guides from 'listchars' (tab:│); space-indented code
" gets them from indentLine. Brackets are colored by depth with rainbow.

let g:indentLine_char = '│'
let g:indentLine_first_char = '│'
let g:indentLine_showFirstIndentLevel = 0
let g:indentLine_color_gui = vimesimal#palette().guide[0]
let g:indentLine_color_term = vimesimal#palette().guide[1]
let g:indentLine_fileTypeExclude = ['', 'help', 'fern', 'markdown', 'json', 'text']
let g:indentLine_bufTypeExclude = ['help', 'terminal', 'nofile']

let s:p = vimesimal#palette()
let s:depth = ['dim', 'steel', 'sand', 'sage', 'mauve', 'teal']
let g:rainbow_active = 1
let g:rainbow_conf = {
      \ 'guifgs':   map(copy(s:depth), 's:p[v:val][0]'),
      \ 'ctermfgs': map(copy(s:depth), 's:p[v:val][1]'),
      \ 'separately': {'fern': 0, 'help': 0},
      \ }
