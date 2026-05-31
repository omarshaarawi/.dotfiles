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

export PATH="$HOME/bin:$PATH"
export PATH="$PATH:$HOME/git/mobile-notary-infra/bin"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# auto-switch node version on cd if .nvmrc exists
autoload -U add-zsh-hook
_nvm_auto_use() {
  if [[ -f .nvmrc ]]; then
    nvm use --silent
  fi
}
add-zsh-hook chpwd _nvm_auto_use

# Atlassian MCP token for pi-mcp-adapter (reads from OpenCode's auth store)
export ATLASSIAN_MCP_TOKEN="Bearer $(node -e "process.stdout.write(JSON.parse(require('fs').readFileSync(require('os').homedir()+'/.local/share/opencode/mcp-auth.json','utf8')).atlassian.tokens.accessToken)" 2>/dev/null)"
export DATADOG_MCP_TOKEN="Bearer $(node -e "process.stdout.write(JSON.parse(require('fs').readFileSync(require('os').homedir()+'/.local/share/opencode/mcp-auth.json','utf8')).datadog.tokens.accessToken)" 2>/dev/null)"

# sentry
fpath=("/Users/shaarawi/.local/share/zsh/site-functions" $fpath)

# 1Password service account for unattended op (Bloombilt vault, read-write)
[ -f "$HOME/.config/op/sa.env" ] && source "$HOME/.config/op/sa.env"
