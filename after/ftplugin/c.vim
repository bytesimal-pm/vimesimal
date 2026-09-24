" C spacing — Linux kernel coding style
" (Documentation/process/coding-style.rst): hard tabs, 8 wide, 80 columns.

setlocal noexpandtab tabstop=8 shiftwidth=8 softtabstop=8
setlocal textwidth=80 colorcolumn=81
setlocal cindent cinoptions=:0,l1,t0,g0,(0

let s:undo = 'setlocal et< ts< sw< sts< tw< cc< cin< cino<'
let b:undo_ftplugin = exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' . s:undo : s:undo
