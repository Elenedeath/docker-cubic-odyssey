#!/bin/bash
set -euo pipefail

APP_FILE="${server_files}/config/server_config.txt"
TEMPLATE_FILE="${HOME}/scripts/server_config.txt"

mkdir -p "$(dirname "$APP_FILE")"

if [ ! -f "$APP_FILE" ]; then
    cp "$TEMPLATE_FILE" "$APP_FILE"
fi

variables=(
    "GALAXY_SEED" "galaxySeed"
    "SERVER_PWD" "serverPassword"
    "MAX_PLAYERS" "maxPlayers"
    "SERVER_NAME" "serverName"
    "PRIVATE_SERVER" "privateServer"
    "STARTING_PORT" "startingPort"
    "ENDING_PORT" "endingPort"
    "GAME_MODE" "gameMode"
    "ENABLE_CRASH_DUMPS" "enableCrashDumps"
    "ALLOW_RELAYING" "allowRelaying"
    "ENABLE_LOGGING" "enableLogging"
)

for ((i=0; i<${#variables[@]}; i+=2)); do
    var_name="${variables[$i]}"
    config_name="${variables[$i+1]}"
    value="${!var_name:-}"

    if [ -n "$value" ]; then
        echo "${config_name} set to: ${value}"
        if grep -q "^${config_name} " "$APP_FILE"; then
            sed -i "s|^${config_name} .*|${config_name} ${value}|" "$APP_FILE"
        else
            printf '\n%s %s\n' "$config_name" "$value" >> "$APP_FILE"
        fi
    fi
done