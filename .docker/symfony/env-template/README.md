# Environment Template Directory

This directory contains templates for environment configuration files used in the SubjectsPlus Symfony application.

## Files

- `.env.TEMPLATE` - Complete template with all environment variables and placeholder values

## Usage

1. **Copy the template** to create your environment-specific file:
   ```bash
   cp .env.TEMPLATE .env.symfony.<deployment>.<environment>
   ```
   Examples:
   - `cp .env.TEMPLATE .env.symfony.calder.dev`
   - `cp .env.TEMPLATE .env.symfony.richter.prod`
   - file should be place in .docker/symfony/

2. **Edit the copied file** and replace all placeholder values with actual configuration:
   - Secrets and passwords should be strong and unique
   - URLs should match your actual environment
   - Database credentials should be for your specific database instance

3. **Security Note**: Never commit files containing real secrets to version control. The actual `.env.*` files should be added to `.gitignore`.

## Environment Variables Overview

### Core Symfony Configuration
- `APP_ENV` - Application environment (dev/prod/test)
- `APP_SECRET` - Secret key for Symfony (must be changed from default)

### Database Configuration
- `DATABASE_URL` - Full database connection string
- `DATABASE_PASSWORD` - Database password (alternative to embedding in URL)

### Security & Authentication
- `APP_AUTH_TYPE` - Authentication method (basic/saml/etc.)
- `SAML_ENABLED` - Enable SAML authentication
- `SECURITY_MATCHER_DOMAIN` - Domain for security matching

### LMS Integrations
- **Blackboard LTI 1.3**: Client ID, deployment ID, keys for Blackboard integration
- **Canvas LTI 1.3**: Issuer URL, OAuth endpoints, client ID, keys for Canvas integration

### CORS & Networking
- `CORS_ALLOW_ORIGIN` - Allowed origins for CORS
- `TRUSTED_PROXIES` - Trusted proxy IPs/CIDR ranges

### Azure Integration
- `AZURE_MYSQL_SSL_CERT_PATH` - Path to SSL certificate for Azure MySQL

## Docker Considerations

When using Docker, ensure that:
- Container names in `DATABASE_URL` match your `docker-compose.yml`
- Private key file paths are accessible within containers
- SSL certificate paths are mounted if using Azure MySQL

## Getting Help

If you need help configuring specific integrations:
- Blackboard LTI: Refer to Blackboard Learn administration documentation
- Canvas LTI: Refer to Canvas Developer documentation
- Database: Ensure MySQL 5.7+ compatibility