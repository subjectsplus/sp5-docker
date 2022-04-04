FROM appsvc/php:7.4-apache-xdebug_20200522.6

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        iputils-ping \
        git \
        vim \
        zip \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo pdo_mysql \
    && pecl install apcu && docker-php-ext-enable apcu \
    # Installation of Image Magic PHP Extension
    && apt install -y libmagickwand-dev --no-install-recommends && \
    pecl install imagick && docker-php-ext-enable imagick && \
    # Removal of packages that are only used to compile/install the extensions
    rm -rf /var/lib/apt/lists/*


RUN curl -sSk https://getcomposer.org/installer | php -- --disable-tls && \
   mv composer.phar /usr/local/bin/composer


#Remove php opcache file -only for development
RUN rm -rf /usr/local/etc/php/conf.d/opcache-recommended.ini

# enable mods
RUN a2enmod headers \
    rewrite

ARG XDEBUG_IDEKEY
ARG XDEBUG_REMOTE_HOST
ARG XDEBUG_REMOTE_PORT

RUN echo 'xdebug.idekey='$XDEBUG_IDEKEY >> /usr/local/etc/php/php.ini && \
    echo 'xdebug.remote_host='$XDEBUG_REMOTE_HOST >> /usr/local/etc/php/php.ini && \
    echo 'xdebug.remote_port='$XDEBUG_REMOTE_PORT >> /usr/local/etc/php/php.ini && \
    echo 'xdebug.default_enable = off' >> /usr/local/etc/php/php.ini && \
    echo 'xdebug.remote_enable = on' >> /usr/local/etc/php/php.ini && \
    echo 'xdebug.remote_autostart = off' >> /usr/local/etc/php/php.ini && \
    echo 'xdebug.remote_connect_back = off' >> /usr/local/etc/php/php.ini

COPY init.sh /usr/local/bin/init.sh
RUN chmod u+x /usr/local/bin/init.sh

COPY ./wait-for-it/wait-for-it.sh /usr/local/wait-for-it.sh
RUN chmod u+x /usr/local/wait-for-it.sh

WORKDIR /home/site/wwwroot

ENTRYPOINT ["/usr/local/bin/init.sh"]
