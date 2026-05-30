#!/bin/bash
set -u

loc_dir="/home/cubic/server_files/save_server"
backup_folder="/home/cubic/server_files/backup"

if [ -z "${BACKUP_RETENTION:-}" ]; then
    BACKUP_RETENTION=10
elif [[ "$BACKUP_RETENTION" =~ ^[0-9]+$ ]] && [ "$BACKUP_RETENTION" -gt 0 ]; then
    echo "Backup retention value: $BACKUP_RETENTION is valid!"
else
    echo "[WARNING] '$BACKUP_RETENTION' is not a valid value! Setting to default!"
    BACKUP_RETENTION=10
fi

echo "Checking if backup folder exists:"
if [ -d "$backup_folder" ]; then
    echo "$backup_folder exists."
else
    echo "$backup_folder doesn't exist, creating folder!"
    mkdir -p "$backup_folder"
fi

date_now=$(date '+%Y-%m-%d_%H-%M-%S')
echo "Creating new archive filename: $date_now"
archive_file="cubic_odyssey_backup-$date_now.tar.gz"

echo "Backing up current save files to $backup_folder/$archive_file"
date
echo " "

tar -czvf "$backup_folder/$archive_file" -C "$loc_dir" save continue_game.json

echo " "
echo "Backup finished"
echo " "
date

echo " "
echo "Keeping only the last $BACKUP_RETENTION backups"
echo " "

mapfile -t backups < <(find "$backup_folder" -type f -name 'cubic_odyssey_backup-*.tar.gz' -printf '%T@ %p\n' | sort -n | cut -d' ' -f2-)

total_backups=${#backups[@]}
if [ "$total_backups" -gt "$BACKUP_RETENTION" ]; then
    delete_count=$((total_backups - BACKUP_RETENTION))
    echo "Found $total_backups backups. Deleting the oldest $delete_count..."

    for ((i=0; i<delete_count; i++)); do
        echo "Deleting ${backups[i]}"
        rm -f "${backups[i]}"
    done
else
    echo "Found $total_backups backups. No need to delete any (retention is $BACKUP_RETENTION)."
fi

echo " "
echo "Current backups:"
ls -lh "$backup_folder"