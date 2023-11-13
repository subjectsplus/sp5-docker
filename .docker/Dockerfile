FROM mcr.microsoft.com/appsvc/php:8.0-apache-xdebug_20230721.2.tuxprod
#FROM mcr.microsoft.com/appsvc/php:7.4-apache-xdebug_20221208.1.tuxprod
#FROM appsvc/php:7.4-apache-xdebug_20200522.6

RUN apt-get update -y --fix-missing && apt-get install -y --no-install-recommends sudo \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        iputils-ping \
        git \
        vim \
        zip \
        net-tools \
        libapache2-mod-shib \
        memcached \
        libmemcached-tools \
        libmemcached-dev \
        net-tools \
        netcat \
        htop \
        curl \
        tzdata \
        unzip \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo pdo_mysql \
    && pecl install apcu && docker-php-ext-enable apcu \
    # Installation of Image Magic PHP Extension
    && apt install -y libmagickwand-dev --no-install-recommends \
    && docker-php-ext-enable imagick \
    # Removal of packages that are only used to compile/install the extensions
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean



#Remove php opcache file -only for development
RUN rm -rf /usr/local/etc/php/conf.d/opcache-recommended.ini

# Enable APCU Cache
COPY php-apache/usr-local-etc-php-confd/docker-php-ext-apcu.ini /usr/local/etc/php/conf.d/

# enable mods
RUN a2enmod headers \
    rewrite


RUN echo "Mutex posixsem" >> /etc/apache2/apache2.conf

#ARG XDEBUG_IDEKEY
#ARG XDEBUG_REMOTE_HOST
#ARG XDEBUG_REMOTE_PORT
#
#RUN echo 'xdebug.idekey='$XDEBUG_IDEKEY >> /usr/local/etc/php/php.ini && \
#    echo 'xdebug.remote_host='$XDEBUG_REMOTE_HOST >> /usr/local/etc/php/php.ini && \
#    echo 'xdebug.remote_port='$XDEBUG_REMOTE_PORT >> /usr/local/etc/php/php.ini && \
#    echo 'xdebug.default_enable = off' >> /usr/local/etc/php/php.ini && \
#    echo 'xdebug.remote_enable = on' >> /usr/local/etc/php/php.ini && \
#    echo 'xdebug.remote_autostart = off' >> /usr/local/etc/php/php.ini && \
#    echo 'xdebug.remote_connect_back = off' >> /usr/local/etc/php/php.ini

# Copy your local_bashrc file to the home directory of the user (e.g., root)
COPY php-apache/root/local_bashrc /root/local_bashrc

# Append the source command to the main .bashrc file
RUN echo "source ~/local_bashrc" >> /root/.bashrc

# Set global git user
RUN git config --global user.email "webmaster.lib@miami.edu" && git config --global user.name "WADTeam" && git config --global --add safe.directory /home/site/wwwroot

# copy the deploy file that updates the symfony app
COPY php-apache/usr/local/bin/sp-build.sh /usr/local/bin/sp-build.sh
RUN chmod u+x /usr/local/bin/sp-build.sh

# copy the docker start up file
COPY php-apache/usr/local/bin/sp-init.sh /usr/local/bin/sp-init.sh
RUN chmod u+x /usr/local/bin/sp-init.sh

COPY php-apache/wait-for-it/wait-for-it.sh /usr/local/wait-for-it.sh
RUN chmod u+x /usr/local/wait-for-it.sh

WORKDIR /home/site/wwwroot

ENTRYPOINT ["/usr/local/bin/sp-init.sh"]
