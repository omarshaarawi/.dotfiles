export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$HOME/bin:$HOME/.local/bin:$HOME/go/bin:/usr/local/go/bin"

export ZSH=/Users/Shaarawi/.oh-my-zsh
export OPENAI_API_KEY=$(op item get 'OpenAI Key' --field credential)
export DEFAULT_USER="$(whoami)"
export EDITOR="vim"
export ZSH_THEME="robbyrussell"
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
export GITHUB_USERNAME="omarshaarawi"
export JAVA_HOME="/Library/Java/JavaVirtualMachines/graalvm-ce-java17-21.3.0/Contents/Home"
export PROG=urfave
#export GOROOT=/usr/local/go
#export GOPATH=$HOME/go


alias ez='vim ~/.zshrc'
alias sz='source ~/.zshrc'
alias vim=nvim
alias vi=nvim
alias mv='mv -i'
alias rm='rm -I'
alias python=/usr/local/bin/python3
alias gfp="git commit --amend --no-edit && git push --force-with-lease"

plugins=(
  git
  zsh-autosuggestions
  brew
  z
)


source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $ZSH/oh-my-zsh.sh

declare -x -A configs
configs=(
    git "$HOME/.config/git/config"
    nvim "$HOME/.config/nvim/lua/shaarawi/packer.lua"
    wezterm "$HOME/.wezterm.lua"
    zsh "$HOME/.zshrc"

    )
for key value in ${(kv)configs}; do
    if [[ $key == "zsh" ]]
        then
            alias ${key}config="nvim $value && source $value && echo
$configs[zsh] has been sourced"
     else
        alias ${key}config="nvim $value"
    fi
done


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


