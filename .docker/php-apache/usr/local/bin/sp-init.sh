#!/usr/bin/env bash
set -e

service ssh start

cat <<EOL >/etc/motd

 SSSSS  PPPPPP  555555     DDDDD
SS      PP   PP 55         DD  DD    eee  vv   vv
 SSSSS  PPPPPP  555555     DD   DD ee   e  vv vv
     SS PP         5555    DD   DD eeeee    vvv
 SSSSS  PP      555555     DDDDDD   eeeee    v


Documentation: http://aka.ms/webapp-linux
PHP quickstart: https://aka.ms/php-qs

EOL
cat /etc/motd


if [ -e /home/site/wwwroot/hostingstart.html ]
then
    echo "hostingstart.html exists so it needs to be deleted"
    rm -f /home/site/wwwroot/hostingstart.html
fi

modify_local_phpini() {
  {
    # increase php max upload file size
    echo -e "upload_max_filesize=16M"

    # disable zend xdebug
    echo -e "; zend_extension=xdebug.so"

    # increase php memory limit. default is 128.
    echo -e "memory_limit=512M"

    # Increase max execution time to 120 seconds
    echo -e "max_execution_time=120"

    # Increase max input time to 120 seconds
    echo -e "max_input_time=120"
  } >> /usr/local/etc/php/conf.d/php.ini
}

add_host_docker_internal_to_hosts() {
  echo $(date "+%T") "Adding host.docker.internal to hosts file"
  HOST_DOMAIN="host.docker.internal"
  ping -q -c1 $HOST_DOMAIN >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    HOST_IP=$(ip route | awk 'NR==1 {print $3}')
    echo -e "$HOST_IP\t$HOST_DOMAIN" >>/etc/hosts
  fi
  echo $(date "+%T") "Done adding host.docker.internal to hosts file"
}

check_mysql_is_ready() {
  echo "Checking MySQL sp5_richter_mysql server is ready"
  /usr/local/wait-for-it.sh sp5_richter_mysql:3306 -s --timeout=920 -- echo "MySQL sp5_richter_mysql server is ready!"
}

install_nodejs() {
  # https://github.com/nodesource/distributions#debian-versions
  echo "######################################################"
  echo "node 20 Start Install"
  # Install prerequisites
  apt-get update -y
  apt-get install -y ca-certificates curl gnupg

  # Create keyrings directory
  mkdir -p /etc/apt/keyrings

  # Download and add the NodeSource GPG key to the keyring
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

  # Set the Node.js major version (e.g., 20 in this example)
  NODE_MAJOR=20

  # Add the NodeSource repository to sources.list.d
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

  # Update package lists and install Node.js
  apt-get update -y
  apt-get install nodejs -y

  # Clean up
  rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/nodesource.list
  echo "Node version: $(node --version)"
  echo "node End Install"
  echo "######################################################"
}
# TODO: yarn classic is in maintenance mode and will eventually reach end of life.
install_yarn() {
  echo "######################################################"
  echo "yarn Classic 1.22.19 Start Install"
  npm install --global yarn
  echo "Yarn version: $(yarn --version)"
  echo "######################################################"
  echo "yarn End Install"
}


#install_composer() {
#  # Check if Composer is already installed globally
#  if [ -x "$(command -v composer)" ]; then
#      echo "Composer is already installed globally."
#  else
#      echo "######################################################"
#      echo "composer Start Install"
#      # Update the package repository
#      apt update
#
#      # Install dependencies
#      apt install php-cli php-zip unzip -y
#
#      # Download and install Composer globally
#      php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
#      php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
#      php composer-setup.php
#      php -r "unlink('composer-setup.php');"
#
#      mv composer.phar /usr/local/bin/composer
#
#      # Verify Composer installation
#      composer --version
#
#      # Cleanup
#      apt autoremove --purge -y
#
#      echo "composer End Install"
#      echo "######################################################"
#  fi
#}

install_composer() {
  echo "######################################################"
  echo "Composer Start Install"

  # Check if Composer is already installed globally
  if command -v composer &> /dev/null; then
    echo "Composer is already installed globally."
    composer --version
  else
    echo "Installing Composer..."


    # Download and verify Composer installer
    EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

    if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
      >&2 echo 'ERROR: Invalid installer checksum'
      rm composer-setup.php
      exit 1
    fi

    # Install Composer
    php composer-setup.php --quiet --install-dir=/usr/local/bin --filename=composer
    RESULT=$?
    rm composer-setup.php

    # Verify installation
    if [ $RESULT -eq 0 ]; then
      echo "Composer installed successfully."
      composer --version
    else
      >&2 echo "ERROR: Composer installation failed"
      exit 1
    fi

  fi

  echo "Composer End Install"
  echo "######################################################"
}

install_symfony_cli() {
  echo "Install Symfony CLI"
  curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | sudo -E bash && \
      apt install symfony-cli
}

start_apache_server() {
  # start apache2
  if [ ! -d /var/lock/apache2 ]; then
    mkdir /var/lock/apache2
  fi

  if [ ! -d /var/run/apache2 ]; then
    mkdir /var/run/apache2
  fi

  echo "sleep for 10 seconds before starting apache2"
  echo "Your environment is ready when the terminal displays: Command line: '/usr/sbin/apache2 -D FOREGROUND' "
  sleep 10
  echo $(date "+%T") "Starting apache2"
  #sed -i "s/{PORT}/$PORT/g" /etc/apache2/apache2.conf
  sed -i "s/{PORT}/80/g" /etc/apache2/apache2.conf
  /usr/sbin/apache2ctl -D FOREGROUND
}


set_public_directory_permissions() {
    echo "Setting correct permissions for Symfony public directory"

    PUBLIC_DIR="/home/site/wwwroot/public"

    if [ -d "$PUBLIC_DIR" ]; then
        echo "Setting permissions for public directory"

        # Set directory permissions
        find "$PUBLIC_DIR" -type d -exec chmod 755 {} +

        # Set file permissions
        find "$PUBLIC_DIR" -type f -exec chmod 644 {} +

        # Ensure the web server can write to the public directory if needed
        chown -R www-data:www-data "$PUBLIC_DIR"

        echo "Public directory permissions have been set"
    else
        echo "Public directory not found at $PUBLIC_DIR"
    fi
}


add_host_docker_internal_to_hosts &&
check_mysql_is_ready &&
modify_local_phpini &&
install_nodejs &&
install_yarn &&
install_composer &&
install_symfony_cli &&
set_public_directory_permissions &&
start_apache_server