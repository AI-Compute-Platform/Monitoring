---
name: deployment
description: Deploy and update services on the A6000 GPU server via SSH
---

# Deployment - A6000 Server

Deploy services to the remote GPU server.

## Server Info

| Item | Value |
|------|-------|
| Public IP | 135.84.176.142 |
| SSH Port | 20073 |
| User | root |
| Internal IP | 172.16.100.80 |
| Gateway | 172.16.100.10 (OPNsense, no admin access) |

## Monitoring Stack

### Deploy

```bash
cd AIComputePlatform/Monitoring
./deployment/deploy.sh -k <SSH_KEY_PATH>
```

Example:
```bash
./deployment/deploy.sh -k ~/.ssh/tony_a300
```

The script runs 4 steps:
1. Create remote directory `/opt/monitoring`
2. SCP upload config files + dashboard JSON
3. `docker compose down && up -d`
4. Verify container status

### Update Dashboards

Edit local `grafana/dashboards/*.json`, then re-run `deploy.sh`.

### Containers

| Container | Port | Purpose |
|-----------|------|---------|
| dcgm-exporter | 9400 | GPU metrics collection |
| node-exporter | 9100 | CPU/RAM/disk/network metrics |
| prometheus | 9090 | Time-series database |
| grafana | 3000 | Visualization dashboards |

## Remote Directory Structure

```
/opt/monitoring/
├── docker-compose.yml
├── prometheus.yml
└── grafana/
    ├── provisioning/
    │   ├── datasources/
    │   └── dashboards/
    └── dashboards/
```

## Notes

- SSH key is passed via `-k` parameter, never hardcoded
- All ports listen locally only; external access requires SSH tunnel (see `/monitor`)
- Docker data uses named volumes; `docker compose down -v` clears everything
- 7TB NVMe is not yet mounted (has LVM residue, confirm before formatting)
- Outbound bandwidth is ~10Mbps; large image pulls will be slow
