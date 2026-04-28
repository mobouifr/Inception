*This project has been created as part of the 42 curriculum by mobouifr.*

<div align="center">

# Inception

**A production-like web infrastructure built with Docker and Docker Compose.**

*Three services. One network. Zero hardcoded secrets.*

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docs.docker.com/get-started/)
[![NGINX](https://img.shields.io/badge/NGINX-009639?style=for-the-badge&logo=nginx&logoColor=white)](https://nginx.org/en/docs/)
[![WordPress](https://img.shields.io/badge/WordPress-21759B?style=for-the-badge&logo=wordpress&logoColor=white)](https://wordpress.org/documentation/)
[![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=for-the-badge&logo=mariadb&logoColor=white)](https://mariadb.com/kb/en/documentation/)
[![42](https://img.shields.io/badge/42-1337-000000?style=for-the-badge)](https://42.fr)

</div>

---

## What is this?

Inception is a 42 system administration project about building a reproducible, container-based web infrastructure from scratch — no pre-built images, no shortcuts. Each service is defined in its own `Dockerfile`, wired together with Docker Compose, and isolated on a private bridge network.

The stack is minimal but deliberately close to how real infrastructure works: NGINX handles HTTPS termination and proxying, WordPress runs with PHP-FPM behind it, and MariaDB stores the data. Secrets are mounted at runtime, not baked into images. Persistent data survives container restarts.

> The subject is about service composition, isolation, and reproducible rebuilds — not about emulating whole operating systems.

---

## Stack

| Layer | Service | Role |
|---|---|---|
| Entry point | NGINX | HTTPS termination, reverse proxy — port `443` only |
| Application | WordPress + PHP-FPM | CMS — no NGINX inside the container |
| Database | MariaDB | Stores all WordPress data |
| Secrets | Docker secrets | Passwords mounted from host files at runtime |
| Persistence | Named volumes | Data lives under `/home/mobouifr/data/` |

---

## Getting started

### Requirements

- Docker Engine
- Docker Compose v2
- GNU Make
- A Linux virtual machine

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/mobouifr/inception.git
cd inception

# 2. Create your secrets from the example
cp -r secrets.example/ secrets/
# Open every file in secrets/ and replace the placeholders

# 3. Add the domain to /etc/hosts
echo "127.0.0.1 mobouifr.42.fr" | sudo tee -a /etc/hosts

# 4. Build and start
make
```

Then open:
```
https://mobouifr.42.fr
https://mobouifr.42.fr/wp-admin
```

### Makefile rules

| Rule | Effect |
|---|---|
| `make` | First build and start the stack |
| `make down` | Stop all containers |
| `make restart` | Restart the stack |
| `make rebuild` | Full teardown and rebuild |

> `secrets/` is git-ignored and must be created from `secrets.example/` before building.
> The WordPress admin username must not contain `admin` or `administrator`.

---

## Design choices

<details>
<summary>Virtual machines vs Docker</summary>
<br/>

Virtual machines virtualize hardware and run a full guest OS — heavier, slower to boot, better when you need OS-level isolation. Docker shares the host kernel and packages only the application and its dependencies. Lighter, faster, and better suited to composing several services. This project uses Docker because the subject is about service composition and repeatable rebuilds, not OS emulation.

</details>

<details>
<summary>Secrets vs environment variables</summary>
<br/>

Environment variables are easy to expose through process inspection, logs, shell history, or crash output. Docker secrets keep sensitive values in files managed at runtime, mounted into the container under `/run/secrets/`. This project stores all passwords in `secrets/` on the host and injects them as Compose secrets — nothing sensitive ever touches an image or a Compose file directly.

</details>

<details>
<summary>Docker network vs host network</summary>
<br/>

Host networking removes container isolation and exposes too much of the host network namespace. Docker bridge networks isolate services from the host and provide internal DNS — containers reach each other by service name. This project uses the custom bridge network `my-net`, which keeps the stack private while letting NGINX, WordPress, and MariaDB communicate internally.

</details>

<details>
<summary>Named volumes vs bind mounts</summary>
<br/>

Docker volumes are managed by Docker and abstract the host filesystem. Bind mounts map a specific host path into a container — the stored data is easy to inspect but depends on the chosen path. This project uses named volumes with bind mount driver options, so data persists under `/home/mobouifr/data/www` and `/home/mobouifr/data/mariadb` and remains accessible on the host.

</details>

---

## Configuration

Non-sensitive values go in a local `srcs/.env` file (git-ignored):

| Variable | Example | Description |
|---|---|---|
| `DOMAIN_NAME` | `mobouifr.42.fr` | Domain pointing to the WordPress site |
| `MYSQL_DATABASE` | `wordpress` | WordPress database name |
| `MYSQL_USER` | `wpuser` | MariaDB user for WordPress |
| `WP_TITLE` | `My Inception Blog` | WordPress site title |

Sensitive values go in `secrets/` — one file per secret, never committed:

```
secrets/
├── credentials.txt
├── db_password.txt
├── db_root_password.txt
├── wp_admin_password.txt
└── wp_user_password.txt
```

---

## Project structure

```
inception/
│
├── Makefile
├── secrets.example/          ← committed placeholder files — copy and fill
│   ├── credentials.txt
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
│
└── srcs/
    ├── docker-compose.yml    ← services, volumes, network, secrets
    ├── .env                  ← local non-sensitive config (git-ignored)
    └── requirements/
        ├── nginx/            ← Dockerfile + TLS config
        ├── wordpress/        ← Dockerfile + PHP-FPM + setup scripts
        └── mariadb/          ← Dockerfile + init scripts
```

---

## Resources

- [Docker overview](https://docs.docker.com/get-started/)
- [Docker Compose file reference](https://docs.docker.com/compose/compose-file/)
- [Docker secrets with Compose](https://docs.docker.com/compose/use-secrets/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [WordPress documentation](https://wordpress.org/documentation/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [USER_DOC.md](USER_DOC.md) · [DEV_DOC.md](DEV_DOC.md)
