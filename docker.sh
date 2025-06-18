#!/bin/bash

# Script to manage Docker operations for the Captive Portal Platform
# Supports both development and production environments

# Default to development environment
ENV=${2:-dev}

# Set the appropriate docker-compose file based on environment
if [ "$ENV" == "prod" ]; then
  COMPOSE_FILE="docker-compose.prod.yml"
  echo "Using production environment..."
else
  COMPOSE_FILE="docker-compose.yml"
  echo "Using development environment..."
fi

case "$1" in
  build)
    echo "Building Docker image for $ENV environment..."
    docker-compose -f $COMPOSE_FILE build
    ;;
  up)
    echo "Starting containers for $ENV environment..."
    docker-compose -f $COMPOSE_FILE up -d
    ;;
  down)
    echo "Stopping containers for $ENV environment..."
    docker-compose -f $COMPOSE_FILE down
    ;;
  logs)
    echo "Showing logs for $ENV environment..."
    docker-compose -f $COMPOSE_FILE logs -f
    ;;
  restart)
    echo "Restarting containers for $ENV environment..."
    docker-compose -f $COMPOSE_FILE restart
    ;;
  shell)
    echo "Accessing shell in web container for $ENV environment..."
    docker-compose -f $COMPOSE_FILE exec web sh
    ;;
  ps)
    echo "Showing container status for $ENV environment..."
    docker-compose -f $COMPOSE_FILE ps
    ;;
  health)
    echo "Checking health status for $ENV environment..."
    curl -s http://localhost:8000/health | json_pp
    ;;
  db-migrate)
    echo "Running database migrations for $ENV environment..."
    docker-compose -f $COMPOSE_FILE exec web flask db migrate -m "${2:-Database migration}"
    ;;
  db-upgrade)
    echo "Upgrading database for $ENV environment..."
    docker-compose -f $COMPOSE_FILE exec web flask db upgrade
    ;;
  db-downgrade)
    echo "Downgrading database for $ENV environment..."
    docker-compose -f $COMPOSE_FILE exec web flask db downgrade
    ;;
  create-admin)
    echo "Creating admin user for $ENV environment..."
    docker-compose -f $COMPOSE_FILE exec web python -c "
from app import create_app, db
from app.models import User
app = create_app()
with app.app_context():
    if User.query.filter_by(email='admin@example.com').first() is None:
        admin = User(email='admin@example.com')
        admin.set_password('password')
        db.session.add(admin)
        db.session.commit()
        print('Admin user created')
    else:
        print('Admin user already exists')
"
    ;;
  backup-db)
    echo "Backing up database for $ENV environment..."
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    docker-compose -f $COMPOSE_FILE exec web sh -c "cp captive_portal.db /app/captive_portal_backup_${TIMESTAMP}.db"
    docker cp $(docker-compose -f $COMPOSE_FILE ps -q web):/app/captive_portal_backup_${TIMESTAMP}.db ./backups/
    echo "Database backed up to ./backups/captive_portal_backup_${TIMESTAMP}.db"
    ;;
  *)
    echo "Usage: $0 {build|up|down|logs|restart|shell|ps|health|db-migrate|db-upgrade|db-downgrade|create-admin|backup-db} [dev|prod]"
    echo "  - First parameter is the command to execute"
    echo "  - Second optional parameter is the environment (dev or prod, defaults to dev)"
    exit 1
esac

exit 0
