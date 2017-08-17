# nextcloud-fpm-alpine
Latest Nextcloud based on php:7.1.8-fpm-alpine with opcode caching enabled for performance.

Nextcloud version: 12.0.2

For security reasons, consider disabling or even better: redirecting port 80 with a HTTP 302 redirection to 443 and enable TLS (SSL). Use the nginx config file for this.

Unless you absolutely need direct access to the database, don't expose the MariaDB port.
