# ===============================================================================
# Jenkins Server + Docker base
#
# https://registry.hub.docker.com/_/jenkins/
# http://www.jayway.com/2015/03/14/docker-in-docker-with-jenkins-and-supervisord/
# ===============================================================================

FROM jenkins:latest
MAINTAINER Inaki Anduaga <inaki@inakianduaga.com>

# Switch user to root so that we can install apps (jenkins image switches to user "jenkins" in the end)
USER root

# Install Docker prerequisites
RUN apt-get update -qq && apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
	lxc \
	supervisor

# Create log folder for supervisor, jenkins and docker
RUN mkdir -p /var/log/supervisor
RUN mkdir -p /var/log/docker
RUN mkdir -p /var/log/jenkins

# Install Docker from Docker Inc. repositories.
# We also need app-armor dependency: http://www.tekhead.org/blog/2014/09/installing-docker-on-ubuntu-quick-fix/
RUN echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list \
  && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9 \
  && apt-get update -qq \
  && apt-get install -qqy lxc-docker apparmor

# Add jenkins user to the docker groups so that the jenkins user can run docker without sudo
RUN gpasswd -a jenkins docker

# More jenkins configuration
ENV JENKINS_HOME /var/jenkins_home

# Jenkins home directoy is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME /var/jenkins_home


# ===============================================================================
# Nginx server
#
# https://github.com/dockerfile/nginx
# ===============================================================================

#
# installation
# https://github.com/docker/docker/issues/5383
#
RUN echo "deb http://nginx.org/packages/debian/ wheezy nginx" >> /etc/apt/sources.list.d/nginx.list
RUN apt-key adv --fetch-keys "http://nginx.org/keys/nginx_signing.key"
RUN apt-get update
RUN apt-get -y install nginx
RUN chown -R www-data:www-data /etc/nginx

#
# Configuration
#
COPY conf/nginx/sites-available/jenkins.conf /etc/nginx/sites-enabled/default
COPY conf/nginx/jenkins                      /etc/nginx/jenkins
COPY conf/nginx/nginx.conf                   /etc/nginx/nginx.conf
COPY conf/nginx/mime.types                   /etc/nginx/mime.types
COPY conf/nginx/envvars                      /etc/nginx/envvars

# Run without daemon: http://stackoverflow.com/questions/18861300/how-to-run-nginx-within-docker-container-without-halting
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf

# add certificates
COPY conf/nginx/certificates /etc/nginx

# Expose ports nginx listens to
EXPOSE 80 443


# ===============================================================================
# Startup / Supervisor
# ===============================================================================
#
# Supervisor startup scripts (also includes nginx)
#
ADD conf/supervisor/ /etc/supervisor/conf.d/
ADD scripts/ /scripts/
RUN chmod 755 /scripts/*.sh

# Default command
CMD ["/scripts/start.sh"]


# ===============================================================================
# Debugging
# ===============================================================================

#
# Access terminal displayed when logged into container through bash
#
ENV TERM xterm

#
# Text editor
#
RUN apt-get install -y nano