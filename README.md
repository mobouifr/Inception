*This project has been created as part of the 42 curriculum by mobouifr.*

## Description
This repository contains an implementation of the **Inception** project (42 curriculum): a small, production-like web stack fully containerized with **Docker** and orchestrated with **Docker Compose**.

**Goal**
- Run multiple services in isolated containers.
- Connect them through a private Docker network.
- Persist data using volumes/bind mounts.
- Handle secrets safely using Docker secrets.

**Services included**
- **MariaDB**: database backend for WordPress.
- **WordPress (PHP-FPM)**: application container.
- **Nginx**: HTTPS entrypoint (port `443`) and reverse proxy to WordPress.

**Main design choices (as implemented)**
- Docker Compose defines the stack in [srcs/docker-compose.yml](srcs/docker-compose.yml).
- A dedicated bridge network (`my-net`) is used so containers can reach each other by service name.
- Passwords are provided via Docker **secrets** (file-based) from `secrets/`.
- Persistent data is stored on the host under `/home/mobouifr/data/` and mounted into containers.

### Comparisons (required)
#### Virtual Machines vs Docker
- **VMs** virtualize hardware and run full guest OS instances; they are heavier (CPU/RAM), slower to boot, and typically managed per-VM.
- **Docker containers** share the host kernel and package only the app + dependencies; they are lightweight, start fast, and are well-suited for composing multiple services.

#### Secrets vs Environment Variables
- **Environment variables** are convenient for non-sensitive config but can leak through process listings, logs, shell history, crash dumps, or tooling.
- **Docker secrets** keep sensitive values in files managed by the runtime and reduce accidental exposure; in this project, passwords are stored as files in `secrets/` and injected as Compose secrets.

#### Docker Network vs Host Network
- A **Docker bridge network** isolates services from the host, provides internal DNS (service name resolution), and reduces port exposure.
- **Host networking** removes network isolation (container shares host network namespace); it can be faster/simpler in rare cases but reduces separation and increases the blast radius of misconfiguration.

#### Docker Volumes vs Bind Mounts
- **Docker volumes** are managed by Docker (lifecycle and location abstracted), portable across hosts, and often preferred for production data.
- **Bind mounts** map an explicit host path into a container; they are simple and transparent but depend on host filesystem layout.

In this repository, Compose volumes are configured as **bind mounts** (via `driver_opts: { type: none, o: bind }`) to persist data in:
- `/home/mobouifr/data/www` (WordPress files)
- `/home/mobouifr/data/mariadb` (MariaDB data)

## Getting Started

### Prerequisites
- Docker Engine
- Docker Compose v2
- GNU Make
- Add this line to your /etc/hosts file:
  127.0.0.1 mobouifr.42.fr

### Setup
1. Clone the repository:
	git clone https://github.com/mobouifr/inception.git
	cd inception

2. Copy the example secrets and fill in your own values:
	cp -r secrets.example/ secrets/
	Open each file inside secrets/ and replace the placeholder with any value you want.
	For local testing, anything works — e.g. just type "password123".

3. Build and run the stack:
	make

4. Open your browser and go to:
	https://mobouifr.42.fr
	WordPress admin panel:
	https://mobouifr.42.fr/wp-admin

### Stop the stack
  make down

### Rebuild everything from scratch
  make rebuild

## Resources
### Classic references
- Docker overview: https://docs.docker.com/get-started/
- Docker Compose file reference: https://docs.docker.com/compose/compose-file/
- Docker secrets (Compose): https://docs.docker.com/compose/use-secrets/
- Nginx documentation: https://nginx.org/en/docs/
- WordPress documentation: https://wordpress.org/documentation/
- MariaDB documentation: https://mariadb.com/kb/en/documentation/

### How AI was used
This repository may use AI assistance for:
- Reviewing and improving documentation structure and clarity (README, user/dev docs).
- Explaining design trade-offs (VM vs Docker, secrets vs env vars, networks, volumes).

No AI-generated content is intended to replace understanding of the Docker/Compose configuration; the source of truth remains the files under `srcs/` and `secrets/`.

## More documentation
- User guide: [USER_DOC.md](USER_DOC.md)
- Developer guide: [DEV_DOC.md](DEV_DOC.md)
