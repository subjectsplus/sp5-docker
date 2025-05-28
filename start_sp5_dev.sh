#!/bin/bash

# Script Name: start_sp5_dev.sh
# Description: Bootstraps the SubjectsPlus dev environment for a given institution and environment.
# Usage: ./start_sp5_dev.sh <institution> <env>
# Example: ./start_sp5_dev.sh richter dev
# Author: charlesbrownroberts
# Date Created: 4/10/25
# Last Modified: 4/10/25

# Exit on any error
set -e

# Main code starts here
INSTITUTION=$1
ENV=$2

if [[ -z "$INSTITUTION" || -z "$ENV" ]]; then
  echo "Usage: $0 <institution> <env>"
  echo "Example: $0 richter dev"
  exit 1
fi

ENV_DOCKER=".env.${INSTITUTION}.${ENV}.docker"
ENV_SYMFONY=".docker/symfony/.env.${INSTITUTION}.${ENV}.symfony"
ENV_DOCKER_COMPOSE="docker-compose-${INSTITUTION}"

# Validate env files exist
if [[ ! -f "$ENV_DOCKER" ]]; then
  echo "❌ Docker env file not found: $ENV_DOCKER"
  exit 1
fi

if [[ ! -f "$ENV_SYMFONY" ]]; then
  echo "❌ Symfony env file not found: $ENV_SYMFONY"
  exit 1
fi

echo "🔧 Setting up environment for $INSTITUTION [$ENV]"

# Create environment-specific docker-compose file
cp docker-compose.yml "$ENV_DOCKER_COMPOSE.yml"

# Replace the volume name with environment-specific name
sed -i '' "s/subjectsplus5-db/${INSTITUTION}-subjectsplus5-db/g" "$ENV_DOCKER_COMPOSE.yml"


# Copy Symfony env to .env.local so Symfony picks it up automatically
cp "$ENV_SYMFONY" SubjectsPlus/.env
echo "✅ Copied $ENV_SYMFONY to SubjectsPlus/.env"

# Export Docker environment variables for use in compose
export $(grep -v '^#' "$ENV_DOCKER" | xargs)
echo "✅ Exported environment variables from $ENV_DOCKER"

# Start Docker containers
docker compose -f "$ENV_DOCKER_COMPOSE.yml" --env-file "$ENV_DOCKER" up --build
echo "✅ Docker containers are up and running."