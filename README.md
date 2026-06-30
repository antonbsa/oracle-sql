# Oracle SQL – Oracle 21c XE (Docker)

Local Oracle Database 21c XE environment via Docker.

## Prerequisites

| Tool    | Version | Notes                                            |
| ------- | ------- | ------------------------------------------------ |
| Docker  | 24+     | With Docker Compose v2 plugin (`docker compose`) |
| Node.js | 18+     | For npm scripts                                  |

> No JDK required to run the container. If you need JDBC connectivity from a Java client, install JDK 11+.

---

## Setup

### 1. Configure environment variables

`.env.development` has ready-to-use variable values for running locally

Password rules enforced by Oracle:

- Minimum 8 characters
- At least one uppercase letter, one lowercase letter, one digit

### 2. Start the database

```bash
npm run db:up
```

The first start downloads the image (~1.3 GB) and initializes the database — **this takes 2–5 minutes**. Watch progress with:

```bash
npm run db:logs
```

Wait until you see:

```
DATABASE IS READY TO USE!
```

---

## Connect

### Application user (XEPDB1 PDB)

```bash
npm run db:connect
```

### External client (DBeaver, SQL Developer, JDBC, oracledb)

| Setting      | Value                                     |
| ------------ | ----------------------------------------- |
| Host         | `localhost`                               |
| Port         | `1521`                                    |
| Service name | `XEPDB1` (app PDB) or `XE` (CDB root)     |
| SYS password | value of `ORACLE_PASSWORD`                |
| App user     | value of `APP_USER` / `APP_USER_PASSWORD` |

JDBC URL:

```
jdbc:oracle:thin:@localhost:1521/XEPDB1
```

---

## Validate connection

Inside `sqlplus` (either connect script above):

```sql
-- Basic connectivity
SELECT 'OK' AS status FROM dual;

-- Current user and database
SELECT USER, SYS_CONTEXT('USERENV','DB_NAME') AS db FROM dual;

-- Oracle version
SELECT * FROM v$version WHERE banner LIKE 'Oracle%';
```

Expected output from the last query:

```
BANNER
--------------------------------------------------------------------------------
Oracle Database 21c Express Edition Release 21.0.0.0.0 - Production
```

---

## NPM scripts reference

| Script                   | Description                              |
| ------------------------ | ---------------------------------------- |
| `npm run db:up`          | Start Oracle container in the background |
| `npm run db:down`        | Stop container (data volume preserved)   |
| `npm run db:destroy`     | Stop container **and delete all data**   |
| `npm run db:logs`        | Stream container logs                    |
| `npm run db:status`      | Show container health and status         |
| `npm run db:connect`     | Connect as app user via sqlplus          |

---

## Docker image

**`gvenzl/oracle-xe:21-slim`** — community-maintained, no Oracle account required.

- Source: https://hub.docker.com/r/gvenzl/oracle-xe
- Slim variant: reduced image size, no sample schemas

## Persistence

Data is stored in the `oracle-data` Docker named volume. It survives `db:down` and container restarts. Only `db:destroy` removes it.

---

## Troubleshooting

**Container unhealthy / startup timeout**

- First-run initialization can take 3–5 min — keep tailing logs with `npm run db:logs`.

**ORA-01017: invalid username/password**

- Check password values; they are case-sensitive.
- Re-create the container after changing passwords: `npm run db:destroy && npm run db:up`.
- **Do not set `ORACLE_DATABASE` to `XEPDB1`** in your env files. The `gvenzl/oracle-xe` image treats `ORACLE_DATABASE` as the name of a *new* PDB to create — if you set it to `XEPDB1` (which already exists as the default), that step is silently skipped and `APP_USER` is never created. Leave `ORACLE_DATABASE` unset to use `XEPDB1` (the connect script falls back to it automatically), or set it to a custom name like `DEVDB` to create a dedicated PDB.

**Port 1521 already in use**

- Change `ORACLE_PORT` in `.env` (e.g., `ORACLE_PORT=1522`) and restart.
