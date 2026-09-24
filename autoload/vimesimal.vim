" Shared palette for colors/vimesimal.vim and the lightline theme.
" Based on the kitty theme: black (transparent) background, white text,
" grays for UI, plus muted accents used only for syntax.
" Each entry is [gui hex, cterm 256 index].

function! vimesimal#palette() abort
  return {
        \ 'none':  ['NONE',    'NONE'],
        \ 'black': ['#000000', 16],
        \ 'white': ['#ffffff', 15],
        \ 'dim':   ['#c8c8c8', 251],
        \ 'gray':  ['#a0a0a0', 247],
        \ 'mute':  ['#808080', 244],
        \ 'faint': ['#707070', 242],
        \ 'guide': ['#3a3a3a', 237],
        \ 'line':  ['#262626', 235],
        \ 'panel': ['#1a1a1a', 234],
        \ 'steel': ['#b4bcd0', 146],
        \ 'sage':  ['#a3b8a0', 108],
        \ 'sand':  ['#c8b89a', 144],
        \ 'rose':  ['#c9a0a0', 181],
        \ 'mauve': ['#b89ac0', 139],
        \ 'teal':  ['#9ec0c0', 109],
        \ 'red':   ['#e08080', 174],
        \ }
endfunction
