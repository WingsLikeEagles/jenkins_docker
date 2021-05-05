# jenkins_docker
Jenkins running in a Docker container  
You will need to create your own image.  I suggest using a local registry.  You can see my steps to create a local Portainer Web GUI which has steps to create your own local registry and how to use it.  https://github.com/WingsLikeEagles/Docker_Portainer_setup  

# The Dockerfile needs to be built
docker built -t localhost:5000/myjenkins:2.277.4-lts .  

# Push it to the local registry
docker push localhost:5000/myjenkins:2.277.4-lts

# Create a volume to store the config
docker volume create jenkins_home

# Run it
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v jenkins_home:/var/jenkins_home -p 8080:8080 --name jenkins localhost:myjenkins:2.277.4-lts

# Password
When I tried to log in for the first time the admin account password was not displayed in the console.  This was annoying.  I found that I needed to do the following:  
1. set the /var/jenkins_home/config.xml line "useSecurity" to "false"
2. Go into the Web GUI.
3. On the Dashboard click on "Manage Jenkins"
4. Select "Configure Global Security"
5. Select "Security Realm" to "Jenkins' own user database", and check the box next to "Allow uers to sign up".
6. Click "Save" at the bottom.
7. Create a new account by clicking on "Sign Up" in the upper right corner and entering the requested info.
8. Set the "useSecurity" back to "true"
  a. docker exec -it jenkins /bin/bash
  b. sed -i 's/useSecurity>false</useSecurity>true</g' /var/jenkins_home/config.xml
  c. exit
8. Stop and Restart container:
  a. docker stop jenkins
  b. docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v jenkins_home:/var/jenkins_home -p 8080:8080 --name jenkins localhost:myjenkins:2.277.4-lts
9. Open the Web Gui (http://localhost:8080) and sign in with your new user account
10. Change authorization to only allow logged in users to make changes to the system:
  a. On the Dashboard click on "Manage Jenkins"
  b. Select "Configure Global Security"
  c. Under "Authorization" select "Logged-in users can do anything"
  d. Click "Save" at the bottom.
11. Log out, and log back in to verify
12. You may want to delete the initial user "jenkins_admin" that was created during the install
