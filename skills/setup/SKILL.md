---
name: setup
description: Configura a statusline do plugin statusbar no Claude Code desta máquina — confere requisitos, aponta o statusLine do ~/.claude/settings.json para o script instalado e limpa os caches. Use quando a pessoa pedir para instalar, configurar, ativar, reparar ou desinstalar a statusbar, ou quando a barra não aparecer depois de instalar o plugin.
---

# Configurar a statusbar

O plugin já mantém o script atualizado sozinho: a cada início de sessão, um hook copia o
`status-bar.sh` da versão instalada para `~/.claude/statusbar/status-bar.sh`. O que falta, e só
precisa ser feito uma vez por máquina, é o `statusLine` do `settings.json` apontar para esse
caminho. Esta skill faz isso.

Siga os passos em ordem e fale com a pessoa em linguagem simples.

## 1. Instalar o script agora

O hook só roda no início da próxima sessão; rode o instalador para não depender disso:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/install.sh" && ls -l ~/.claude/statusbar/status-bar.sh
```

Se `CLAUDE_PLUGIN_ROOT` vier vazio, encontre a pasta do plugin com
`ls -d ~/.claude/plugins/cache/*/statusbar/*/ | tail -1` e rode o `scripts/install.sh` de lá.

## 2. Conferir os requisitos

```bash
bash --version | head -1; for c in jq git awk stat; do command -v "$c" >/dev/null && echo "ok  $c" || echo "FALTA  $c"; done
```

`jq` é o essencial: sem ele a barra aparece quase vazia, sem erro nenhum. Se faltar algo, diga
como instalar (`brew install jq` no macOS, `sudo apt install jq` no Debian/Ubuntu,
`winget install jqlang.jq` no Windows com Git Bash) e continue — a configuração vale mesmo antes.

## 3. Apontar o statusLine

Leia o que existe hoje:

```bash
jq '.statusLine // "nenhum"' ~/.claude/settings.json 2>/dev/null || echo "sem settings.json"
```

- **Já aponta para `~/.claude/statusbar/status-bar.sh`:** nada a fazer; vá ao passo 4.
- **Aponta para outro comando:** mostre qual é e pergunte se pode trocar. O comando antigo fica
  registrado na resposta, para a pessoa voltar se quiser. Se ela disser não, pare aqui.
- **Não existe:** siga.

Grave só a chave `statusLine`, preservando todo o resto, com backup antes:

```bash
f=~/.claude/settings.json
[ -f "$f" ] || echo '{}' > "$f"
cp "$f" "$f.bak-statusbar"
jq '.statusLine = {"type": "command", "command": "bash ~/.claude/statusbar/status-bar.sh"}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
jq '.statusLine' "$f"
```

## 4. Testar e limpar caches

```bash
rm -f /tmp/statusline-git-* /tmp/statusline-acct-*
echo '{"session_id":"setup","model":{"display_name":"Teste"},"workspace":{"current_dir":"'"$PWD"'"}}' \
  | bash ~/.claude/statusbar/status-bar.sh | sed 's/\x1b\[[0-9;]*m//g'; echo
```

Duas linhas de texto significam que funcionou. Uma linha quase vazia quase sempre é `jq` faltando.

## 5. Fechar

Diga à pessoa que a barra aparece na próxima atualização da tela (ou ao abrir uma sessão nova) e
que as próximas versões chegam sozinhas com o update do plugin. Mencione o backup em
`~/.claude/settings.json.bak-statusbar`.

## Desinstalar

Se a pessoa pedir para remover: tire a chave `statusLine` (ou restaure o backup) e apague
`~/.claude/statusbar/`, e lembre que o plugin em si sai com `/plugin uninstall statusbar`.

```bash
f=~/.claude/settings.json; cp "$f" "$f.bak-statusbar"; jq 'del(.statusLine)' "$f" > "$f.tmp" && mv "$f.tmp" "$f"; rm -rf ~/.claude/statusbar
```
