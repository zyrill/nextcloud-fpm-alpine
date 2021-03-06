FROM php:8.0.1-fpm-alpine3.13

LABEL maintainer="Dr. Philipp Kleine Jäger <philipp.kleinejaeger@gmail.com>"

ENV NEXTCLOUD_VERSION 20.0.5

# Set UID and GID
RUN deluser www-data && addgroup -S -g 666 www-data && adduser -S -u 666 -D -H -s /bin/false -G www-data www-data \
	&& apk add --no-cache --virtual .build-deps autoconf bzip2 file gcc g++ git libc-dev make musl-dev pcre-dev wget \
      	&& apk add --no-cache freetype-dev gmp-dev icu-dev icu-libs libjpeg-turbo-dev imagemagick-dev libpng-dev libxml2-dev libzip-dev oniguruma-dev postgresql-dev \
	&& RUN IMAGICK_COMMIT="132a11fd26675db9eb9f0e9a3e2887c161875206" \
	&& echo "**** install imagick php extension from source ****" \
	&& git clone https://github.com/Imagick/imagick \
	&& cd imagick \
	&& git checkout ${IMAGICK_COMMIT} \
	&& phpize \
	&& ./configure && make && make install && cd .. && rm -rf imagick \
	&& docker-php-ext-enable imagick \
	&& mkdir -p /var/www/html \
	&& cd /var/www/html \
	&& wget -O - https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.tar.bz2 | tar -xjf - --strip 1 \
	&& chown -R www-data. . \
	&& docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg \
 	&& docker-php-ext-install bcmath exif gd gmp intl mbstring mysqli opcache pdo_mysql pdo_pgsql pgsql zip \
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
