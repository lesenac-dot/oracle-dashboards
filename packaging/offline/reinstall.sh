#!/usr/bin/env bash
# Oracle Dashboards - REINSTALA offline (recria o venv do zero a partir dos wheels locais).
# Use ao ATUALIZAR o pacote nesta mesma pasta, ou se o venv corromper.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP="$HERE/oracle_dashboards"

if [ -d "$APP/.venv" ]; then
  echo "-> Removendo venv antigo: $APP/.venv"
  rm -rf "$APP/.venv"
fi

echo "-> Recriando ambiente..."
exec bash "$HERE/install.sh"
