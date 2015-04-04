MAINTAINER Inaki Anduaga <inaki@inakianduaga.com>

# ===============================================================================
# Jenkins Server
#
# https://github.com/cloudbees/jenkins-ci.org-docker/blob/master/Dockerfile
# ===============================================================================

FROM java:openjdk-7u65-jdk

RUN apt-get update && \
    apt-get install -y wget git curl zip && \
    rm -rf /var/lib/apt/lists/*

ENV JENKINS_HOME /var/jenkins_home

#
# Flag commands as non-interactive
#
ENV DEBIAN_FRONTEND=noninteractive

# Jenkins is ran with user `jenkins`, uid = 1000
# If you bind mount a volume from host/volume from a data container,
# ensure you use same uid
RUN useradd -d "$JENKINS_HOME" -u 1000 -m -s /bin/bash jenkins

# Jenkins home directoy is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME /var/jenkins_home

# `/usr/share/jenkins/ref/` contains all reference configuration we want
# to set on a fresh new installation. Use it to bundle additional plugins
# or config file with your custom jenkins Docker image.
RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d

COPY conf/jenkins/init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-angent-port.groovy

ENV JENKINS_VERSION 1.596.1

# could use ADD but this one does not check Last-Modified header
# see https://github.com/docker/docker/issues/8331
RUN curl -L http://mirrors.jenkins-ci.org/war-stable/1.596.1/jenkins.war -o /usr/share/jenkins/jenkins.war

ENV JENKINS_UC https://updates.jenkins-ci.org
RUN chown -R jenkins "$JENKINS_HOME" /usr/share/jenkins/ref

# Update: We'll proxy it through nginx
# for main web interface:
# EXPOSE 8080

# will be used by attached slave agents:
EXPOSE 50000

USER jenkins

# from a derived Dockerfile, can use `RUN plugin.sh active.txt` to setup /usr/share/jenkins/ref/plugins from a support bundle
COPY conf/jenkins/plugins.sh /usr/local/bin/plugins.sh


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
# Nginx server
#
# https://github.com/dockerfile/nginx
# ===============================================================================

#
# installation
# https://github.com/docker/docker/issues/5383
#
RUN \
  sudo apt-get update && \
  apt-get -y install software-properties-common && \
  add-apt-repository -y ppa:nginx/stable && \
  apt-get update && \
  apt-get install -y nginx && \
  #rm -rf /var/lib/apt/lists/* && \
  chown -R www-data:www-data /var/lib/nginx

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
# Debugging
# ===============================================================================

#
# Access terminal displayed when logged into container through bash
#
ENV TERM xterm

#
# Text editor
#
RUN sudo apt-get install -y nano