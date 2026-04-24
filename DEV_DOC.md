# Developer Documentation (Inception)

## Environment Setup
### Prerequisites
- Docker Engine
- Docker Compose v2
- GNU Make
- A Linux virtual machine that can use the host paths required by the Makefile

### Configuration Files
- Compose file: `srcs/docker-compose.yml`
- Local non-sensitive configuration: `srcs/.env`
- Secrets directory: `secrets/`

### Secrets
The stack reads passwords from Docker secrets mounted from files:

- `secrets/db_password.txt`
- `secrets/db_root_password.txt`
- `secrets/wp_admin_password.txt`
- `secrets/wp_user_password.txt`

Keep real values out of the repository. The `secrets/` directory is git-ignored and must be created from `secrets.example/`.

## Build and Launch
The root `Makefile` is the supported entry point:

```sh
make          # first build and run
make down     # stop all containers
make restart  # restart the stack
make rebuild  # full teardown + rebuild
```

Under the hood, the Makefile runs `docker compose -f srcs/docker-compose.yml ...`.

## Useful Commands
### Containers
- Status: `docker ps`
- Logs: `docker logs nginx`, `docker logs wordpress`, `docker logs mariadb`
- Shell access: `docker exec -it nginx sh`, `docker exec -it wordpress sh`, `docker exec -it mariadb sh`

### Compose
- View the resolved configuration: `docker compose -f srcs/docker-compose.yml config`
- Restart a single service: `docker compose -f srcs/docker-compose.yml restart wordpress`

## Persistence Model
The project uses named volumes with bind mount driver options so the host filesystem stores the data directly:

- `wordpress_data` -> `/home/mobouifr/data/www` -> `/var/www/html`
- `db_data` -> `/home/mobouifr/data/mariadb` -> `/var/lib/mysql`

Because persistence lives on the host, rebuilding images does not erase content unless the host data directories are removed.

## Project Layout
- `srcs/docker-compose.yml`: service definitions for NGINX, WordPress, and MariaDB
- `srcs/requirements/nginx/`: NGINX Dockerfile and TLS configuration
- `srcs/requirements/wordpress/`: WordPress + PHP-FPM Dockerfile and setup scripts
- `srcs/requirements/mariadb/`: MariaDB Dockerfile and initialization scripts
- `secrets/`: runtime secret files mounted into the containers

## Design Notes
- Network isolation comes from the custom bridge network `my-net`; services discover each other by name.
- Sensitive values are kept in Docker secrets instead of inline environment variables.
- Persistent data uses host-backed named volumes so the state survives container recreation.
- NGINX is the only public entrypoint and should remain the only service publishing a host port.
