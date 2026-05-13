---
name: monitor
description: View GPU monitoring dashboards - SSH tunnel setup and Grafana access for the A6000 server
---

# Monitor - A6000 GPU Monitoring

Connect to the remote GPU server's Grafana dashboards via SSH tunnel.

## Prerequisites

Monitoring stack (dcgm-exporter + node-exporter + Prometheus + Grafana) must be deployed on the server.
See `/deployment` for setup.

## Steps

### 1. Open SSH Tunnel

```bash
ssh -i <SSH_KEY_PATH> -p 20073 \
  -L 3000:localhost:3000 \
  -L 9090:localhost:9090 \
  -N root@135.84.176.142
```

Example:
```bash
ssh -i ~/.ssh/tony_a300 -p 20073 \
  -L 3000:localhost:3000 \
  -L 9090:localhost:9090 \
  -N root@135.84.176.142
```

### 2. Open in Browser

| Service | URL | Purpose |
|---------|-----|---------|
| Grafana | http://localhost:3000 | Dashboard visualization |
| Prometheus | http://localhost:9090 | Metrics query |

Default Grafana credentials: `admin / admin`

### 3. Available Dashboards

- **Server Stats** — CPU, RAM, GPU summary, disk usage, network traffic
- **GPU Status** — 8x A6000 timeseries (utilization, memory, temperature, power)

### 4. Troubleshooting

If dashboards show no data, SSH into the server and check containers:
```bash
ssh -i <SSH_KEY_PATH> -p 20073 root@135.84.176.142 "docker compose -f /opt/monitoring/docker-compose.yml ps"
```

### Notes

- No external ports are exposed; all access is via SSH tunnel
- Tunnel must stay open to maintain access
- `-N` flag means no remote shell, port forwarding only
