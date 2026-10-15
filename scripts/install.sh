#!/usr/bin/env bash
# Copia o status-bar.sh da versão instalada do plugin para um caminho fixo, que o statusLine do
# settings.json referencia. Roda a cada início de sessão: assim um update do plugin chega à barra
# sem passo manual. Não imprime nada — a saída de um hook SessionStart vai para o contexto do modelo.

src="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}/status-bar.sh"
dst="$HOME/.claude/statusbar/status-bar.sh"

[ -r "$src" ] || exit 0
if ! cmp -s "$src" "$dst" 2>/dev/null; then
  mkdir -p "$(dirname "$dst")" && cp "$src" "$dst" 2>/dev/null || exit 0
  # Versão nova: descarta os caches para a barra refletir a mudança na hora.
  rm -f /tmp/statusline-git-* /tmp/statusline-acct-* 2>/dev/null
fi
exit 0
