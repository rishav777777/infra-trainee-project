# IT Infrastructure & DevOps Trainee Assignment

This repository contains the configuration, automation, and orchestration files for a highly available, monitored web application stack.

## Architecture Decisions
* **Nginx Reverse Proxy:** Selected for its low memory footprint and high concurrency when routing traffic to the backend.
* **Data Persistence:** A named Docker volume (`pgdata`) is attached to PostgreSQL to guarantee data survives container restarts and upgrades.
* **Automated Log Rotation:** The database backup script includes a 7-day retention policy to prevent the Ubuntu host from running out of disk space over time.

## Architecture Overview
* **OS:** Ubuntu Server (Hardened, Key-based SSH on Port 2222, UFW enabled)
* **Reverse Proxy:** Nginx (Host Port 80)
* **Backend:** Python/Flask Application (Internal Port 5000)
* **Database:** PostgreSQL 16 (Persistent Volume pgdata)
* **Monitoring:** Prometheus & Node Exporter
* **Automation:** Bash scripts for health checks and logical database backups

---

## 1. Setup & Deployment Instructions

### Prerequisites
* Docker Engine and Docker Compose installed.
* UFW configured to allow inbound traffic strictly on ports 2222, 80, and 443.

### Deployment
1. Clone this repository to your local machine:
   `git clone <your-repo-url>`
   `cd infra-trainee-project`
2. Provision the multi-container stack:
   `docker compose up -d --build`

---

## 2. Verification Commands

Run the following commands to verify system configurations:
* **Firewall Status:** `sudo ufw status verbose`
* **Container Status:** `docker ps`
* **Reverse Proxy Routing:** `curl -i http://localhost/`

---

## 3. Automation & Disaster Recovery

### Health Check Script (infra_health_check.sh)
Monitors CPU, RAM, root disk usage (threshold: 85%), and container states.
* **Location:** `/opt/scripts/infra_health_check.sh`
* **Log Destination:** `/var/log/infra_health.log`
* **Cron Schedule:** `*/15 * * * *` (Runs every 15 minutes)

### Database Backup Script (db_backup.sh)
Performs a logical dump of PostgreSQL and compresses it.
* **Location:** `/opt/scripts/db_backup.sh`
* **Backup Destination:** `/var/backups/db/`

### Database Restoration Procedure
To recover the database from a backup archive in the event of data loss, execute the following command:
`gunzip -c /var/backups/db/db_backup_YYYYMMDD.sql.gz | docker exec -i postgres_db psql -U trainee -d traineedb`

---

## 4. Teardown Instructions

To gracefully stop and remove the containers, networks, and images:
`docker compose down`

---

## 5. Required Screenshots

The required evaluation screenshots are located in the screenshots/ directory of this repository:
1. ufw_status_verbose.png - UFW firewall status and rules.
2. docker_ps.png - Running multi-service containers.
3. browser_reverse_proxy.png - Browser output accessing the reverse-proxied application.
4. infra_health_check_output.png - Successful execution and log output of the health check script.

## Assignment Task Mapping
* **Task 1 (System Provisioning):** Ubuntu host hardened with UFW (Ports 80, 443, 2222) and key-based SSH.
* **Task 2 (Containerization):** Multi-service stack (Nginx, Flask, PostgreSQL) defined in `docker-compose.yml`.
* **Task 3 (Automation):** Bash script `/opt/scripts/infra_health_check.sh` monitors metrics via a 15-minute cron job.
* **Task 4 (Monitoring & DR):** `db_backup.sh` handles database dumps. Metrics exposed via Node Exporter and scraped by Prometheus.
* **Task 5 (Git & Docs):** Developed using feature branches and merged into main.
