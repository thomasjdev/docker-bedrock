FROM php:7.1-fpm

# install the PHP extensions we need
RUN set -ex; \
	\
	apt-get update; \
	apt-get install -y \
		libjpeg-dev \
		libpng-dev \
        libxml2-dev \
		libmcrypt-dev \
		libreadline-dev \
		libedit-dev \
		libpspell-dev \
		curl \
		wget \
		less \
		git \
		subversion \
		sudo \
	; \
	rm -rf /var/lib/apt/lists/*; \
	\
	docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
	docker-php-ext-install gd mysqli opcache zip xml xmlrpc mcrypt json readline exif gettext posix pspell iconv
# TODO consider removing the *-dev deps and only keeping the necessary lib* packages

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
        echo 'upload_max_filesize = 64M'; \
        echo 'post_max_size = 64M'; \
        echo 'memory_limit = 256M'; \
        echo 'date.timezone = "America/Los_Angeles"'; \
	} > /usr/local/etc/php/conf.d/custom.ini

RUN set -ex; \
	curl -sS -o /usr/local/bin/wp \
		-L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x  /usr/local/bin/wp && \
	curl -sS -o /tmp/composer-setup.php \
        -L https://getcomposer.org/installer && \
    php /tmp/composer-setup.php --install-dir=/usr/bin --filename=composer && \
    rm /tmp/composer-setup.php && \
    true

RUN set -ex; \
	chown www-data /var/www && \
	sudo -u www-data wp package install aaemnnosttv/wp-cli-dotenv-command

WORKDIR /app