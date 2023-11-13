#!/bin/bash

# Define your functions here

function git_pull() {
    echo "Git Pull not available yet in dev"
    # Add your code for Function One here
#    cd /home/site/wwwroot || exit
#    eval "$(ssh-agent -s)" && ssh-add /root/.ssh/dev_e_sp5_id_ed25519
#    git pull origin staging
}

function composer_install() {
    echo "composer install is running"
    # Add your code for Function Two here
    cd /home/site/wwwroot || exit
    composer install --optimize-autoloader
}

function doctrine_migrations() {
    echo "doctrine:migrations:migrate is running"
    # Add your code for Function Three here
    cd /home/site/wwwroot || exit
    bin/console doctrine:migrations:migrate
}

function yarn_install() {
    echo "yarn install is running"
    # Add your code for Function Three here
    cd /home/site/wwwroot || exit
    yarn install
}

function yarn_encore_dev() {
    echo "yarn encore dev is running"
    # Add your code for Function Three here
    cd /home/site/wwwroot || exit
    yarn encore dev
}

function yarn_encore_production() {
    echo "yarn encore production is running"
    # Add your code for Function Three here
    cd /home/site/wwwroot || exit
    yarn encore production
}

function symfony_cache_clear() {
    echo "bin/console cache:clear is running"
    # Add your code for Function Three here
    cd /home/site/wwwroot || exit
    bin/console cache:clear
}

#function () {
#    echo ""
#    # Add your code for Function Three here
#    cd /home/site/wwwroot || exit
#
#}





# Main script starts here

echo "Welcome to the SubjectsPlus build script"
echo "In most cases these should be run in order, but not always. For example, maybe the cache needs to be cleared, then there is no need to run "

# Display menu options
echo "1. Git Pull"
echo "2. Run Composer Install"
echo "3. Run Doctrine Migrations"
echo "4. Run Yarn Install"
echo "5. Run Yarn Encore Dev"
echo "6. Run Yarn Encore Production"
echo "7. Run Symfony Cache Clear"
echo "8. Exit Build Script"

# Prompt the user for input
read -p "Please select an option (1/2/3/4/5/6/7): " choice

# Case statement to execute functions based on user input
case $choice in
    1)
        git_pull
        ;;
    2)
        composer_install
        ;;
    3)
        doctrine_migrations
        ;;
    4)
        yarn_install
        ;;
    5)
        yarn_encore_dev
        ;;
    6)
        yarn_encore_production
        ;;
    7)
        symfony_cache_clear
        ;;
    8)
        echo "Exiting the script."
        ;;
    *)
        echo "Invalid option. Please select a valid option (1/2/3/4)."
        ;;
esac
