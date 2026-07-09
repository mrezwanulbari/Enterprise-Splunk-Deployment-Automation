#!/usr/bin/env bash
# Pushes a validated app bundle to the deployment server's deployment-apps
# directory and triggers a reload — with a config-check step before deploy
# so a syntax error doesn't get pushed to hundreds of forwarders at once.

set -euo pipefail

APP_NAME="$1"
SOURCE_DIR="$2"
DEPLOY_APPS_DIR="${SPLUNK_HOME:-/opt/splunk}/etc/deployment-apps"

if [[ -z "${APP_NAME}" || -z "${SOURCE_DIR}" ]]; then
  echo "Usage: $0 <app_name> <source_dir>"
  exit 1
fi

echo "Validating app configuration syntax..."
"${SPLUNK_HOME:-/opt/splunk}/bin/splunk" btool check --debug --dir "${SOURCE_DIR}"

echo "Deploying ${APP_NAME} to deployment server..."
rsync -av --delete "${SOURCE_DIR}/" "${DEPLOY_APPS_DIR}/${APP_NAME}/"

echo "Reloading deployment server..."
"${SPLUNK_HOME:-/opt/splunk}/bin/splunk" reload deploy-server

echo "Done. Forwarders will phone home on their next check-in interval."
