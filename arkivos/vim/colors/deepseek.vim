" Deepseek Color Theme for Vim
" Optimized for C and Python development
" Inspired by programming aesthetics and functional color hierarchy

set background=dark
highlight clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "deepseek"

" Palette Definition
let s:ds_bg        = '#0d1117'
let s:ds_fg        = '#c9d1d9'
let s:ds_comment   = '#8b949e'
let s:ds_blue      = '#79c0ff'
let s:ds_green     = '#7ee787'
let s:ds_yellow    = '#ffd33d'
let s:ds_red       = '#ff7b72'
let s:ds_purple    = '#d2a8ff'
let s:ds_orange    = '#ffa657'
let s:ds_cyan      = '#56d4dd'
let s:ds_gray      = '#484f58'
let s:ds_gray_light = '#6e7681'

" Base Colors
exec 'hi Normal       guifg='.s:ds_fg.'      guibg='.s:ds_bg
exec 'hi Comment      guifg='.s:ds_comment.' gui=italic'

" Core Syntax Groups
exec 'hi Constant     guifg='.s:ds_yellow
exec 'hi String       guifg='.s:ds_blue
exec 'hi Character    guifg='.s:ds_blue
exec 'hi Number       guifg='.s:ds_green
exec 'hi Boolean      guifg='.s:ds_yellow
exec 'hi Float        guifg='.s:ds_green

exec 'hi Identifier   guifg='.s:ds_fg
exec 'hi Function     guifg='.s:ds_purple.' gui=bold'

exec 'hi Statement    guifg='.s:ds_orange.' gui=none'
exec 'hi Conditional  guifg='.s:ds_orange
exec 'hi Repeat       guifg='.s:ds_orange
exec 'hi Label        guifg='.s:ds_orange
exec 'hi Operator     guifg='.s:ds_red
exec 'hi Keyword      guifg='.s:ds_orange
exec 'hi Exception    guifg='.s:ds_orange

exec 'hi PreProc      guifg='.s:ds_purple
exec 'hi Include      guifg='.s:ds_orange
exec 'hi Define       guifg='.s:ds_orange
exec 'hi Macro        guifg='.s:ds_orange
exec 'hi PreCondit    guifg='.s:ds_orange

exec 'hi Type         guifg='.s:ds_cyan.' gui=none'
exec 'hi StorageClass guifg='.s:ds_orange
exec 'hi Structure    guifg='.s:ds_cyan
exec 'hi Typedef      guifg='.s:ds_cyan

exec 'hi Special      guifg='.s:ds_red
exec 'hi SpecialChar  guifg='.s:ds_red
exec 'hi Tag          guifg='.s:ds_red
exec 'hi Delimiter    guifg='.s:ds_fg
exec 'hi SpecialComment guifg='.s:ds_comment.' gui=bold'
exec 'hi Debug        guifg='.s:ds_red

" UI Elements
exec 'hi LineNr       guifg='.s:ds_gray.'      guibg='.s:ds_bg
exec 'hi CursorLineNr guifg='.s:ds_orange.'    guibg='.s:ds_gray
exec 'hi CursorLine   guibg='.s:ds_gray
exec 'hi ColorColumn  guibg='.s:ds_gray
exec 'hi SignColumn   guibg='.s:ds_bg

exec 'hi VertSplit    guifg='.s:ds_gray.'      guibg='.s:ds_bg
exec 'hi StatusLine   guifg='.s:ds_fg.'        guibg='.s:ds_gray.' gui=bold'
exec 'hi StatusLineNC guifg='.s:ds_comment.'   guibg='.s:ds_gray

exec 'hi Pmenu        guifg='.s:ds_fg.'        guibg='.s:ds_gray
exec 'hi PmenuSel     guifg='.s:ds_bg.'        guibg='.s:ds_blue
exec 'hi PmenuSbar    guibg='.s:ds_gray
exec 'hi PmenuThumb   guibg='.s:ds_gray_light

exec 'hi MatchParen   guifg='.s:ds_bg.'        guibg='.s:ds_blue.' gui=bold'
exec 'hi Search       guifg='.s:ds_bg.'        guibg='.s:ds_yellow
exec 'hi IncSearch    guifg='.s:ds_bg.'        guibg='.s:ds_orange

" Special Syntax for C
augroup DeepseekC
  autocmd!
  autocmd FileType c hi! link cFormatSpec Special
  autocmd FileType c hi! link cPointerOp Operator
  autocmd FileType c hi! link cCustomFunc Function
  autocmd FileType c syntax match cCustomFunc /\<\w\+\ze\s*(/ contains=cParen
  autocmd FileType c syntax match cPointerOp /->\|\./
  autocmd FileType c syntax match cFormatSpec /%[-+#0*]*\d*\.*\d*[diuoxXfFeEgGaAcspn%]/
augroup END

" Special Syntax for Python
augroup DeepseekPython
  autocmd!
  autocmd FileType python hi! link pythonDecorator PreProc
  autocmd FileType python hi! link pythonStringFormatting Special
  autocmd FileType python syntax match pythonStringFormatting /%\w/ containedin=pythonString
  autocmd FileType python syntax match pythonStringFormatting /{\w\+}/ containedin=pythonString
  autocmd FileType python syntax match pythonStringFormatting /f\s*'\zs{\w\+}/ containedin=pythonString
augroup END

" Git/Diff Highlighting
exec 'hi DiffAdd      guifg='.s:ds_green.'     guibg='.s:ds_bg
exec 'hi DiffChange   guifg='.s:ds_orange.'    guibg='.s:ds_bg
exec 'hi DiffDelete   guifg='.s:ds_red.'       guibg='.s:ds_bg
exec 'hi DiffText     guifg='.s:ds_blue.'      guibg='.s:ds_bg

" LSP and Diagnostics
exec 'hi ErrorMsg     guifg='.s:ds_red.'       guibg='.s:ds_bg.' gui=bold'
exec 'hi WarningMsg   guifg='.s:ds_orange.'    guibg='.s:ds_bg
exec 'hi Error        guifg='.s:ds_red.'       guibg='.s:ds_bg.' gui=undercurl'
exec 'hi Todo         guifg='.s:ds_purple.'    guibg='.s:ds_bg.' gui=bold'
