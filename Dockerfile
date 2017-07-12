FROM php:7.1.7-fpm-alpine
MAINTAINER Dr. Philipp Krüger <p.a.c.krueger@gmail.com>

# Set UID and GID
RUN deluser www-data && addgroup -g 666 www-data && adduser -u 666 -D -s /bin/false -G www-data www-data

# Install dependencies
RUN apk update && \
	apk upgrade && \
	apk add autoconf bzip2 freetype-dev file gcc g++ icu-dev icu-libs libc-dev libjpeg-turbo-dev libmcrypt-dev pcre-dev libpng-dev libxml2-dev make musl-dev postgresql-dev wget

# Install Nextcloud
ENV NEXTCLOUD_VERSION 12.0.0
RUN mkdir -p /var/www/html && \
	cd /var/www/html && \
	wget -O - https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.tar.bz2 | tar -xjf - --strip 1 && \
    chown -R www-data. .

# Configure PHP
RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
RUN docker-php-ext-install gd exif intl mbstring mcrypt mysqli opcache pdo_mysql pdo_pgsql pgsql zip
RUN { \
		echo 'always_populate_raw_post_data=-1'; \
		echo 'max_execution_time=240'; \
		echo 'max_input_vars=1500'; \
		echo 'upload_max_filesize=32M'; \
		echo 'post_max_size=32M'; \
	} > /usr/local/etc/php/conf.d/nextcloud.ini

# set recommended PHP.ini settings # see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=10000'; \
		echo 'opcache.revalidate_freq=1'; \
		echo 'opcache.save_comments=1'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
		echo 'opcache.enable=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN mkdir -p /tmp/pear/download/ && \
	cd /tmp/pear/download/ && \
	wget -O apcu.tgz https://pecl.php.net/get/APCu && \
	echo "" | pear install apcu.tgz && \
	wget -O redis.tgz https://pecl.php.net/get/redis && \
	pear install redis.tgz && \
	docker-php-ext-enable apcu redis

# Clean up
RUN apk del autoconf bzip2 file gcc g++ imagemagick libc-dev libxml2-dev make musl-dev wget && \
	rm -rf /var/cache/apk/*

# Configure volumes
VOLUME /var/www/html/

