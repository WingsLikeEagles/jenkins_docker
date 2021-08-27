# jenkins_docker
Jenkins running in a Docker container  
You will need to create your own image.  I suggest using a local registry (this is not strictly necessary).  You can see my steps to create a local Portainer Web GUI which has steps to create your own local registry and how to use it.  https://github.com/WingsLikeEagles/Docker_Portainer_setup  

# The Dockerfile needs to be built
`docker built -t localhost:5000/myjenkins:2.277.4-lts .`  

# Push it to the local registry
`docker push localhost:5000/myjenkins:2.277.4-lts`

# Create a volume to store the config
`docker volume create jenkins_home`

# Run it
`docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v jenkins_home:/var/jenkins_home -p 8080:8080 --name jenkins localhost:myjenkins:2.277.4-lts`

# Password
When I tried to log in for the first time the admin account password was not displayed in the console (and all the defaults I tried failed).  This was annoying.  I found that I needed to do the following:  
1. Set the "useSecurity" to "false"  
  a. `docker exec -it jenkins /bin/bash`  
  b. `sed -i 's/useSecurity>true</useSecurity>false</g' /var/jenkins_home/config.xml`  
  c. `exit`
2. Stop and Restart container:  
  a. `docker stop jenkins`  
  b. `docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v jenkins_home:/var/jenkins_home -p 8080:8080 --name jenkins localhost:myjenkins:2.277.4-lts`
3. Go into the Web GUI. (http://localhost:8080)
4. On the Dashboard click on "Manage Jenkins"
5. Select "Configure Global Security"
6. Select "Security Realm" to "Jenkins' own user database", and check the box next to "Allow uers to sign up".
7. Click "Save" at the bottom.
8. Create a new account by clicking on "Sign Up" in the upper right corner and entering the requested info.
9. Set the "useSecurity" back to "true"  
  a. `docker exec -it jenkins /bin/bash`  
  b. `sed -i 's/useSecurity>false</useSecurity>true</g' /var/jenkins_home/config.xml`   
  c. `exit`  
10. Stop and Restart container:  
  a. `docker stop jenkins`  
  b. `docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v jenkins_home:/var/jenkins_home -p 8080:8080 --name jenkins localhost:myjenkins:2.277.4-lts`  
11. Open the Web Gui (http://localhost:8080) and sign in with your new user account
12. Change authorization to only allow logged in users to make changes to the system:  
  a. On the Dashboard click on "Manage Jenkins"  
  b. Select "Configure Global Security"  
  c. Under "Authorization" select "Logged-in users can do anything"  
  d. Click "Save" at the bottom.  
13. Log out, and log back in to verify
14. You may want to delete the initial user "jenkins_admin" that was created during the install

# Runner  
This section needs work as it creates a new runner each time it is run... (maybe remove the `--rm`?)
`docker run --rm --name gitlab-runner-01 --network="host" -v gitlab-runner-01-config:/etc/gitlab-runner localhost:5000/gitlab-runner:alpine-v14.2.0 register --non-interactive --name my-runner-01 --url=http://gitlab.localhost.localdomain/ --registration-token $REGISTRATION_TOKEN --executor shell`  
`-rm` to destroy the container after it finishes running.  The volumes, config, will persist because of the `-v` command below.
`--name gitlab-runner-01` this is the name of the container (the gitlab-runner container) we are registering with this command.
`--network="host"` is needed for a localhost setup where the URL is included in your local HOSTS file.  127.0.0.1 gitlab.localhost.localdomain  
`-v gitlab-runner-01-config:/etc/gitlab-runner` is used to save the config when the container dies.  A separate volume should be used for each runner (i.e. gitlab-runner-02, etc).  
`localhost:5000/gitlab-runner:alpine-v14.2.0` is the local registry image being run (this requires a local registry, see https://github.com/WingsLikeEagles/Docker_Portainer_setup)  
`register --non-interactive --name my-runner-01 --url=http://gitlab.localhost.localdoamin/ --registration-token $REGISTRATION_TOKEN --executor shell` is the command being passed inside the container to register it.  
- `register` is the command to register a host (or container in this case) with the gitlab server.  
- `--non-interactive` is to automate the registration.  
- `--name my-runner-01` is used inside the container for registering with the GitLab server.  This is NOT the name of the container.  
- `--url=http://gitlab.localhost.localdomain/` is the GitLab server.  Be sure to include the trailing `/` as it may fail if it's missing.
- `--registration-token $REGISTRATION_TOKEN` is the Registration token from your Project on the aforementioned GitLab server.  
- `--executor shell` is telling the register command to utilize the shell for the execution.  
