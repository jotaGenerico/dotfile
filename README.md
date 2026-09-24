
# 💻 Dotfiles: Bash, Kate, Vim & Neovim

Repositório de configurações para produtividade e ambiente de desenvolvimento onde quer que eu va (hu3).

## 📂 Organização de Arquivos

Toda a configuração está concentrada no diretório `arkivos/`:

-   **Fontes**: Localizadas em `arkivos/ambiente/`. Inclui ComicShanns, OpenDyslexic e Powerline Symbols.

-   **Temas (Colorschemes)**:

    -   **Vim**: Em `arkivos/vim/colors/` (Ex: `jota.vim`, `cyberPunk.vim`).

    -   **Neovim**: Em `arkivos/nvim/colors/` (`jotan.lua`).

    -   **Bash**: Em `arkivos/bash/custom/themes/jota/`.


## 🛠️ Como Utilizar

### 1. Vim

Escolha um dos perfis em `arkivos/vim/` e linke para sua home:

Bash

```
# Exemplo para usar a configuração atual da 42
ln -s ~/dotfile/arkivos/vim/vimrc_42sp ~/.vimrc

# Copie os temas para o diretório do Vim
mkdir -p ~/.vim/colors
cp ~/dotfile/arkivos/vim/colors/* ~/.vim/colors/

```

### 2. Neovim (Nvim)

A configuração principal está em `arkivos/nvim/init.lua`.

Bash

```
mkdir -p ~/.config/nvim
ln -s ~/dotfile/arkivos/nvim/init.lua ~/.config/nvim/init.lua
ln -s ~/dotfile/arkivos/nvim/coc-settings.json ~/.config/nvim/coc-settings.json

```

### 3. Bash

Integre o `bashrc` customizado:

Bash

```
cat ~/dotfile/arkivos/bash/bashrc >> ~/.bashrc

```

## 📝 Notas

-   **Cheat Sheet**: Consulte `arkivos/vim_cheat_sheet.png` para atalhos rápidos.

-   **Linter 42**: O arquivo `arkivos/nvim/arkivos/clang.format-42` está disponível para padronização de código.


----------

### Cuidado com o `init.lua.b`:  arquivos com extensão `.b` ou `.original` são backups e não devem ser usados como principal.
