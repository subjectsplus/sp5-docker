# sp5-docker README

# Install

* DO NOT use the main branch. Create your own branch first!!!
* Clone the sp5-docker repo
    * `git clone  https://github.com/subjectsplus/sp5-docker.git`
* Checkout YOUR new branch
    * `git checkout my-new-sp5-docker-branch`
* Change into directory
    * `cd sp5-docker` 
* Go to subjectplus main repo https://github.com/subjectsplus/SubjectsPlus
   * Create your own branch off of sp5-main - this is going to be your submodule and where most of the development occurs
   * my-initials-sp5-symfony-migrate      
* Pull subjectplus submodule
    * `git submodule init`
    * Checkout new branch from SubjectsPlus repo
    * `git checkout my-new-subjectsplus-branch`
    

* Copy .env.default to .env
* Run docker-compose for the first time
    * `docker-compose up --build`

* Go to http://localhost:82/
* Create Config File
  * You MUST use `sp5_mysql` for the database host 

