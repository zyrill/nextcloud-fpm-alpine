# nextcloud-fpm-alpine
Latest Nextcloud based on php:7.2.1-fpm-alpine3.7 with opcode caching enabled for performance.

Nextcloud version: 13.0.2

For security reasons, consider disabling or even better: redirecting port 80 with a HTTP 302 redirection to 443 and enable TLS (SSL). Use the nginx config file for this.

Note that tagged images are released and never changed. The "latest" image however may be a few commits ahead of the last released version. This process allows incorporation of version bumps of upstream images without compromising stability of releases.

Unless you absolutely need direct access to the database, don't expose the MariaDB port.

Here are the config.php entries corresponding to the config above. This is just an excerpt, just use the Nextcloud installer to configure DB etc. and afterwards add the memcache and redis entries:

    'dbtype' => 'mysql',
    'dbhost' => 'mariadb',
    'dbname' => 'next',
    'dbuser' => 'next',
    'dbpassword' => 'H8nNqjBhUFHwVSDapZAyh4mH',
    'memcache.local' => '\\OC\\Memcache\\APCu',
    'memcache.locking' => '\\OC\\Memcache\\APCu',
    'memcache.distributed' => '\\OC\\Memcache\\Redis',
    'redis' =>
      array (
        'host' => 'redis',
        'port' => 6379,
        'timeout' => 0,
        'dbindex' => 1,
      ),
