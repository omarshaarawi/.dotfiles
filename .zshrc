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

