" lightline theme for vimesimal: white mode block, gray segments,
" a muted accent per mode.

let s:p = vimesimal#palette()

function! s:c(fg, bg) abort
  return [s:p[a:fg][0], s:p[a:bg][0], s:p[a:fg][1], s:p[a:bg][1]]
endfunction

let s:t = {'normal': {}, 'insert': {}, 'visual': {}, 'replace': {}, 'inactive': {}, 'tabline': {}}

let s:t.normal.left    = [s:c('black', 'white'), s:c('white', 'guide')]
let s:t.normal.middle  = [s:c('faint', 'panel')]
let s:t.normal.right   = [s:c('black', 'white'), s:c('white', 'guide'), s:c('dim', 'panel')]
let s:t.normal.error   = [s:c('black', 'red')]
let s:t.normal.warning = [s:c('black', 'sand')]

let s:t.insert.left    = [s:c('black', 'sage'),  s:c('white', 'guide')]
let s:t.visual.left    = [s:c('black', 'steel'), s:c('white', 'guide')]
let s:t.replace.left   = [s:c('black', 'rose'),  s:c('white', 'guide')]

let s:t.inactive.left   = [s:c('faint', 'panel'), s:c('faint', 'panel')]
let s:t.inactive.middle = [s:c('faint', 'panel')]
let s:t.inactive.right  = [s:c('faint', 'panel'), s:c('faint', 'panel')]

let s:t.tabline.left   = [s:c('faint', 'panel')]
let s:t.tabline.tabsel = [s:c('black', 'white')]
let s:t.tabline.middle = [s:c('faint', 'panel')]
let s:t.tabline.right  = [s:c('black', 'white')]

let g:lightline#colorscheme#vimesimal#palette = s:t
