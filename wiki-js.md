
## WIKI JS

docker-compose.yml :

```
services:
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: wiki
      POSTGRES_PASSWORD: wikijsrocks
      POSTGRES_USER: wikijs
    logging:
      driver: "none"
    restart: unless-stopped
    volumes:
      - /opt/docker/wiki-js/db-data:/var/lib/postgresql/data  # Проброс данных Postgres

  wiki:
    image: ghcr.io/requarks/wiki:2
    user: "root"
    depends_on:
      - db
    environment:
      DB_TYPE: postgres
      DB_HOST: db
      DB_PORT: 5432
      DB_USER: wikijs
      DB_PASS: wikijsrocks
      DB_NAME: wiki
    restart: unless-stopped
    ports:
      - "8080:3000"
    volumes:
      - /opt/docker/wiki-js/data:/wiki/data  # Проброс каталога данных Wiki.js
      - /opt/docker/wiki-js/backups:/wiki/data/back-up  # Проброс каталога бэкапов
      - /opt/docker/wiki-js/assets:/wiki/public/assets # ico png pic

```
