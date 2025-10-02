# Load .env if it exists
ifneq (,$(wildcard .env))
  include .env
  export
endif

build:
	docker compose build
pull:
	docker pull canopynetwork/canopy
up:
	docker compose down
	docker compose up -d
down:
	docker compose down
restart_with_latest:
	make pull
	make up
logs:
	docker compose logs -f node1 node2
frontend-logs:
	docker compose logs -f canopy-frontend
all-logs:
	docker compose logs -f
reset:
	docker compose stop node1 node2

	rm -rf monitoring/loki/data/*
	rm -rf monitoring/grafana/data/*

	rm -rf ../canopy_data/node1/canopy/
	rm -rf ../canopy_data/node1/logs/

	rm -rf ../canopy_data/node2/canopy/
	rm -rf ../canopy_data/node2/logs/


	mkdir -p ../canopy_data/node1/canopy
	mkdir -p ../canopy_data/node1/logs

	mkdir -p ../canopy_data/node2/canopy
	mkdir -p ../canopy_data/node2/logs
start_with_snapshot:
	@echo "Checking for existing canopy data directories..."
	@if [ -d "../canopy_data/node1/canopy" ]; then \
		echo "Found existing canopy data in node1. Do you want to delete it? (y/N): "; \
		read confirm; \
		if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
			echo "Stopping node1 for downloading latest snapshot data chainID: 1"; \
			docker compose stop node1; \
			rm -rf ../canopy_data/node1/canopy/; \
			echo "Deleted node1 canopy data."; \
		else \
			echo "Keeping existing node1 data."; \
		fi; \
	fi
	@if [ -d "../canopy_data/node2/canopy" ]; then \
		echo "Found existing canopy data in node2. Do you want to delete it? (y/N): "; \
		read confirm; \
		if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
			echo "Stopping node2 for downloading latest snapshot data chainID: 2"; \
			docker compose stop node2; \
			rm -rf ../canopy_data/node2/canopy/; \
			echo "Deleted node2 canopy data."; \
		else \
			echo "Keeping existing node2 data."; \
		fi; \
	fi

	echo "Downloading snapshot for mainnet chainID: 1"	
	wget -O snapshot.tar.gz $(SNAPSHOT_1_URL)

	echo "Deleting/Recreating node1 datadir"
	rm -rf ../canopy_data/node1/canopy/
	mkdir  ../canopy_data/node1/canopy/

	echo "Uncompressing snapshot for mainnet chainID: 1"
	tar -xvzf ./snapshot.tar.gz -C ../canopy_data/node1/canopy/

	echo "Deleting snapshot for chain ID 2"
	rm ./snapshot.tar.gz

	echo "Restarting node1"

	echo "Downloading snapshot for mainnet chainID: 2"
	wget -O snapshot.tar.gz $(SNAPSHOT_2_URL)

	echo "Deleting/Recreating node2 datadir"
	rm -rf ../canopy_data/node2/canopy/
	mkdir ../canopy_data/node2/canopy/

	echo "Uncompressing snapshot for mainnet chainID: 2"
	tar -xvzf ./snapshot.tar.gz -C ../canopy_data/node2/canopy/

	echo "Deleting snapshot for chain ID 2"
	rm ./snapshot.tar.gz

	echo "Restarting node2 and whole stack"
	docker compose up -d

# Frontend specific commands
frontend-build:
	cd frontend && make build
frontend-dev:
	cd frontend && make dev
frontend-install:
	cd frontend && make install
frontend-docker-build:
	cd frontend && make docker-build
frontend-docker-run:
	cd frontend && make docker-run
frontend-compose-up:
	docker compose up canopy-frontend -d
frontend-compose-down:
	docker compose stop canopy-frontend
frontend-restart:
	docker compose restart canopy-frontend
frontend-k8s-local:
	cd frontend && make k8s-local
frontend-k8s-staging:
	cd frontend && make k8s-staging
frontend-tilt-up:
	cd frontend && make tilt-up
frontend-tilt-down:
	cd frontend && make tilt-down

# Submodule management
frontend-update:
	@echo "Updating frontend submodule to latest version..."
	git submodule update --remote --merge frontend
	@echo "Frontend submodule updated successfully!"
	@echo "Current commit: $$(cd frontend && git rev-parse --short HEAD)"
	@echo "Branch: $$(cd frontend && git branch --show-current)"

submodule-init:
	@echo "Initializing and updating all submodules..."
	git submodule update --init --recursive
	@echo "All submodules initialized!"

frontend-reset:
	@echo "Resetting frontend submodule to remote HEAD..."
	@read -p "This will discard any local changes in the frontend submodule. Continue? (y/N): " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		cd frontend && git fetch origin && git reset --hard origin/main; \
		echo "Frontend submodule reset to remote HEAD"; \
	else \
		echo "Reset cancelled"; \
	fi

frontend-status:
	@echo "Frontend submodule status:"
	@git submodule status frontend
	@echo ""
	@echo "Frontend submodule branch and commit:"
	@cd frontend && echo "Branch: $$(git branch --show-current)" && echo "Commit: $$(git log -1 --oneline)"

# Stack management with frontend
up-with-frontend:
	docker compose up -d
down-all:
	docker compose down
restart-all:
	docker compose restart
build-all:
	docker compose build
