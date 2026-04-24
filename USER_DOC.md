# User Documentation (Inception)

## What This Stack Provides
Inception deploys three containers with Docker Compose:

- NGINX terminates HTTPS on port `443` and proxies requests to WordPress.
- WordPress runs with PHP-FPM only; there is no NGINX inside the application container.
- MariaDB stores the WordPress database.

The containers share a custom bridge network called `my-net`, so they can reach each other by service name.

## Start, Stop, Restart
Use the root `Makefile` for all common operations:

```sh
make          # first build and run
make down     # stop all containers
make restart  # restart the stack
make rebuild  # full teardown + rebuild
```

`make` also creates the host storage directories used by the stack:

- `/home/mobouifr/data/www`
- `/home/mobouifr/data/mariadb`

## Open the Site
After the stack starts, open:

- https://mobouifr.42.fr
- https://mobouifr.42.fr/wp-admin

If the domain does not resolve, add a hosts entry that points to your VM IP:

```sh
<VM_IP> mobouifr.42.fr
```

## Secrets and Settings
Passwords are stored as Docker secrets from the `secrets/` folder.

- `secrets/db_password.txt`
- `secrets/db_root_password.txt`
- `secrets/wp_admin_password.txt`
- `secrets/wp_user_password.txt`

The `secrets/` directory is git-ignored and must be created from `secrets.example/`:

```sh
cp -r secrets.example/ secrets/
```

The WordPress admin username must not contain `admin` or `administrator`.

## Persistence
The project keeps its data on the host using named volumes backed by bind mount driver options:

- WordPress files: `/home/mobouifr/data/www` -> `/var/www/html`
- MariaDB data: `/home/mobouifr/data/mariadb` -> `/var/lib/mysql`

If you need to reset the stack completely, use `make rebuild` and remove the host data directories only if you want a full data wipe.
