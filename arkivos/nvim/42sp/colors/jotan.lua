-- jotan.lua - Tema jota adaptado para Neovim + Treesitter
-- Author: jota
-- Last Change: 2025

vim.cmd('hi clear')
if vim.fn.exists('syntax_on') then
  vim.cmd('syntax reset')
end

vim.o.termguicolors = true
vim.g.colors_name = 'jotan'

-- Paleta de cores
local colors = {
  bg = 'NONE',
  fg = '#d7d4cd',
  white = '#ffffff',
  green = '#58FF1E',
  yellow = '#ffff00',
  orange = '#FF8B00',
  red = '#ff0000',
  purple = '#5454ff',
  blue = '#2a38f9',
  black = '#121212',
  gray = '#111111',
  dark_gray = '#0a0a0a',
}

-- Função helper para definir highlights
local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- ============================================================================
-- GRUPOS BASE DO VIM
-- ============================================================================
hl('Normal', { fg = colors.fg, bg = colors.bg })
hl('NonText', { fg = colors.green, bg = colors.bg })
hl('Comment', { fg = colors.white, bg = colors.bg })
hl('Constant', { fg = colors.orange, bg = colors.bg })
hl('String', { fg = colors.yellow, bg = colors.bg })
hl('Number', { link = 'Constant' })
hl('Error', { fg = colors.red, bg = colors.bg })
hl('Identifier', { fg = colors.purple, bg = colors.bg })
hl('Function', { fg = colors.purple, bg = colors.bg })
hl('Statement', { fg = colors.green, bg = colors.bg })
hl('PreProc', { fg = colors.red, bg = colors.bg })
hl('Type', { fg = colors.green, bg = colors.bg })
hl('Special', { fg = colors.green, bg = colors.bg })
hl('Underlined', { fg = colors.green, bg = colors.bg, underline = true })
hl('Ignore', { fg = colors.fg, bg = colors.bg })
hl('Todo', { fg = colors.black, bg = colors.red })

-- Interface
hl('StatusLine', { fg = colors.purple, bg = colors.bg })
hl('StatusLineNC', { fg = colors.purple, bg = colors.bg })
hl('VertSplit', { fg = colors.fg, bg = colors.bg })
hl('TabLine', { fg = colors.purple, bg = colors.bg })
hl('TabLineFill', { fg = colors.fg, bg = colors.bg })
hl('TabLineSel', { fg = colors.black, bg = colors.purple })
hl('Title', { fg = colors.black, bg = colors.purple })

-- Cursor e Linhas
hl('CursorLine', { bg = colors.gray })
hl('CursorLineNr', { fg = colors.green, bg = colors.bg })
hl('LineNr', { fg = colors.purple, bg = colors.bg })
hl('ColorColumn', { bg = colors.dark_gray })
hl('SignColumn', { fg = colors.fg, bg = colors.bg })

-- Visual
hl('Visual', { fg = colors.purple, bg = colors.bg, reverse = true })
hl('VisualNOS', { underline = true })

-- Menus
hl('Pmenu', { fg = colors.fg, bg = colors.bg })
hl('PmenuSel', { fg = colors.fg, bg = colors.bg })
hl('PmenuSbar', { fg = colors.fg, bg = colors.bg })
hl('PmenuThumb', { fg = colors.fg, bg = colors.bg })

-- Busca
hl('Search', { fg = '#003b4f', bg = '#222222' })
hl('IncSearch', { fg = '#000000', bg = colors.green })

-- Diff
hl('DiffAdd', { fg = colors.black, bg = colors.green })
hl('DiffChange', { fg = colors.black, bg = colors.orange })
hl('DiffDelete', { fg = colors.fg, bg = colors.red })
hl('DiffText', { fg = colors.fg, bg = colors.bg })

-- Outros
hl('Directory', { fg = colors.purple, bg = colors.bg })
hl('ErrorMsg', { fg = colors.red, bg = colors.bg })
hl('MatchParen', { fg = colors.fg, bg = colors.bg })

-- ============================================================================
-- TREESITTER (Syntax Highlight Moderno)
-- ============================================================================

-- Funções em ROXO (como no tema original)
hl('@function', { fg = colors.purple })
hl('@function.call', { fg = colors.purple })
hl('@function.builtin', { fg = colors.purple })
hl('@method', { fg = colors.purple })
hl('@method.call', { fg = colors.purple })
hl('@constructor', { fg = colors.purple })

-- Keywords (if, while, return, etc) em VERDE
hl('@keyword', { fg = colors.green })
hl('@keyword.function', { fg = colors.green })
hl('@keyword.return', { fg = colors.green })
hl('@keyword.operator', { fg = colors.green })
hl('@conditional', { fg = colors.green })
hl('@repeat', { fg = colors.green })
hl('@label', { fg = colors.green })

-- Tipos em VERDE
hl('@type', { fg = colors.green })
hl('@type.builtin', { fg = colors.green })
hl('@type.definition', { fg = colors.green })

-- Operadores em VERDE
hl('@operator', { fg = colors.green })

-- Variáveis (cinza/branco padrão)
hl('@variable', { fg = colors.fg })
hl('@variable.builtin', { fg = colors.fg })
hl('@parameter', { fg = colors.fg })
hl('@field', { fg = colors.fg })
hl('@property', { fg = colors.fg })

-- Strings em AMARELO
hl('@string', { fg = colors.yellow })
hl('@string.escape', { fg = colors.green })
hl('@string.special', { fg = colors.green })
hl('@character', { fg = colors.yellow })

-- Números em LARANJA
hl('@number', { fg = colors.orange })
hl('@float', { fg = colors.orange })
hl('@boolean', { fg = colors.orange })
hl('@constant', { fg = colors.orange })
hl('@constant.builtin', { fg = colors.orange })

-- Comentários em BRANCO
hl('@comment', { fg = colors.white })
hl('@comment.todo', { fg = colors.black, bg = colors.red })

-- Preprocessor (#include, #define) em VERMELHO
hl('@preproc', { fg = colors.red })
hl('@include', { fg = colors.red })
hl('@define', { fg = colors.red })
hl('@macro', { fg = colors.red })

-- Pontuação
hl('@punctuation.delimiter', { fg = colors.fg })
hl('@punctuation.bracket', { fg = colors.fg })
hl('@punctuation.special', { fg = colors.green })

-- Tags (HTML, etc)
hl('@tag', { fg = colors.green })
hl('@tag.attribute', { fg = colors.purple })
hl('@tag.delimiter', { fg = colors.fg })

-- ============================================================================
-- LSP / COC
-- ============================================================================
hl('DiagnosticError', { fg = colors.red })
hl('DiagnosticWarn', { fg = colors.orange })
hl('DiagnosticInfo', { fg = colors.purple })
hl('DiagnosticHint', { fg = colors.green })

-- ============================================================================
-- PLUGINS (Git, Tree, etc)
-- ============================================================================
-- GitSigns
hl('GitSignsAdd', { fg = colors.green })
hl('GitSignsChange', { fg = colors.orange })
hl('GitSignsDelete', { fg = colors.red })

-- NvimTree
hl('NvimTreeFolderName', { fg = colors.purple })
hl('NvimTreeOpenedFolderName', { fg = colors.purple, bold = true })
hl('NvimTreeRootFolder', { fg = colors.purple, bold = true })
hl('NvimTreeGitDirty', { fg = colors.orange })
hl('NvimTreeGitNew', { fg = colors.green })
hl('NvimTreeGitDeleted', { fg = colors.red })

-- Telescope
hl('TelescopeBorder', { fg = colors.purple, bg = colors.bg })
hl('TelescopePromptBorder', { fg = colors.purple, bg = colors.bg })
hl('TelescopeResultsBorder', { fg = colors.purple, bg = colors.bg })
hl('TelescopePreviewBorder', { fg = colors.purple, bg = colors.bg })
