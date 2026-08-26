#!/usr/bin/env bash
# Oracle Dashboards — Instalador
# Cria virtualenv isolado e instala dependências.
# Também adiciona o alias `oracle_dashboards` ao ~/.zshrc (ou ~/.bashrc).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SCRIPT_DIR/.venv"
SHELL_RC=""

# ── Detectar shell ──────────────────────────────────────────────────
if [[ -n "${ZSH_VERSION:-}" ]] || [[ "$SHELL" == */zsh ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ -n "${BASH_VERSION:-}" ]] || [[ "$SHELL" == */bash ]]; then
    SHELL_RC="$HOME/.bashrc"
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   Oracle Dashboards — Instalação                 ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ── Virtualenv ──────────────────────────────────────────────────────
if [[ ! -d "$VENV_DIR" ]]; then
    echo "→ Criando virtualenv em $VENV_DIR ..."
    python3 -m venv "$VENV_DIR"
else
    echo "→ Virtualenv já existe em $VENV_DIR"
fi

# ── Dependências ────────────────────────────────────────────────────
echo "→ Instalando dependências..."
"$VENV_DIR/bin/pip" install --upgrade pip -q
"$VENV_DIR/bin/pip" install -r "$SCRIPT_DIR/requirements.txt"

echo "→ Dependências instaladas:"
"$VENV_DIR/bin/pip" show oracledb textual rich 2>/dev/null | grep -E "^(Name|Version):" | paste - -

# ── Alias ───────────────────────────────────────────────────────────
ALIAS_LINE="alias oracle_dashboards='\"$SCRIPT_DIR/oracle_dashboards.sh\"'"

if [[ -n "$SHELL_RC" ]]; then
    if grep -q "oracle_dashboards" "$SHELL_RC" 2>/dev/null; then
        echo "→ Alias oracle_dashboards já existe em $SHELL_RC"
    else
        echo "" >> "$SHELL_RC"
        echo "# ── Oracle Dashboards ──────────────────────────────────────────────────────" >> "$SHELL_RC"
        echo "$ALIAS_LINE" >> "$SHELL_RC"
        echo "→ Alias adicionado em $SHELL_RC"
    fi
else
    echo "→ Shell não identificado. Adicione manualmente ao seu rc:"
    echo "   $ALIAS_LINE"
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   Instalação concluída!                  ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "  Recarregue o shell:   source $SHELL_RC"
echo "  Ou execute direto:    $SCRIPT_DIR/oracle_dashboards.sh"
echo ""
echo "  Opcional (export de PDF do painel F-Report):"
echo "    \"$VENV_DIR/bin/pip\" install --prefer-binary -r \"$SCRIPT_DIR/requirements-optional.txt\""
echo "    (o --prefer-binary evita compilar a Pillow em servidores com gcc antigo)"
echo ""
