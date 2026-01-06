#!/bin/bash

# 1. Cria diretórios necessários na home
mkdir -p ~/.config/nvim
mkdir -p ~/.local/share/nvim/site/autoload

# 2. Baixa o vim-plug se não existir
if [ ! -f ~/.local/share/nvim/site/autoload/plug.vim ]; then
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# 3. Cria um .clang-format padrão da 42 na home para o linter ler
cat << EOF > ~/.clang-format
BasedOnStyle: LLVM
IndentWidth: 4
UseTab: ForIndentation
BreakBeforeBraces: Allman
ColumnLimit: 80
EOF

echo "Setup concluído. Agora abra o nvim e rode :PlugInstall"
