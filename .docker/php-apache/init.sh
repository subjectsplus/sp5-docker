#!/usr/bin/env bash

run_composer_clearcache() {
  echo $(date "+%T") "Running composer clearcache"
  cd /home/site/wwwroot
  composer clearcache
  echo $(date "+%T") "Done composer clearcache"
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

#load_doctrine_fixtures() {
#  echo $(date "+%T") "Loading doctrine fixtures"
#  cd /home/site/wwwroot
#  bin/console doctrine:schema:drop --force && bin/console doctrine:schema:update --force && bin/console doctrine:fixtures:load -n
#  echo $(date "+%T") "Done loading doctrine fixtures"
#}


run_install_node() {
  echo $(date "+%T") "Installing NODE v14"
  # https://github.com/nodesource/distributions/blob/master/README.md#debinstall
  curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
  apt-get install -y nodejs
  echo $(date "+%T") "Finished installing NODE v14"
  echo "Node version"
  node -v
}

run_install_nvm() {
   echo $(date "+%T") "Installing nvm"
   # https://tecadmin.net/how-to-install-nvm-on-debian-10/#:~:text=Installing%20NVM%20on%20Debian&text=Firstly%2C%20Open%20a%20terminal%20on,nvm%20installer%20script%20on%20terminal.&text=Above%20script%20makes%20all%20the,of%20current%20logged%20in%20user.

   touch /root/.bashrc
   curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
   export NVM_DIR="$HOME/.nvm"
   [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
   [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

   echo $(date "+%T") "Finished installing nvm"
   echo "nvm version"
   nvm -v
}


run_install_yarn() {
  echo $(date "+%T") "Installing yarn"
  cd /root
  npm install --global yarn
  echo $(date "+%T") "Finished Installing yarn"
  echo "yarn version"
  yarn -v

}

run_symfony_cache_global_clear() {
  echo $(date "+%T") "Running symfony cache global clear"
  cd /home/site/wwwroot
  php bin/console cache:pool:clear cache.global_clearer
  echo $(date "+%T") "Done symfony cache global clear"
}

run_npm_cache_clean() {
  echo $(date "+%T") "Running npm cache clean"
  cd /home/site/wwwroot
  npm cache clean --force
  echo $(date "+%T") "Done npm cache clean"
}

run_yarn_cache_clean() {
  echo $(date "+%T") "Running yarn cache clean"
  cd /home/site/wwwroot
  yarn cache clean
  echo $(date "+%T") "Done yarn cache clean"
}

run_yarn_install() {
  echo $(date "+%T") "Running yarn install packages"
  yarn install
  echo $(date "+%T") "Finish running yarn install packages"
}

run_yarn_encore_dev() {
    echo "sleep for 5 seconds before starting apache2"
    sleep 5
    echo $(date "+%T") "Running yarn encore dev"
    cd /home/site/wwwroot
    yarn encore dev
    echo $(date "+%T") "Done yarn encore dev"
}

start_apache_server() {
  # start apache2
  echo "sleep for 10 seconds before starting apache2"
  sleep 10
  echo $(date "+%T") "Starting apache2"
  sed -i "s/{PORT}/80/g" /etc/apache2/apache2.conf
  /usr/sbin/apache2ctl -D FOREGROUND
}

run_composer_clearcache
init_composer_dependecies &
add_host_docker_internal_to_hosts &
check_mysql_is_ready
run_database_migrations
run_install_node
run_install_nvm
run_install_yarn
run_symfony_cache_global_clear
run_npm_cache_clean
run_yarn_cache_clean
run_yarn_install
run_yarn_encore_dev
start_apache_server
