#!/bin/bash
set -euo pipefail

# Dokku / Heroku: слушаем порт из окружения
export KC_HTTP_PORT="${PORT:-8080}"

# Совместимость со старым README: KEYCLOAK_USER / KEYCLOAK_PASSWORD
if [[ -n "${KEYCLOAK_USER:-}" && -n "${KEYCLOAK_PASSWORD:-}" ]]; then
  export KEYCLOAK_ADMIN="${KEYCLOAK_ADMIN:-$KEYCLOAK_USER}"
  export KEYCLOAK_ADMIN_PASSWORD="${KEYCLOAK_ADMIN_PASSWORD:-$KEYCLOAK_PASSWORD}"
fi

# Совместимость: PROXY_ADDRESS_FORWARDING=true -> trust X-Forwarded-* от nginx Dokku
if [[ "${PROXY_ADDRESS_FORWARDING:-}" == "true" ]]; then
  export KC_PROXY_HEADERS="${KC_PROXY_HEADERS:-xforwarded}"
fi

# Совместимость: KEYCLOAK_HOSTNAME из README
if [[ -n "${KEYCLOAK_HOSTNAME:-}" ]]; then
  export KC_HOSTNAME="${KC_HOSTNAME:-$KEYCLOAK_HOSTNAME}"
fi

# Часто нужно за reverse proxy (при проблемах с редиректами — оставь true)
export KC_HOSTNAME_STRICT="${KC_HOSTNAME_STRICT:-false}"

# DATABASE_URL от dokku postgres:link → JDBC и KC_DB_*
# Ограничение: пароль не должен содержать неэкранированный @ ; иначе задай KC_DB_* через dokku config:set
if [[ -n "${DATABASE_URL:-}" ]]; then
  if [[ "$DATABASE_URL" =~ ^postgres(ql)?://([^:]+):([^@]+)@([^/:]+):([0-9]+)/([^/?#]+) ]]; then
    export KC_DB="${KC_DB:-postgres}"
    export KC_DB_USERNAME="${KC_DB_USERNAME:-${BASH_REMATCH[2]}}"
    export KC_DB_PASSWORD="${KC_DB_PASSWORD:-${BASH_REMATCH[3]}}"
    export KC_DB_URL="${KC_DB_URL:-jdbc:postgresql://${BASH_REMATCH[4]}:${BASH_REMATCH[5]}/${BASH_REMATCH[6]}}"
  else
    echo "ERROR: не удалось разобрать DATABASE_URL, задай KC_DB_URL / KC_DB_USERNAME / KC_DB_PASSWORD вручную" >&2
    exit 1
  fi
fi

exec /opt/keycloak/bin/kc.sh start "$@"
