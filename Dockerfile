FROM jenkins/jenkins:2.277.4-lts
USER root
RUN groupadd -g 999 docker; usermod -aG $(cat /etc/group | grep docker: | cut -d: -f3) jenkins
RUN curl -sSL https://get.docker.com/ |sh
USER jenkins
