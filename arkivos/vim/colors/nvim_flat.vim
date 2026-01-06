" Nome do tema: NeoFlat
" Baseado nas cores do logo do Neovim

" Reset cores anteriores
hi clear
if exists("syntax_on")
    syntax reset
endif

let g:colors_name = "neoflat"

" Cores do logo Neovim
let s:neo_blue = '#2196F3'      " Azul
let s:neo_green = '#4CAF50'     " Verde
let s:neo_dark = '#1a1b1c'      " Fundo escuro
let s:neo_gray = '#3E4452'      " Cinza escuro
let s:neo_light = '#ABB2BF'     " Cinza claro
let s:neo_white = '#FFFFFF'     " Branco

" Configurações gerais
exe 'hi Normal guifg=' . s:neo_light . ' guibg=' . s:neo_dark
exe 'hi LineNr guifg=' . s:neo_gray
exe 'hi CursorLineNr guifg=' . s:neo_blue
exe 'hi CursorLine guibg=' . s:neo_gray

" Sintaxe
exe 'hi Comment guifg=' . s:neo_gray
exe 'hi Constant guifg=' . s:neo_blue
exe 'hi String guifg=' . s:neo_green
exe 'hi Character guifg=' . s:neo_green
exe 'hi Number guifg=' . s:neo_blue
exe 'hi Boolean guifg=' . s:neo_blue
exe 'hi Float guifg=' . s:neo_blue

exe 'hi Identifier guifg=' . s:neo_blue
exe 'hi Function guifg=' . s:neo_green

exe 'hi Statement guifg=' . s:neo_blue
exe 'hi Conditional guifg=' . s:neo_blue
exe 'hi Repeat guifg=' . s:neo_blue
exe 'hi Label guifg=' . s:neo_blue
exe 'hi Operator guifg=' . s:neo_light
exe 'hi Keyword guifg=' . s:neo_blue

exe 'hi PreProc guifg=' . s:neo_green
exe 'hi Include guifg=' . s:neo_blue
exe 'hi Define guifg=' . s:neo_blue
exe 'hi Macro guifg=' . s:neo_blue
exe 'hi PreCondit guifg=' . s:neo_blue

exe 'hi Type guifg=' . s:neo_green
exe 'hi StorageClass guifg=' . s:neo_blue
exe 'hi Structure guifg=' . s:neo_blue
exe 'hi Typedef guifg=' . s:neo_blue

exe 'hi Special guifg=' . s:neo_green
exe 'hi SpecialChar guifg=' . s:neo_blue
exe 'hi Tag guifg=' . s:neo_blue
exe 'hi Delimiter guifg=' . s:neo_light
exe 'hi SpecialComment guifg=' . s:neo_gray
exe 'hi Debug guifg=' . s:neo_blue

" Interface
exe 'hi Visual guibg=' . s:neo_gray
exe 'hi MatchParen guibg=' . s:neo_gray . ' guifg=' . s:neo_blue
exe 'hi StatusLine guifg=' . s:neo_light . ' guibg=' . s:neo_gray
exe 'hi StatusLineNC guifg=' . s:neo_gray . ' guibg=' . s:neo_dark
exe 'hi VertSplit guifg=' . s:neo_gray . ' guibg=' . s:neo_dark
exe 'hi Pmenu guifg=' . s:neo_light . ' guibg=' . s:neo_gray
exe 'hi PmenuSel guifg=' . s:neo_white . ' guibg=' . s:neo_blue
exe 'hi Search guibg=' . s:neo_gray . ' guifg=' . s:neo_white

