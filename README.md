
# 💻 Dotfiles: Bash, Kate, Vim & Konsole

Repositório de configurações para produtividade e ambiente de desenvolvimento onde quer que eu va (hu3).

## 📂 Organização de Arquivos

Toda a configuração está concentrada no diretório `arkivos/`:

-   **Fontes**: Localizadas em `arkivos/ambiente/`. Inclui ComicShanns, OpenDyslexic e Powerline Symbols.

-   **Vim**: `arkivos/vim/vimrc` (casa) e `arkivos/vim/vimrc42` (42). Temas em `arkivos/vim/colors/`.

-   **Bash**: `arkivos/bash/bashrc` (casa) e `arkivos/bash/bashrc42` (42). Tema do oh-my-bash em `arkivos/bash/custom/themes/jota/`.

-   **Konsole**: Perfis e esquemas de cores em `arkivos/bash/konsole/`.

-   **Kate**: Configuração em `arkivos/kate/` e tema de cores em `arkivos/kate/themes/jota.theme`.


## 🛠️ Como Utilizar

### 1. Fontes

```
mkdir -p ~/.local/share/fonts
unzip -o ~/dotfile/arkivos/ambiente/ComicShannsMono.zip -d ~/.local/share/fonts/
unzip -o ~/dotfile/arkivos/ambiente/OpenDyslexic.zip -d ~/.local/share/fonts/
unzip -o ~/dotfile/arkivos/ambiente/PowerlineExtraSymbols.zip -d ~/.local/share/fonts/PowerlineExtraSymbols
fc-cache -f
```

### 2. Vim

Plugins via vim-plug (`:PlugInstall` depois de copiar). Para copiar do vim para fora, instale o `vim-gtk3`.

```
cp ~/dotfile/arkivos/vim/vimrc ~/.vimrc
mkdir -p ~/.vim/colors
cp ~/dotfile/arkivos/vim/colors/* ~/.vim/colors/
```

### 3. Bash (oh-my-bash)

Com o oh-my-bash já instalado:

```
cp ~/dotfile/arkivos/bash/bashrc ~/.bashrc
mkdir -p ~/.oh-my-bash/custom/themes
cp -r ~/dotfile/arkivos/bash/custom/themes/jota ~/.oh-my-bash/custom/themes/
```

### 4. Konsole

```
mkdir -p ~/.local/share/konsole
cp ~/dotfile/arkivos/bash/konsole/*.profile ~/dotfile/arkivos/bash/konsole/*.colorscheme ~/.local/share/konsole/
```

### 5. Kate

```
cp ~/dotfile/arkivos/kate/katerc ~/dotfile/arkivos/kate/kateschemarc ~/dotfile/arkivos/kate/katevirc ~/.config/
mkdir -p ~/.config/kate ~/.local/share/org.kde.syntax-highlighting/themes
cp -r ~/dotfile/arkivos/kate/externaltools ~/dotfile/arkivos/kate/formatting ~/dotfile/arkivos/kate/lspclient ~/.config/kate/
cp ~/dotfile/arkivos/kate/themes/jota.theme ~/.local/share/org.kde.syntax-highlighting/themes/
```

## 📝 Notas

-   **Cheat Sheet**: Consulte `arkivos/vim_cheat_sheet.png` para atalhos rápidos.

-   **Linter 42**: O arquivo `arkivos/clang.format-42` está disponível para padronização de código.
