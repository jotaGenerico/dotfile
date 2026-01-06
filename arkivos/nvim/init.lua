-- ========================================================================== --
-- 0. NODE NPM PATH (para CoC funcionar)
-- ========================================================================== --
vim.g.coc_node_path = '/usr/local/bin/node'

-- ========================================================================== --
-- 1. PLUGINS (Vim-Plug)
-- ========================================================================== --
local Plug = vim.fn['plug#']
vim.fn['plug#begin']('~/.local/share/nvim/plugged')

-- Temas
Plug 'sainnhe/sonokai'
Plug 'rebelot/kanagawa.nvim'
Plug 'projekt0n/github-nvim-theme'

-- Visual e Interface
Plug 'ryanoasis/vim-devicons'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-lualine/lualine.nvim'
Plug('akinsho/bufferline.nvim', { ['tag'] = 'v4.*' })
Plug 'nvim-tree/nvim-tree.lua'

-- Syntax e Highlight
Plug('nvim-treesitter/nvim-treesitter', { ['tag'] = 'v0.9.2' })

-- Produtividade
Plug 'windwp/nvim-autopairs'
Plug 'numToStr/Comment.nvim'
Plug 'folke/which-key.nvim'
Plug 'github/copilot.vim'

-- Git Integration
Plug 'lewis6991/gitsigns.nvim'

-- Busca e Navegação
Plug 'nvim-lua/plenary.nvim'
Plug('nvim-telescope/telescope.nvim', { ['tag'] = '0.1.8' })

-- LSP e Autocomplete
Plug('neoclide/coc.nvim', {branch = 'release'})

vim.fn['plug#end']()

-- ========================================================================== --
-- 2. CONFIGURAÇÃO DOS PLUGINS
-- ========================================================================== --
-- Copilot começa DESLIGADO
vim.g.copilot_enabled = false
vim.g.copilot_no_tab_map = true
-- Aceitar sugestão do Copilot com Ctrl + L
vim.api.nvim_set_keymap(
  'i',
  '<C-l>',
  'copilot#Accept("\\<CR>")',
  { expr = true, silent = true }
)
-- Função para ligar/desligar Copilot
_G.toggle_copilot = function()
  if vim.g.copilot_enabled then
    vim.cmd('Copilot disable')
    vim.g.copilot_enabled = false
    print("Copilot: OFF")
  else
    vim.cmd('Copilot enable')
    vim.g.copilot_enabled = true
    print("Copilot: ON")
  end
end

-- Treesitter (syntax highlight moderno)
require('nvim-treesitter.configs').setup({
  ensure_installed = { "c", "cpp", "python", "lua", "vim", "bash" },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = false
  },
})

-- Autopairs (fecha parênteses, aspas, colchetes)
require('nvim-autopairs').setup({
  check_ts = false,
  fast_wrap = {},
  disable_filetype = { "TelescopePrompt", "vim" },
  map_cr = true,
  map_bs = true,
})

-- Gitsigns (git diff visual)
require('gitsigns').setup({
  signs = {
    add          = { text = '│' },
    change       = { text = '│' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
  },
})

-- Which-key (mostra atalhos)
require('which-key').setup({
  triggers = {"<leader>"},
})

-- Lualine (barra de status)
require('lualine').setup({
  options = {
    theme = 'auto',
    icons_enabled = true,
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
  },
})

-- Bufferline (abas/buffers)
require('bufferline').setup({
  options = {
    mode = 'buffers',
    numbers = 'none',
    close_command = 'bdelete! %d',
    right_mouse_command = 'bdelete! %d',
    left_mouse_command = 'buffer %d',
    indicator = {
      style = 'icon',
      icon = '▎',
    },
    buffer_close_icon = '󰅖',
    modified_icon = '●',
    close_icon = '',
    left_trunc_marker = '',
    right_trunc_marker = '',
    diagnostics = 'coc',
    diagnostics_indicator = function(count, level)
      local icon = level:match("error") and " " or " "
      return " " .. icon .. count
    end,
    offsets = {
      {
        filetype = 'NvimTree',
        text = 'File Explorer',
        text_align = 'center',
        separator = true,
      }
    },
    separator_style = 'slant',
    show_buffer_icons = true,
    show_buffer_close_icons = true,
    show_close_icon = false,
    show_tab_indicators = true,
    persist_buffer_sort = true,
    enforce_regular_tabs = false,
    always_show_bufferline = true,
  },
})

-- Nvim-tree (file explorer)
require('nvim-tree').setup({
  disable_netrw = true,
  hijack_netrw = true,
  sync_root_with_cwd = true,
  respect_buf_cwd = true,
  update_focused_file = {
    enable = true,
    update_root = true,
  },
  view = {
    width = 25,
    side = 'left',
  },
  renderer = {
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
      },
    },
  },
  filters = {
    dotfiles = false,
    git_ignored = false,
    custom = { 'node_modules', '.cache' },
  },
})

-- CCC começa DESLIGADO
vim.g.coc_enabled = false
vim.g.coc_snippet_disable = 1
vim.g.coc_snippet_next = ''
vim.g.coc_snippet_prev = ''
-- Função para ligar/desligar CoC
_G.toggle_coc = function()
  if vim.g.coc_enabled == false then
    vim.cmd('CocEnable')
    vim.g.coc_enabled = true
    print("CoC: ON")
  else
    vim.cmd('CocDisable')
    vim.g.coc_enabled = false
    print("CoC: OFF")
  end
end

-- Função para ligar/desligar Copilot/CoC
_G.toggle_code_suggestions = function()
  if vim.g.copilot_enabled or vim.g.coc_enabled then
    vim.cmd('Copilot disable')
    vim.cmd('CocDisable')
    vim.g.copilot_enabled = false
    vim.g.coc_enabled = false
    print("Sugestões de código: OFF")
  else
    vim.cmd('Copilot enable')
    vim.cmd('CocEnable')
    vim.g.copilot_enabled = true
    vim.g.coc_enabled = true
    print("Sugestões de código: ON")
  end
end

-- Comment.nvim (comentários)
require('Comment').setup()

-- ========================================================================== --
-- 3. CONFIGURAÇÕES GERAIS
-- ========================================================================== --
local opt = vim.opt

opt.autoindent = true
opt.clipboard = "unnamedplus"
opt.colorcolumn = "80"
opt.cursorline = true
opt.expandtab = false
opt.ignorecase = true
opt.mouse = "a"
opt.number = true
opt.relativenumber = true
opt.scrolloff = 10
opt.shiftwidth = 4
opt.signcolumn = "yes"
opt.smartcase = true
opt.smartindent = false
opt.splitbelow = true
opt.splitright = true
opt.syntax = "on"
opt.tabstop = 4
opt.termguicolors = true
opt.updatetime = 300

-- INVISIVEIS
opt.list = true
opt.listchars = {
  tab = '→ ',
  trail = '·',
}


-- ========================================================================== --
-- 4. TEMA E TRANSPARÊNCIA
-- ========================================================================== --
vim.g.sonokai_style = 'andromeda'

local function apply_transparency()
    local groups = {
        "Normal", "NormalNC", "EndOfBuffer", "SignColumn",
        "Pmenu", "TelescopeBorder", "LineNr", "CursorLineNr",
        "BufferLineFill", "BufferLineBackground",
        "NvimTreeNormal", "NvimTreeNormalNC", "NvimTreeEndOfBuffer",
        "NvimTreeVertSplit", "NvimTreeStatusLine", "NvimTreeStatusLineNC"
    }
    for _, group in ipairs(groups) do
        vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
    end
    vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#000000", ctermbg = 236 })
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "#0a0a0a", ctermbg = 234 })
end

-- Escolha seu tema aqui
vim.cmd('colorscheme jotan')
-- vim.cmd('colorscheme sonokai')
-- vim.cmd('colorscheme kanagawa')
-- vim.cmd('colorscheme github_dark')

vim.defer_fn(apply_transparency, 100)

vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        vim.defer_fn(apply_transparency, 100)
    end
})

-- ========================================================================== --
-- 5. ATALHOS (KEYMAPS)
-- ========================================================================== --
local keymap = vim.keymap.set
vim.g.mapleader = "\\"

keymap('n', '<C-a>', ':NvimTreeToggle<CR>')
keymap('n', '<leader>d', ':bp | bd #<CR>', { silent = true })
keymap('n', '<C-h>', '<C-w>h')
keymap('n', '<C-j>', '<C-w>j')
keymap('n', '<C-k>', '<C-w>k')
keymap('n', '<C-l>', '<C-w>l')
keymap('n', '<M-Right>', ':BufferLineCycleNext<CR>')
keymap('n', '<M-Left>', ':BufferLineCyclePrev<CR>')
keymap('n', '<leader>ff', ':Telescope find_files<CR>')
keymap('n', '<leader>fg', ':Telescope live_grep<CR>')

-- Atalho para ligar/desligar Copilot/Coc
keymap('n', '<leader>tc', ':lua toggle_copilot()<CR>', { silent = true })
keymap('n', '<leader>tl', ':lua toggle_coc()<CR>', { silent = true })
keymap('n', '<leader>ta', ':lua toggle_code_suggestions()<CR>', { silent = true })


-- Comentar e Descomentar estilo VS Code (Ctrl + /)
-- No modo normal: comenta a linha
keymap('n', '<C-_>', 'gcc', { remap = true, silent = true })
keymap('n', '<C-/>', 'gcc', { remap = true, silent = true })
-- No modo visual: comenta o bloco selecionado
keymap('v', '<C-_>', 'gc', { remap = true, silent = true })
keymap('v', '<C-/>', 'gc', { remap = true, silent = true })

-- Terminal
keymap('n', '<C-t>', ':botright split | resize 9 | terminal<CR>i', { silent = true })
keymap('t', '<Esc>', [[<C-\><C-n>]], { silent = true })
keymap('t', '<C-w>h', [[<C-\><C-n><C-w>h]], { silent = true })
keymap('t', '<C-w>j', [[<C-\><C-n><C-w>j]], { silent = true })
keymap('t', '<C-w>k', [[<C-\><C-n><C-w>k]], { silent = true })
keymap('t', '<C-w>l', [[<C-\><C-n><C-w>l]], { silent = true })

vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "*",
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
    end
})

-- ========================================================================== --
-- 6. COC CONFIG (AUTOCOMPLETE E LINTER)
-- ========================================================================== --

-- TAB e ENTER devem ser SEMPRE literais (sem autocomplete automático)
vim.api.nvim_set_keymap('i', '<Tab>', '<Tab>', { noremap = true, silent = true })

-- Autocomplete SOMENTE sob comando
-- Ctrl + Space abre o menu de sugestões
vim.keymap.set('i', '<C-Space>', 'coc#refresh()', { expr = true, silent = true })

-- Ctrl + y confirma sugestão (quando o menu estiver aberto)
vim.api.nvim_set_keymap(
  'i',
  '<C-y>',
  'coc#pum#visible() ? coc#pum#confirm() : "\\<C-y>"',
  { expr = true, noremap = true, silent = true }
)

-- Desativa inlay hints (poluição visual e anti-42)
vim.g.coc_enable_inlay_hint = 0


-- ========================================================================== --
-- 7. NORMA 42 (HEADER)
-- ========================================================================== --
_G.insert_std_header = function()
    local header = {
        "/* ************************************************************************** */",
        "/*                                                                          */",
        "/*                                                       :::      ::::::::   */",
        "/*  ft_forty-two.c                                     :+:      :+:    :+:   */",
        "/*                                                   +:+ +:+         +:+     */",
        "/*  By: drown-ed <drown-ed@student.42.fr>          +#+  +:+       +#+        */",
        "/*                                               +#+#+#+#+#+   +#+           */",
        "/*  Created: 8888/88/88 88:88:88 by drown-ed          #+#    #+#             */",
        "/*  Updated: 8888/88/88 88:88:88 by drown-ed         ###   ########.fr       */",
        "/*                                                                                                                                                                                             */",
        "/* ************************************************************************** */",
        ""
    }
    vim.api.nvim_buf_set_lines(0, 0, 0, false, header)
end
keymap('n', '<F1>', ':lua insert_std_header()<CR>', { silent = true })
