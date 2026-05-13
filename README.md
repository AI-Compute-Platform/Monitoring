# platform-monitoring

Monitoring and observability stack for the GPU cloud platform POC.

This repository provides:

- NVIDIA GPU metrics
- Docker/container monitoring
- Prometheus metrics collection
- Grafana dashboards
- Future alerting support

Current target environment:

- Ubuntu 24.04 LTS
- Docker Engine
- NVIDIA Container Toolkit
- RTX A6000 / A100 / H100 servers

---

# Architecture

```text
+-------------------+
| GPU Server        |
|-------------------|
| Docker Engine     |
| NVIDIA Runtime    |
+---------+---------+
          |
          v
+-------------------+
| DCGM Exporter     |
| GPU Metrics       |
+---------+---------+
          |
          v
+-------------------+
| Prometheus        |
| Metrics Storage   |
+---------+---------+
          |
          v
+-------------------+
| Grafana           |
| Dashboards        |
+-------------------+
```

---

# Components

## DCGM Exporter

Collects NVIDIA GPU metrics.

Metrics include:

- GPU utilization
- GPU memory usage
- temperature
- power draw
- PCIe metrics
- ECC status

---

## Prometheus

Scrapes and stores metrics.

Accessible at:

```text
http://SERVER_IP:9090
```

---

## Grafana

Visualization and dashboards.

Accessible at:

```text
http://SERVER_IP:3000
```

Default credentials:

```text
admin / admin
```

Change the password immediately after first login.

---

# Repository Structure

```text
platform-monitoring/
├── docker-compose.yml
├── prometheus.yml
├── grafana/
│   ├── dashboards/
│   └── datasources/
├── prometheus/
├── dcgm/
└── README.md
```

---

# Prerequisites

Before starting:

- Docker Engine installed
- NVIDIA drivers installed
- NVIDIA Container Toolkit installed
- GPU containers working

Verify:

```bash
nvidia-smi
```

and:

```bash
docker run --rm --gpus all nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi
```

---

# Quick Start

## 1. Clone Repository

```bash
git clone git@github.com:AI-Compute-Platform/Monitoring.git
cd Monitoring
```

---

## 2. Start Monitoring Stack

```bash
docker compose up -d
```

---

## 3. Verify Containers

```bash
docker ps
```

Expected containers:

```text
prometheus
grafana
dcgm-exporter
```

---

## 4. Verify GPU Metrics

```bash
curl localhost:9400/metrics | head
```

Expected output contains:

```text
DCGM_FI_DEV_GPU_UTIL
```

---

# SSH Port Forwarding

If the GPU server is remote:

```bash
ssh -p 20073 \
  -L 3000:localhost:3000 \
  -L 9090:localhost:9090 \
  root@SERVER_IP
```

Then access locally:

```text
http://localhost:3000
http://localhost:9090
```

---

# Example docker-compose.yml

```yaml
services:
  dcgm-exporter:
    image: nvcr.io/nvidia/k8s/dcgm-exporter:latest
    container_name: dcgm-exporter
    restart: unless-stopped
    runtime: nvidia
    gpus: all
    cap_add:
      - SYS_ADMIN
    ports:
      - "9400:9400"

  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: unless-stopped
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus-data:/prometheus

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: unless-stopped
    ports:
      - "3000:3000"
    volumes:
      - grafana-data:/var/lib/grafana

volumes:
  prometheus-data:
  grafana-data:
```

---

# Example prometheus.yml

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: dcgm-exporter
    static_configs:
      - targets: ["dcgm-exporter:9400"]
```

---

# Recommended Next Steps

## Phase 1

Monitoring POC.

Goals:

- validate GPU metrics
- validate Prometheus scraping
- validate Grafana dashboards

---

## Phase 2

Add container monitoring.

Add:

- cAdvisor
- node_exporter
- Loki

Track:

- CPU
- RAM
- container lifecycle
- disk IO
- network IO

---

## Phase 3

Integrate with control plane.

Expose:

- GPU allocation status
- active jobs
- scheduler metrics
- per-user utilization

---

# Future Improvements

Planned future features:

- Alertmanager
- Slack/Discord alerts
- multi-node monitoring
- GPU quota tracking
- Prometheus federation
- long-term metrics retention
- S3 object storage backups
- Kubernetes support

---

# Security Notes

Current POC setup is intended for internal development only.

Before production:

- secure Grafana authentication
- restrict Prometheus access
- add TLS
- isolate monitoring network
- add firewall rules
- disable public Docker socket exposure

---

# License

Internal project.
