*This project has been created as part of the 42 curriculum by mobouifr.*

# Inception

[![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)](https://docs.docker.com/get-started/)
[![Docker Compose](https://img.shields.io/badge/Docker%20Compose-2496ED?logo=docker&logoColor=white)](https://docs.docker.com/compose/compose-file/)
[![NGINX](https://img.shields.io/badge/NGINX-009639?logo=nginx&logoColor=white)](https://nginx.org/en/docs/)
[![WordPress](https://img.shields.io/badge/WordPress-21759B?logo=wordpress&logoColor=white)](https://wordpress.org/documentation/)
[![MariaDB](https://img.shields.io/badge/MariaDB-003545?logo=mariadb&logoColor=white)](https://mariadb.com/kb/en/documentation/)
[![Debian](https://img.shields.io/badge/Debian-A81D33?logo=debian&logoColor=white)](https://www.debian.org/)
[![Make](https://img.shields.io/badge/Make-6D00CC?logo=gnu&logoColor=white)](https://www.gnu.org/software/make/)
[![Shell/Bash](https://img.shields.io/badge/Shell%2FBash-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Last Commit](https://img.shields.io/github/last-commit/mobouifr/inception)](https://github.com/mobouifr/inception)

This project builds a small but production-like web infrastructure with Docker and Docker Compose. It runs inside a Linux virtual machine and separates the stack into three dedicated services: NGINX for HTTPS termination and reverse proxying, WordPress with PHP-FPM for the application layer, and MariaDB for the database.

## Table of Contents
- [Description](#description)
- [Instructions](#instructions)
- [Design Choices](#design-choices)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
- [Resources](#resources)
- [More Documentation](#more-documentation)

---

## Description
Inception is a 42 system administration project focused on building a clean, reproducible infrastructure with containers. The goal is to package each service from scratch, connect them through a private Docker network, keep persistent data on the host, and manage secrets without hardcoding them into images or Compose files.

### At a Glance
- **Goal:** run a complete web stack that feels close to production while staying small and easy to rebuild.
- **Front door:** NGINX is the only public entrypoint and listens on port `443` only.
- **Application:** WordPress runs with PHP-FPM and no NGINX inside the container.
- **Database:** MariaDB stores the WordPress data.
- **Secrets:** passwords are provided through Docker secrets mounted from host files.
- **Persistence:** site files and database data live under `/home/mobouifr/data/`.

---

## Instructions
### Prerequisites
- Docker Engine
- Docker Compose v2
- GNU Make
- A Linux virtual machine

### Setup
1. Clone the repository.

2. Copy the example secrets folder into a git-ignored `secrets/` directory.

```sh
cp -r secrets.example/ secrets/
```

3. Open every file inside `secrets/` and replace the placeholder values with your own.

4. Add the domain to `/etc/hosts` so it resolves locally.

```sh
echo "127.0.0.1 mobouifr.42.fr" | sudo tee -a /etc/hosts
```

5. Build and start the stack.

```sh
make
```

6. Open the site in your browser.

```text
https://mobouifr.42.fr
https://mobouifr.42.fr/wp-admin
```

### Makefile Commands
```sh
make          # first build and run
make down     # stop all containers
make restart  # restart the stack
make rebuild  # full teardown + rebuild
```

> Important:
> - The `secrets/` directory is git-ignored and must be created from `secrets.example/`.
> - The WordPress admin username must not contain `admin` or `administrator`.
> - NGINX is the only entrypoint, it publishes port `443` only, and TLS is restricted to TLSv1.2 and TLSv1.3.

---

## Design Choices
### Virtual Machines vs Docker
- **Virtual Machines** virtualize hardware and run a full guest OS. They are heavier, slower to boot, and usually best when you need strong OS-level isolation.
- **Docker** shares the host kernel and packages only the application plus its dependencies. It is lighter, starts faster, and is better suited to composing several services.
- **This project** uses Docker because the subject is about service composition, isolation, and repeatable rebuilds, not about emulating whole operating systems.

### Secrets vs Environment Variables
- **Environment variables** are convenient for non-sensitive settings, but they are easier to expose through process inspection, logs, shell history, or crash output.
- **Docker secrets** keep sensitive values in files managed at runtime and mount them into the container under `/run/secrets/`.
- **This project** stores MariaDB and WordPress passwords in `secrets/` on the host and injects them as Compose secrets.

### Docker Network vs Host Network
- **Docker bridge networks** isolate services from the host network and provide internal DNS, so containers can reach each other by service name.
- **Host networking** removes that isolation and is not used here because the subject forbids it and it exposes too much of the host network namespace.
- **This project** uses the custom bridge network `my-net`, which keeps the stack private while still letting NGINX, WordPress, and MariaDB talk to each other.

### Docker Volumes vs Bind Mounts
- **Docker volumes** are managed by Docker and abstract the host filesystem layout.
- **Bind mounts** map a specific host path into a container and make the stored data easy to inspect, but they depend on the chosen host path.
- **This project** uses named volumes with bind mount driver options so the data persists under `/home/mobouifr/data/www` and `/home/mobouifr/data/mariadb`.

---

## Project Structure
```text
.
├── Makefile                  # Build, run, stop, rebuild commands
├── secrets/                  # Git-ignored - contains real secret files
├── secrets.example/          # Committed - placeholder files to copy and fill
│   ├── credentials.txt
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
└── srcs/
    ├── docker-compose.yml    # Defines all services, volumes, network, secrets
    ├── .env                  # Local non-sensitive config (git-ignored)
    └── requirements/
        ├── nginx/            # NGINX Dockerfile + SSL config
        ├── wordpress/        # WordPress + PHP-FPM Dockerfile + setup scripts
        └── mariadb/          # MariaDB Dockerfile + init scripts
```

---

## Configuration
If you keep non-sensitive Compose values in a local `srcs/.env` file, these are the main variables:

| Variable | Example Value | Description |
| --- | --- | --- |
| `DOMAIN_NAME` | `mobouifr.42.fr` | Domain pointing to the WordPress site |
| `MYSQL_DATABASE` | `wordpress` | WordPress database name |
| `MYSQL_USER` | `wpuser` | MariaDB user for WordPress |
| `WP_TITLE` | `My Inception Blog` | WordPress site title |

---

## Resources
- Docker overview: https://docs.docker.com/get-started/
- Docker Compose file reference: https://docs.docker.com/compose/compose-file/
- Docker secrets (Compose): https://docs.docker.com/compose/use-secrets/
- NGINX documentation: https://nginx.org/en/docs/
- WordPress documentation: https://wordpress.org/documentation/
- MariaDB documentation: https://mariadb.com/kb/en/documentation/
- AI usage: AI was used to improve documentation structure, clarity, and the explanation of design trade-offs. The implementation itself remains the source of truth in `srcs/` and `secrets/`.

---

## More Documentation
- User guide: [USER_DOC.md](USER_DOC.md)
- Developer guide: [DEV_DOC.md](DEV_DOC.md)
