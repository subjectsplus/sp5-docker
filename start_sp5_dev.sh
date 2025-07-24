#!/bin/bash

# Script Name: start_sp5_dev.sh
# Description: Bootstraps the SubjectsPlus dev environment for a given institution and environment.
# Usage: ./start_sp5_dev.sh <institution> <env>
# Example: ./start_sp5_dev.sh richter dev
# Author: charlesbrownroberts
# Date Created: 4/10/25
# Last Modified: 6/18/25

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

ENV_DOCKER=".env.docker.${INSTITUTION}.${ENV}"
ENV_SYMFONY=".docker/symfony/.env.symfony.${INSTITUTION}.${ENV}"
ENV_DOCKER_COMPOSE="docker-compose-${INSTITUTION}"

# Validate env files exist
if [[ ! -f "$ENV_DOCKER" ]]; then
  echo "❌ Docker env file not found: $ENV_DOCKER"
  exit 1
else
  echo "✅ Found Docker env file: $ENV_DOCKER"
fi

if [[ ! -f "$ENV_SYMFONY" ]]; then
  echo "❌ Symfony env file not found: $ENV_SYMFONY"
  exit 1
else
  echo "✅ Found Symfony env file: $ENV_SYMFONY"
fi

if [[ ! -f "$ENV_DOCKER_COMPOSE.yml" ]]; then
  echo "❌ Docker Compose file not found: $ENV_DOCKER_COMPOSE.yml"
  exit 1
else
  echo "✅ Found Docker Compose file: $ENV_DOCKER_COMPOSE.yml"
fi

echo "🔧 Setting up environment for $INSTITUTION [$ENV]"

# Copy Symfony env to .env so Symfony picks it up automatically
cp "$ENV_SYMFONY" SubjectsPlus/.env
echo "✅ Copied $ENV_SYMFONY to SubjectsPlus/.env"

# Start Docker containers using the --env-file flag for instance-specific env

docker compose --env-file "$ENV_DOCKER" -f "$ENV_DOCKER_COMPOSE.yml" up --build

if [[ $? -eq 0 ]]; then
  echo "✅ Docker containers are up and running."
else
  echo "❌ Docker Compose failed to start containers."
  exit 1
fi