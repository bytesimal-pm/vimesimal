" vimesimal — monochrome theme matching kitty, with muted syntax accents.
" Background is NONE so kitty's background_opacity shows through.

set background=dark
highlight clear
if exists('syntax_on')
  syntax reset
endif
let g:colors_name = 'vimesimal'

let s:p = vimesimal#palette()

" s:hi(group, fg, bg, [attr], [sp])
function! s:hi(group, fg, bg, ...) abort
  let l:attr = get(a:, 1, 'NONE')
  let l:cmd = printf('highlight %s guifg=%s guibg=%s ctermfg=%s ctermbg=%s gui=%s cterm=%s',
        \ a:group, s:p[a:fg][0], s:p[a:bg][0], s:p[a:fg][1], s:p[a:bg][1], l:attr, l:attr)
  if a:0 > 1
    let l:cmd .= ' guisp=' . s:p[a:2][0]
  endif
  execute l:cmd
endfunction

" --- Editor UI --------------------------------------------------------------
call s:hi('Normal',       'white', 'none')
call s:hi('NonText',      'guide', 'none')
call s:hi('SpecialKey',   'guide', 'none')
call s:hi('EndOfBuffer',  'guide', 'none')
call s:hi('Conceal',      'guide', 'none')
call s:hi('LineNr',       'faint', 'none')
call s:hi('LineNrAbove',  'faint', 'none')
call s:hi('LineNrBelow',  'faint', 'none')
call s:hi('CursorLineNr', 'white', 'panel', 'bold')
call s:hi('CursorLine',   'none',  'panel')
call s:hi('CursorColumn', 'none',  'panel')
call s:hi('ColorColumn',  'none',  'panel')
call s:hi('SignColumn',   'none',  'none')
call s:hi('FoldColumn',   'faint', 'none')
call s:hi('Folded',       'mute',  'panel')
call s:hi('VertSplit',    'guide', 'none')
call s:hi('StatusLine',   'white', 'panel')
call s:hi('StatusLineNC', 'faint', 'panel')
call s:hi('StatusLineTerm',   'white', 'panel')
call s:hi('StatusLineTermNC', 'faint', 'panel')
call s:hi('TabLine',      'faint', 'panel')
call s:hi('TabLineFill',  'none',  'panel')
call s:hi('TabLineSel',   'black', 'white', 'bold')
call s:hi('Visual',       'black', 'white')
call s:hi('VisualNOS',    'black', 'dim')
call s:hi('Search',       'black', 'dim')
call s:hi('IncSearch',    'black', 'white', 'bold')
call s:hi('CurSearch',    'black', 'white', 'bold')
call s:hi('MatchParen',   'white', 'guide', 'bold')
call s:hi('Pmenu',        'dim',   'panel')
call s:hi('PmenuSel',     'black', 'white', 'bold')
call s:hi('PmenuSbar',    'none',  'line')
call s:hi('PmenuThumb',   'none',  'mute')
call s:hi('PmenuKind',    'steel', 'panel')
call s:hi('PmenuExtra',   'mute',  'panel')
call s:hi('WildMenu',     'black', 'white', 'bold')
call s:hi('Title',        'white', 'none',  'bold')
call s:hi('Directory',    'steel', 'none')
call s:hi('ModeMsg',      'white', 'none',  'bold')
call s:hi('MoreMsg',      'sage',  'none')
call s:hi('Question',     'sage',  'none')
call s:hi('ErrorMsg',     'red',   'none',  'bold')
call s:hi('WarningMsg',   'sand',  'none')
call s:hi('QuickFixLine', 'none',  'line')
call s:hi('SpellBad',     'none',  'none',  'undercurl', 'red')
call s:hi('SpellCap',     'none',  'none',  'undercurl', 'sand')
call s:hi('SpellRare',    'none',  'none',  'undercurl', 'mauve')
call s:hi('SpellLocal',   'none',  'none',  'undercurl', 'steel')
call s:hi('DiffAdd',      'sage',  'panel')
call s:hi('DiffChange',   'steel', 'panel')
call s:hi('DiffDelete',   'red',   'none')
call s:hi('DiffText',     'black', 'steel')
highlight Cursor gui=reverse cterm=reverse

" --- Syntax -----------------------------------------------------------------
call s:hi('Comment',      'mute',  'none', 'italic')
call s:hi('SpecialComment', 'faint', 'none', 'italic')
call s:hi('Todo',         'black', 'sand', 'bold')
call s:hi('Constant',     'rose',  'none')
call s:hi('Number',       'rose',  'none')
call s:hi('Float',        'rose',  'none')
call s:hi('Boolean',      'rose',  'none')
call s:hi('String',       'sand',  'none')
call s:hi('Character',    'sand',  'none')
call s:hi('Identifier',   'white', 'none')
call s:hi('Function',     'white', 'none', 'bold')
call s:hi('Statement',    'steel', 'none', 'bold')
call s:hi('Conditional',  'steel', 'none', 'bold')
call s:hi('Repeat',       'steel', 'none', 'bold')
call s:hi('Label',        'steel', 'none')
call s:hi('Keyword',      'steel', 'none', 'bold')
call s:hi('Exception',    'steel', 'none', 'bold')
call s:hi('Operator',     'gray',  'none')
call s:hi('Delimiter',    'gray',  'none')
call s:hi('PreProc',      'mauve', 'none')
call s:hi('Include',      'mauve', 'none')
call s:hi('Define',       'mauve', 'none')
call s:hi('Macro',        'mauve', 'none')
call s:hi('PreCondit',    'mauve', 'none')
call s:hi('Type',         'sage',  'none')
call s:hi('StorageClass', 'sage',  'none', 'italic')
call s:hi('Structure',    'sage',  'none')
call s:hi('Typedef',      'sage',  'none')
call s:hi('Special',      'teal',  'none')
call s:hi('SpecialChar',  'teal',  'none')
call s:hi('Tag',          'teal',  'none')
call s:hi('Debug',        'teal',  'none')
call s:hi('Underlined',   'steel', 'none', 'underline')
call s:hi('Ignore',       'faint', 'none')
call s:hi('Error',        'red',   'none', 'bold')
call s:hi('Added',        'sage',  'none')
call s:hi('Changed',      'steel', 'none')
call s:hi('Removed',      'red',   'none')

" --- Plugins ----------------------------------------------------------------
" vim-gitgutter
call s:hi('GitGutterAdd',          'sage',  'none')
call s:hi('GitGutterChange',       'steel', 'none')
call s:hi('GitGutterDelete',       'red',   'none')
call s:hi('GitGutterChangeDelete', 'mauve', 'none')

" vim-lsp
call s:hi('LspErrorText',              'red',   'none')
call s:hi('LspWarningText',            'sand',  'none')
call s:hi('LspInformationText',        'steel', 'none')
call s:hi('LspHintText',               'mute',  'none')
call s:hi('LspErrorVirtualText',       'red',   'none', 'italic')
call s:hi('LspWarningVirtualText',     'sand',  'none', 'italic')
call s:hi('LspInformationVirtualText', 'steel', 'none', 'italic')
call s:hi('LspHintVirtualText',        'mute',  'none', 'italic')
call s:hi('LspErrorHighlight',         'none',  'none', 'undercurl', 'red')
call s:hi('LspWarningHighlight',       'none',  'none', 'undercurl', 'sand')
call s:hi('LspInformationHighlight',   'none',  'none', 'undercurl', 'steel')
call s:hi('LspHintHighlight',          'none',  'none', 'undercurl', 'mute')
call s:hi('lspReference',              'none',  'line')

" vim-c-cpp-modern
call s:hi('cUserFunction',  'white', 'none', 'bold')
call s:hi('cMemberAccess',  'gray',  'none')
call s:hi('cStructMember',  'dim',   'none')
