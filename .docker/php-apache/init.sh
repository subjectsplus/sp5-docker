#!/usr/bin/env bash

init_composer_dependecies() {
  echo $(date "+%T") "Installing composer dependencies"
  cd /home/site/wwwroot
  composer install
  echo $(date "+%T") "Done installing composer dependencies"
}

run_database_migrations() {
  echo $(date "+%T") "Running database migrations"
  cd /home/site/wwwroot
  php bin/console --no-interaction doctrine:migrations:migrate
  echo $(date "+%T") "Done running database migrations"
}

load_doctrine_fixtures() {
  echo $(date "+%T") "Loading doctrine fixtures"
  cd /home/site/wwwroot
  bin/console doctrine:schema:drop --force && bin/console doctrine:schema:update --force && bin/console doctrine:fixtures:load -n
  echo $(date "+%T") "Done loading doctrine fixtures"
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

start_apache_server() {
  # start apache2
  echo $(date "+%T") "Starting apache2"
  sed -i "s/{PORT}/80/g" /etc/apache2/apache2.conf
  /usr/sbin/apache2ctl -D FOREGROUND
}

check_mysql_is_ready() {
  echo "Checking MySQL server is ready"
  /usr/local/wait-for-it.sh sp5_mysql:3306 -s --timeout=920 -- echo "MySQL server is ready!"
}


init_composer_dependecies &
add_host_docker_internal_to_hosts &
check_mysql_is_ready
run_database_migrations
load_doctrine_fixtures
start_apache_server
