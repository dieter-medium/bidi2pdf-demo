#!/bin/bash
set -e

mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<-EOSQL
  CREATE DATABASE IF NOT EXISTS bidi2pdf_demo_production_cache;
  CREATE DATABASE IF NOT EXISTS bidi2pdf_demo_production_queue;
  CREATE DATABASE IF NOT EXISTS bidi2pdf_demo_production_cable;

  GRANT ALL PRIVILEGES ON bidi2pdf_demo_production.* TO ${MYSQL_USER}@'%';
  GRANT ALL PRIVILEGES ON bidi2pdf_demo_production_cache.* TO ${MYSQL_USER}@'%';
  GRANT ALL PRIVILEGES ON bidi2pdf_demo_production_queue.* TO ${MYSQL_USER}@'%';
  GRANT ALL PRIVILEGES ON bidi2pdf_demo_production_cable.* TO ${MYSQL_USER}@'%';

  FLUSH PRIVILEGES;
EOSQL


