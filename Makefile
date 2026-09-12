.PHONY: up down check backup

up:
	docker compose up -d

down:
	docker compose down -v

check:
	sudo /opt/scripts/infra_health_check.sh

backup:
	sudo ./scripts/db_backup.sh
