#!/bin/bash
docker compose down && docker compose up -d

echo "Waiting 20 seconds for services to start fully ..."
sleep 20
docker compose ps

