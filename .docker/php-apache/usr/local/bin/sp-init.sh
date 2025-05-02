#!/usr/bin/env bash
set -e

service ssh start

cat <<EOL >/etc/motd

UU   UU MM    MM LL          SSSSS  PPPPPP  555555
UU   UU MMM  MMM LL         SS      PP   PP 55
UU   UU MM MM MM LL          SSSSS  PPPPPP  555555
UU   UU MM    MM LL              SS PP         5555
 UUUUU  MM    MM LLLLLLL     SSSSS  PP      555555


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
  } >> /usr/local/etc/php/conf.d/php.ini
}

patch_symfony_assert_warning() {
  local file="/home/site/wwwroot/vendor/symfony/runtime/Internal/BasicErrorHandler.php"
  if [[ -f "$file" ]]; then
    echo "Patching assert.warning in BasicErrorHandler.php…"
    # change ini_set('assert.warning', 0) → ini_set('assert.warning', 1)
    sed -ri \
      -e "s/(ini_set\('assert.warning',[[:space:]]*)0/\11/" \
      "$file"
    echo "Patch applied."
  else
    echo "Warning: $file not found, skipping Symfony assert warning patch."
  fi
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
  echo "Checking MySQL server is ready"
  /usr/local/wait-for-it.sh sp5_mysql:3306 -s --timeout=920 -- echo "MySQL server is ready!"
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


install_composer() {
  # Check if Composer is already installed globally
  if [ -x "$(command -v composer)" ]; then
      echo "Composer is already installed globally."
  else
      echo "######################################################"
      echo "composer Start Install"
      # Update the package repository
      apt update

      # Install dependencies
      apt install -y unzip curl

      # Download and install Composer globally
      EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
      php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
      ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"
      php -r "if ('$EXPECTED_CHECKSUM' === '$ACTUAL_CHECKSUM') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
      php composer-setup.php
      php -r "unlink('composer-setup.php');"

      mv composer.phar /usr/local/bin/composer

      # Verify Composer installation
      composer --version

      # Cleanup
      apt autoremove --purge -y

      echo "composer End Install"
      echo "######################################################"
  fi
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


add_host_docker_internal_to_hosts &&
check_mysql_is_ready &&
modify_local_phpini &&
patch_symfony_assert_warning &&
install_nodejs &&
install_yarn &&
install_composer &&
install_symfony_cli &&
start_apache_server