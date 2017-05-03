# nextcloud-fpm-alpine
Latest Nextcloud based on php:7.1.4-fpm-alpine with opcode caching enabled for performance.

Nextcloud version: 11.0.3

Note: the vulnerabilities stem from the upstream Alpine image, so there's nothing that can be done here downstream. The affected packages are required by php plugins so it's not possible to simply remove them. Also, I've checked the findings and while critical, they should not impede the security of the Nextcloud installation.

For security reasons, consider disabling or even better: redirecting port 80 with a HTTP 302 redirection to 443 and enable TLS (SSL). Use the nginx config file for this.

Unless you absolutely need direct access to the database, don't expose the MariaDB port.