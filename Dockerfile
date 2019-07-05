FROM php:7.3.6-fpm-alpine3.9

LABEL maintainer="Dr. Philipp Kleine Jäger <philipp.kleinejaeger@gmail.com>"

ENV NEXTCLOUD_VERSION 16.0.2

# Set UID and GID
RUN deluser www-data && addgroup -g 666 www-data && adduser -u 666 -D -s /bin/false -G www-data www-data \
	&& apk add --no-cache --virtual .build-deps autoconf bzip2 file gcc g++ libc-dev make musl-dev pcre-dev wget \
	&& apk add --no-cache freetype-dev icu-dev icu-libs libjpeg-turbo-dev libpng-dev libxml2-dev libzip-dev postgresql-dev \
	&& mkdir -p /var/www/html \
	&& cd /var/www/html \
	&& wget -O - https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.tar.bz2 | tar -xjf - --strip 1 \
	&& chown -R www-data. . \
	&& docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ \
	&& docker-php-ext-install gd exif intl mbstring mysqli opcache pdo_mysql pdo_pgsql pgsql zip \
	&& { \
		echo 'always_populate_raw_post_data=-1'; \
		echo 'max_execution_time=240'; \
		echo 'max_input_vars=1500'; \
		echo 'upload_max_filesize=32M'; \
		echo 'post_max_size=32M'; \
		echo 'memory_limit=512M'; \
	} > /usr/local/etc/php/conf.d/nextcloud.ini \
	&& { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=10000'; \
		echo 'opcache.revalidate_freq=1'; \
		echo 'opcache.save_comments=1'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
		echo 'opcache.enable=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini \
	&& mkdir -p /tmp/pear/download/ \
	&& cd /tmp/pear/download/ \
	&& wget -O apcu.tgz https://pecl.php.net/get/APCu \
	&& echo "" | pear install apcu.tgz \
	&& wget -O redis.tgz https://pecl.php.net/get/redis \
	&& pear install redis.tgz \
	&& docker-php-ext-enable apcu redis \
	&& rm -rf /tmp/pear/ \
	&& apk del --no-cache .build-deps \
	&& echo '*/15    *       *       *       *       php -f /var/www/html/cron.php' > /etc/crontabs/www-data

# Configure volumes
VOLUME /var/www/html/
