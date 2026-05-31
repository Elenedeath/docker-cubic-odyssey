#!/bin/bash
set -euo pipefail

loc_dir="/home/cubic/server_files/save_server"
backup_folder="/home/cubic/backups"

if [[ -z "${BACKUP_RETENTION:-}" ]]; then
    BACKUP_RETENTION=10
elif [[ "${BACKUP_RETENTION}" =~ ^[0-9]+$ ]] && [[ "${BACKUP_RETENTION}" -gt 0 ]]; then
    echo "Backup retention value: ${BACKUP_RETENTION} is valid."
else
    echo "[WARNING] '${BACKUP_RETENTION}' is not a valid value. Using default: 10"
    BACKUP_RETENTION=10
fi

mkdir -p "${backup_folder}"

if [[ ! -d "${loc_dir}" ]]; then
    echo "[ERROR] Save directory not found: ${loc_dir}"
    exit 1
fi

date_now="$(date '+%Y-%m-%d_%H-%M-%S')"
echo "Creating new archive filename: ${date_now}"
archive_file="${backup_folder}/cubic_odyssey_backup-${date_now}.tar.gz"

declare -a items_to_backup=()
[[ -d "${loc_dir}/save" ]] && items_to_backup+=("save")
[[ -f "${loc_dir}/continue_game.json" ]] && items_to_backup+=("continue_game.json")

if [[ ${#items_to_backup[@]} -eq 0 ]]; then
    echo "[WARNING] Nothing to back up in ${loc_dir}"
    exit 0
fi

echo "Backing up current save files to ${archive_file}"
tar -czvf "${archive_file}" -C "${loc_dir}" "${items_to_backup[@]}"

mapfile -t backups < <(
    find "${backup_folder}" -maxdepth 1 -type f -name 'cubic_odyssey_backup-*.tar.gz' -printf '%T@ %p\n' \
    | sort -n \
    | cut -d' ' -f2-
)

total_backups=${#backups[@]}
if [[ "${total_backups}" -gt "${BACKUP_RETENTION}" ]]; then
    delete_count=$((total_backups - BACKUP_RETENTION))
    echo "Found ${total_backups} backups. Deleting oldest ${delete_count}..."

    for ((i=0; i<delete_count; i++)); do
        echo "Deleting ${backups[i]}"
        rm -f -- "${backups[i]}"
    done
else
    echo "Found ${total_backups} backups. No deletion needed."
fi

echo "Current backups:"
ls -lh "${backup_folder}"