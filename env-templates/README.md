# Docker Environment Templates

This directory contains templates for Docker environment configuration files used in the SubjectsPlus application.

## Files

- `.env.docker.template` - Main Docker environment template
- `.env.docker.calder.template` - Calder instance-specific Docker template
- `.env.docker.default.template` - Default/fallback instance Docker template
- `.env.docker.richter.template` - Richter instance-specific Docker template

## Usage

1. **Copy the appropriate template** for your deployment:
   ```bash
   # For main Docker environment
   cp .env.docker.template ../.env

   # For instance-specific environments
   cp .env.docker.calder.template ../.env.docker.calder.dev
   cp .env.docker.richter.template ../.env.docker.richter.dev
   cp .env.docker.default.template ../.env.docker.default
   ```

2. **Edit the copied file** and replace placeholder values with actual configuration:
   - Database passwords should be strong and unique
   - Container names should match your docker-compose.yml
   - Ports should be available on your system
   - Network settings should not conflict with existing networks

3. **Security Note**: Never commit files containing real passwords to version control. The actual `.env*` files should be added to `.gitignore`.

## Environment Variables Overview

### MySQL Database Configuration
- `MYSQL_ROOT_PASSWORD` - Root user password for MySQL
- `MYSQL_DATABASE` - Database name to create
- `MYSQL_USER` - Application database user
- `MYSQL_PASSWORD` - Application database user password
- `MYSQL_PORT` - MySQL container port (usually 3306)

### Application Configuration
- `SUBJECTSPLUS_APP` - Path to SubjectsPlus application directory

### XDebug Configuration
- `XDEBUG_IDEKEY` - IDE key for debugging (PHPSTORM, VSCODE, etc.)
- `XDEBUG_REMOTE_PORT` - Port for XDebug connections
- `XDEBUG_REMOTE_HOST` - Host IP for XDebug (usually host.docker.internal)

### Docker Container Configuration
- `MYSQL_CONTAINER_NAME` - Name for MySQL container
- `PHP_APACHE_CONTAINER_NAME` - Name for PHP Apache container
- `PHP_APACHE_PORTS` - Port mapping for PHP Apache (host:container)
- `MYSQL_CONTAINER_PORTS` - Port mapping for MySQL (host:container)
- `DOCKER_BRIDGE_NAME` - Docker network bridge name

### Network Configuration (Default Instance)
- `DEFAULT_IPV4_MYSQL` - Static IP for MySQL service
- `DEFAULT_IPV4_PHP` - Static IP for PHP service
- `DEFAULT_SUBNET` - Docker network subnet

## Instance-Specific Notes

### Calder Instance
- Uses port 82 for PHP Apache
- MySQL on standard port 3306
- Separate network bridge for isolation

### Richter Instance
- Uses port 84 for PHP Apache
- MySQL on standard port 3306
- Separate network bridge for isolation

### Default Instance
- Uses port 84 for PHP Apache
- Includes static IP assignments
- Fallback configuration for unspecified instances

## Docker Compose Integration

Ensure your `docker-compose.yml` files reference these environment variables correctly. The templates are designed to work with the existing docker-compose configurations in the sp5-docker directory.