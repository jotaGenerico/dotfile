call plug#begin()
Plug 'mhinz/vim-startify'
Plug 'ryanoasis/vim-devicons'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'Yggdroot/indentLine'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'sheerun/vim-polyglot'
Plug 'preservim/nerdtree'
Plug 'preservim/nerdcommenter'
Plug 'dense-analysis/ale'
Plug 'jiangmiao/auto-pairs'
Plug 'davidhalter/jedi-vim'

call plug#end()

" Global Sets
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax on                   " Enable syntax highlight
set nu                      " Enable line numbers
set relativenumber
set tabstop=4               " Show existing tab with 4 spaces width
set softtabstop=4           " Show existing tab with 4 spaces width
set shiftwidth=4            " When indenting with '>', use 4 spaces width
set noexpandtab             " On pressing tab, insert real tab spaces
set smarttab                " insert tabs on the start of a line according to shiftwidth
set smartindent             " Automatically inserts one extra level of indentation in some cases
set hidden                  " Hides the current buffer when a new file is openned
set incsearch               " Incremental search
set ignorecase              " Ingore case in search
set smartcase               " Consider case if there is a upper case character
set scrolloff=8             " Minimum number of lines to keep above and below the cursor
set colorcolumn=81          " Draws a line at the given line to keep aware of the line size
set signcolumn=yes          " Add a column on the left. Useful for linting
set cmdheight=1             " Give more space for displaying messages
set updatetime=100          " Time in miliseconds to consider the changes
set encoding=utf-8          " The encoding should be utf-8 to activate the font icons
set termguicolors           " Colors 24 bits
set nobackup                " No backup files
set nowritebackup           " No backup files
set splitright              " Create the vertical splits to the right
set splitbelow              " Create the horizontal splits below
set autoread                " Update vim after file update from outside
set mouse=a                 " Enable mouse support
set history=500             " By default is 50
set cursorline              " Highlight on edit line
set laststatus=1            " Show information on status bar
set clipboard=unnamedplus   " Share clipboard with the system
filetype on                 " Detect and set the filetype option and trigger the FileType Event
filetype plugin on          " Load the plugin file for the file type, if any
filetype indent on          " Load the indent file for the file type, if any
let mapleader = "\\"        " maplear para \

set completeopt=menuone,noinsert,noselect  " Opções de completamento
set omnifunc=syntaxcomplete#Complete        " Função de completamento omni
set wildmenu                                " Ativa o menu de completamento
set wildmode=list:longest,full              " Modo de completamento
set guifont=ComicShannsMono\ Nerd\ Font\ Mono:h12



" Themes
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"if exists('+termguicolors')
"  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
"  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
"endif

colo jota

let g:NERDTreeHighlightCursorline = 0


" Terminal
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mapeamento para abrir um terminal (yank nao funciona)
nnoremap <silent> <C-t> :botright terminal ++rows=9<CR>
nnoremap <silent> <leader>z :botright terminal ++rows=9<CR>

autocmd BufEnter term://* silent! nnoremap <buffer> <C-c> "+y
autocmd BufEnter term://* silent! vnoremap <buffer> <C-c> "+y

if has('terminal')
  " Define as cores para o terminal
  let g:terminal_ansi_colors = [
    \ '#000000', '#FF0000', '#00FF00', '#FFFF00',
    \ '#3465A4', '#FF00FF', '#00FFFF', '#FFFFFF',
    \ '#808080', '#FF8080', '#80FF80', '#FFFF80',
    \ '#729FCF', '#FF80FF', '#80FFFF', '#FFFFFF'
    \ ]

  " Configura o shell para usar cores
  let &t_AB="\e[48;5;%dm"
  let &t_AF="\e[38;5;%dm"

    " Configura a aparência do terminal embutido
  if exists('+winhighlight')
    autocmd TerminalOpen * setlocal winhighlight=Normal:Normal
  endif
  autocmd TerminalOpen * setlocal nonumber norelativenumber signcolumn=no
endif



" IdentLine
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable vertical indentation lines
let g:indentLine_enabled = 1
let g:indentLine_setColors = 0  " Use default theme colors

" Show tab characters visually (| instead of whitespace)
set listchars=tab:\|.

" Key mappings to toggle invisible characters
nnoremap <leader>si :set list<CR>    " \vl => show invisible characters
nnoremap <leader>hi :set nolist<CR>  " \vu => hide invisible characters



" NerdTree
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set guifont=ComicShannsMono\ Nerd\ Font\ Mono:h12

" Ignorar arquivos .o e .out
let g:NERDTreeIgnore = ['\.o$', '\.out$']

" Exit Vim if NERDTree is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | call feedkeys(":quit\<CR>:\<BS>") | endif

" Toggle NERDTree
map <C-a> :NERDTreeToggle<CR>
nnoremap <leader>a :NERDTreeToggle<CR>



" Navegação entre splits com Ctrl + setas
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <C-Left>  <C-w>h
nnoremap <C-Down>  <C-w>j
nnoremap <C-Up>    <C-w>k
nnoremap <C-Right> <C-w>l

" Navegação entre buffers de código com Alt + setas (ignora NERDTree e terminal)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! SafeBufferNext()
    let l:start = bufnr('%')
    let l:current = l:start
    let l:limit = bufnr('$') + 10  " segurança pra evitar loop infinito
    while 1
        execute 'bnext'
        if &filetype !=# 'nerdtree' && &buftype !=# 'terminal'
            return
        endif
        let l:current = bufnr('%')
        if l:current == l:start || l:limit == 0
            return
        endif
        let l:limit -= 1
    endwhile
endfunction

function! SafeBufferPrev()
    let l:start = bufnr('%')
    let l:current = l:start
    let l:limit = bufnr('$') + 10
    while 1
        execute 'bprevious'
        if &filetype !=# 'nerdtree' && &buftype !=# 'terminal'
            return
        endif
        let l:current = bufnr('%')
        if l:current == l:start || l:limit == 0
            return
        endif
        let l:limit -= 1
    endwhile
endfunction

nnoremap <M-Right> :call SafeBufferNext()<CR>
nnoremap <M-Left> :call SafeBufferPrev()<CR>



" AirLine
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:airline#extensions#tabline#formatter = 'jsformatter'
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline#extensions#branch#enabled = 0
let g:airline_statusline_ontop=0
let g:airline_theme='jota'

nnoremap <leader><Right> :bn<CR>
nnoremap <leader><Left> :bp<CR>
nnoremap <leader>d :bp \| bd #<CR>



" CtrlP
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ctrlp_custom_ignore = '\v[\/]\.(swp|zip|o)$'
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
let g:ctrlp_show_hidden = 1



" NerdCommenter
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:NERDDefaultNesting = 1
let g:NERDAltDelims_c = 1
let g:NERDSpaceDelims = 3
let g:NERDDefaultAlign = 'left'
" let g:NERDDefaultLiner = '// %s'
let g:NERDCompactSexyComs = 1

" Normal + Visual mode para melhor controle
nnoremap <leader>l <Plug>NERDCommenterInsert
vnoremap <leader>l <Plug>NERDCommenterInsert

nnoremap <leader>c <Plug>NERDCommenterInvert
vnoremap <leader>c <Plug>NERDCommenterInvert

nnoremap <leader>b <Plug>NERDCommenterBlock
vnoremap <leader>b <Plug>NERDCommenterBlock

nnoremap <leader>s <Plug>NERDCommenterToggle
vnoremap <leader>s <Plug>NERDCommenterToggle



" Jedi
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:jedi#popup_on_dot = 0
let g:jedi#show_call_signatures = 0
let g:jedi#environment_path = "venv"
let g:jedi#completions_enabled = 0



" Ale
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ale_enabled = 1
let g:ale_completion_enabled = 1

" Definir os linters para linguagens
let g:ale_linters = {
    \ 'c': ['gcc'],
    \ 'cpp': [],
    \ 'python': [],
    \ 'html': [],
    \ 'sh': ['shellcheck'],
    \ }

" Desativar correção automática
let g:ale_fix_on_save = 0
let g:ale_fixers = {'c': [], 'cpp': []}

" C/C++ (configuracao de formatacao)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""




" Python
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""




" Remap
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Adding an empty line below, above and below with insert
nmap op o<Esc>k
nmap oi O<Esc>j
nmap oo A<CR>

" Remap usando o mapleader (\ como prefixo)
" Inserir linhas acima/abaixo
nnoremap <leader>p o<Esc>k
nnoremap <leader>i O<Esc>j
nnoremap <leader>o A<CR>

" Criar nova aba
nnoremap <leader>t :tabe<CR>

" Navegar entre buffers
nnoremap <leader>n :bn<CR>
nnoremap <leader>b :bp<CR>

" Criar splits caso isso seja util um dia
" nnoremap <leader>h :split<CR>
" nnoremap <leader>v :vsplit<CR>

" Fechar split / aba
nnoremap <leader>q :bd<CR>

" Atalho para comandos (:!)
nnoremap <leader>c :!

" Rodar script atual (ex: python)
nnoremap <leader>r :!python %<CR>

" ativando um yank para o clipboard perde funcionalidade yank padrao
" vnoremap y:w !xclip -selection clipboard<CR><CR>

" Copia pro clipboard e salva no yank interno também
vnoremap y y:call system('xclip -selection clipboard', @")<CR>




" Pessoais
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" buscar e substituir
" %s/palavra_antiga/palavra_nova/g



" Funcoes
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! <SID>StdHeader()
    execute "normal! i/* ************************************************************************** */"
    execute "normal! o/*                                                                            */"
    execute "normal! o/*                                                        :::      ::::::::   */"
    execute "normal! o/*   ft_forty-two.c                                     :+:      :+:    :+:   */"
    execute "normal! o/*                                                    +:+ +:+         +:+     */"
    execute "normal! o/*   By: drown-ed <drown-ed@student.42.fr>          +#+  +:+       +#+        */"
    execute "normal! o/*                                                +#+#+#+#+#+   +#+           */"
    execute "normal! o/*   Created: 8888/88/88 88:88:88 by drown-ed          #+#    #+#             */"
    execute "normal! o/*   Updated: 8888/88/88 88:88:88 by drown-ed         ###   ########.SP       */"
    execute "normal! o/*                                                                            */"
    execute "normal! o/* ************************************************************************** */\n\n"
endfunction

" Mapeamento para adicionar um cabeçalho padrão ao pressionar F1
map <silent> <F1> :call <SID>StdHeader()<CR>
