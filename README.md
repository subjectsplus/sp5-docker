# sp5-docker README

# Install

* DO NOT use the main branch. Create your own branch first!!!
* Clone the sp5-docker repo
    * `git clone  https://github.com/subjectsplus/sp5-docker.git`
* Checkout YOUR new branch
    * `git checkout my-new-sp5-docker-branch`
* Change into directory
    * `cd sp5-docker`    
* Pull subjectplus submodule
    * `git submodule init`
    * Create new branch on SubjectsPlus repo
    * `git checkout my-new-subjectsplus-branch`
    

* Rename .env.default to .env
* Run docker-compose for the first time
    * `docker-compose up --build`

* Go to http://localhost:82/
* Create Config File
  * You MUST use `sp5_mysql` for the database host 

