#!/bin/bash
echo "This will perform a hard reset of the Elastic Stack setup."
echo "All data will be lost and you will need to re-enroll any agents."
echo "------------------------------------------------------------------"

read -p "Are you sure you want to continue? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo "Operation cancelled."
    exit 1
fi

# Wipe all and re-deploy
docker compose down -v --remove-orphans
docker volume prune -f
bash restart.sh
