#!/bin/bash
set -euo pipefail

REMOTE_USER="root"
REMOTE_HOST="135.84.176.142"
REMOTE_PORT="20073"
REMOTE_DIR="/opt/monitoring"

usage() {
    echo "Usage: $0 -k <ssh_key_path>"
    echo ""
    echo "Options:"
    echo "  -k    Path to SSH private key (required)"
    echo ""
    echo "Example:"
    echo "  $0 -k ~/.ssh/tony_a300"
    exit 1
}

while getopts "k:" opt; do
    case $opt in
        k) SSH_KEY="$OPTARG" ;;
        *) usage ;;
    esac
done

if [ -z "${SSH_KEY:-}" ]; then
    usage
fi

if [ ! -f "$SSH_KEY" ]; then
    echo "Error: SSH key not found: $SSH_KEY"
    exit 1
fi

SSH_CMD="ssh -i $SSH_KEY -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST"
SCP_CMD="scp -i $SSH_KEY -P $REMOTE_PORT"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Deploying Monitoring Stack ==="
echo "Target: $REMOTE_USER@$REMOTE_HOST:$REMOTE_PORT"
echo "Remote dir: $REMOTE_DIR"
echo ""

echo "[1/4] Creating remote directories..."
$SSH_CMD "mkdir -p $REMOTE_DIR/grafana/provisioning/datasources $REMOTE_DIR/grafana/provisioning/dashboards $REMOTE_DIR/grafana/dashboards"

echo "[2/4] Uploading files..."
$SCP_CMD "$PROJECT_DIR/docker-compose.yml" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/"
$SCP_CMD "$PROJECT_DIR/prometheus.yml" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/"
$SCP_CMD "$PROJECT_DIR/grafana/provisioning/datasources/prometheus.yml" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/grafana/provisioning/datasources/"
$SCP_CMD "$PROJECT_DIR/grafana/provisioning/dashboards/dashboards.yml" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/grafana/provisioning/dashboards/"
$SCP_CMD "$PROJECT_DIR/grafana/dashboards/server-stats.json" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/grafana/dashboards/"
$SCP_CMD "$PROJECT_DIR/grafana/dashboards/gpu-status.json" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/grafana/dashboards/"

echo "[3/4] Restarting containers..."
$SSH_CMD "cd $REMOTE_DIR && docker compose down && docker compose up -d"

echo "[4/4] Verifying containers..."
$SSH_CMD "cd $REMOTE_DIR && docker compose ps"

echo ""
echo "=== Done ==="
echo "SSH tunnel: ssh -i $SSH_KEY -p $REMOTE_PORT -L 3000:localhost:3000 -L 9090:localhost:9090 -N $REMOTE_USER@$REMOTE_HOST"
echo "Grafana:    http://localhost:3000"
