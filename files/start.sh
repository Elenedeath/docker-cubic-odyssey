#!/bin/bash
# Location of server data and save data for docker

server_files="/home/cubic/server_files"

echo " "
echo "Server files location is set to : $server_files"
echo " "

mkdir -p /home/cubic/.steam 2>/dev/null
chmod -R 777 /home/cubic/.steam 2>/dev/null

echo " "
echo "Updating Cubic Odyssey Dedicated Server files..."
echo " "

if [ -n "$STEAM_LOGIN" ]; then
    LOGIN_ARGS="+login $STEAM_LOGIN $STEAM_PWD"
else
    LOGIN_ARGS="+login anonymous"
fi

if [ -n "$BETANAME" ]; then
    if [ -n "$BETAPASSWORD" ]; then
        echo "Using beta $BETANAME with a password"
        steamcmd +@sSteamCmdForcePlatformType windows \
            +force_install_dir "$server_files" \
            $LOGIN_ARGS \
            +app_update "3858450 -beta $BETANAME -betapassword $BETAPASSWORD" validate \
            +quit
    else
        echo "Using beta $BETANAME without a password"
        steamcmd +@sSteamCmdForcePlatformType windows \
            +force_install_dir "$server_files" \
            $LOGIN_ARGS \
            +app_update "3858450 -beta $BETANAME" validate \
            +quit
    fi
else
    echo "No beta branch used."
    steamcmd +@sSteamCmdForcePlatformType windows \
        +force_install_dir "$server_files" \
        $LOGIN_ARGS \
        +app_update 3858450 validate \
        +quit
fi

if [ -f "$server_files/steam_appid.txt" ]; then
    echo "steam_appid: $(cat "$server_files/steam_appid.txt")"
else
    echo "steam_appid.txt not found yet"
fi

echo "Running setup script for the app.cfg file"
source /home/cubic/scripts/env2cfg.sh

echo " "
if [ -n "$NO_CRON" ]; then
    echo "No Cron image used!"
else
    sudo -u root cron

    if [ "$BACKUPS" = "false" ]; then
        echo "[IMPORTANT] Backups are disabled!"
        sudo -u root sed -i "/backup.sh/c # 0 * * * * /bin/bash /home/cubic/scripts/backup.sh 2>&1" /var/spool/cron/crontabs/root
    elif [ -n "$BACKUP_INTERVAL" ]; then
        echo "Changing backup interval to $BACKUP_INTERVAL"
        sudo -u root sed -i "/backup.sh/c $BACKUP_INTERVAL /bin/bash /home/cubic/scripts/backup.sh 2>&1" /var/spool/cron/crontabs/root
    fi
fi

echo " "
echo "Cleaning possible X11 leftovers"
echo " "
rm -f /tmp/.X*-lock > /dev/null 2>&1
rm -rf /tmp/.X11-unix > /dev/null 2>&1

cd "$server_files" || exit 1
echo "Starting Cubic Odyssey Dedicated Server"
echo " "
echo "Clean wine Folder"
echo " "
rm -rf /home/cubic/.wine
export WINEPREFIX=/home/cubic/.wine
export WINEARCH=win64
wineboot -i
wineserver -w
echo "Launching wine Cubic Odyssey"
echo " "
source /home/cubic/scripts/wrapper.sh
