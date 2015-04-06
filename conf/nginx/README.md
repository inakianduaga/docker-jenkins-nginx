Nginx Jenkins
=============

> Nginx configuration based on Nginx Server Configs boilerplate
> Proxies all http/https requests to the Jenkins server

## Folder structure

- `./certificates/` : ssl certificate/certificate_key goes here, with names `cert.crt`, `cert.key`
- `./jenkins/` : jenkins configuration includes
- `./nginx.conf`: Main nginx server configuration

## Reference

https://wiki.jenkins-ci.org/display/JENKINS/Running+Jenkins+behind+Nginx
https://www.digitalocean.com/community/tutorials/how-to-configure-nginx-with-ssl-as-a-reverse-proxy-for-jenkins

## [Nginx Server Configs](https://github.com/h5bp/server-configs-nginx)

**Nginx Server Configs** is a collection of configuration snippets that can help
your server improve the web site's performance and security, while also
ensuring that resources are served with the correct content-type and are
accessible, if needed, even cross-domain.

### Documentation

The [documentation](doc/TOC.md) is bundled with
the project, which makes it readily available for offline reading and provides a
useful starting point for any documentation you want to write about your project.