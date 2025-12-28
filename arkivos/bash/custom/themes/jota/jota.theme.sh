#! bash oh-my-bash.module
# Tema Minimalista J - Git Status com Cores (CORRIGIDO)

# ========== CORES COM ESCAPE BASH ==========
# O uso de \[ e \] é obrigatório para o Bash não se perder no cálculo da linha
if tput setaf 1 &> /dev/null; then
  BLUE="\[$(tput setaf 4)\]"
  GREEN="\[$(tput setaf 2)\]"
  RED="\[$(tput setaf 1)\]"
  RESET="\[$(tput sgr0)\]"
else
  BLUE="\[\033[0;34m\]"
  GREEN="\[\033[0;32m\]"
  RED="\[\033[0;31m\]"
  RESET="\[\033[0m\]"
fi

# ========== FUNÇÃO: Status Git ==========
function git_status_symbol() {
  if git rev-parse --git-dir > /dev/null 2>&1; then
    # --porcelain é rápido, mas git status ainda custa IO
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
      echo -e "${RED}"
    else
      echo -e "${GREEN}"
    fi
  else
    echo -e "${GREEN}"
  fi
}

# ========== FUNÇÃO: Diretório Pai/Atual ==========
function short_pwd() {
  local pwd_info=$(pwd)
  local home_dir="$HOME"

  pwd_info=${pwd_info/$home_dir/\~}

  # IFS local para evitar efeitos colaterais
  local IFS='/'
  local dir_array=($pwd_info)
  local array_length=${#dir_array[@]}

  if [[ $array_length -gt 2 ]]; then
    echo "${dir_array[$array_length-2]}/${dir_array[$array_length-1]}"
  else
    echo "$pwd_info"
  fi
}

# ========== PROMPT PRINCIPAL ==========
function _omb_theme_PROMPT_COMMAND() {
  local git_color=$(git_status_symbol)
  # Aplicamos as cores protegidas aqui
  local dir_path="${BLUE}($(short_pwd))${RESET}"
  local prompt_symbol='_$'

  # PS1 montado com as variáveis que já contêm \[ e \]
  PS1="${dir_path}${git_color}${prompt_symbol}${RESET} "
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
