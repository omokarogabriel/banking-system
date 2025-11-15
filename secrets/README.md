# Secrets Directory

This directory contains sensitive configuration files for the secure Docker Compose deployment.

## Files

- `mysql_root_password.txt` - MySQL root password
- `mysql_user.txt` - MySQL application user
- `mysql_password.txt` - MySQL application user password

## Security Notes

⚠️ **IMPORTANT**: 
- These files contain example values for development only
- **NEVER commit actual production secrets to version control**
- Use strong, unique passwords in production
- Consider using external secret management systems (AWS Secrets Manager, HashiCorp Vault, etc.)

## Usage

These files are used by `docker-compose.security.yml` for secure credential management:

```bash
# Deploy with secure configuration
docker-compose -f docker-compose.security.yml up -d
```

## Production Recommendations

1. **Generate Strong Passwords**:
   ```bash
   # Generate secure passwords
   openssl rand -base64 32 > mysql_root_password.txt
   openssl rand -base64 32 > mysql_password.txt
   ```

2. **Set Proper File Permissions**:
   ```bash
   chmod 600 secrets/*.txt
   ```

3. **Use External Secret Management**:
   - AWS Secrets Manager
   - HashiCorp Vault
   - Kubernetes Secrets
   - Docker Swarm Secrets

4. **Regular Rotation**:
   - Rotate passwords regularly
   - Update all dependent services
   - Test connectivity after rotation