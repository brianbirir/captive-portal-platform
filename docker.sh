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
  *)
    echo "Usage: $0 {build|up|down|logs|restart|shell|ps|health} [dev|prod]"
    echo "  - First parameter is the command to execute"
    echo "  - Second optional parameter is the environment (dev or prod, defaults to dev)"
    exit 1
esac

exit 0
