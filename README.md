# jenkins_docker
Jenkins running in a Docker container  
You will need to create your own image.  I suggest using a local registry.  You can see my steps to create a local Portainer Web GUI which has steps to create your own local registry and how to use it.  https://github.com/WingsLikeEagles/Docker_Portainer_setup  

# The Dockerfile needs to be built
`docker built -t localhost:5000/myjenkins:2.277.4-lts .`  

# Push it to the local registry
`docker push localhost:5000/myjenkins:2.277.4-lts`

# Create a volume to store the config
`docker volume create jenkins_home`

# Run it
`docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v jenkins_home:/var/jenkins_home -p 8080:8080 --name jenkins localhost:myjenkins:2.277.4-lts`

# Password
When I tried to log in for the first time the admin account password was not displayed in the console.  This was annoying.  I found that I needed to do the following:  
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
