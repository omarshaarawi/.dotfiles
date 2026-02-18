autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C

source ~/.zsh/common.zsh

if [[ -f ~/.is_work_machine ]]; then
    source ~/.zsh/work.zsh
else
    source ~/.zsh/personal.zsh
fi

source ~/.zsh/common_after.zsh


#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Turso
export PATH="$PATH:/Users/Shaarawi/.turso"
