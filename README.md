Jenkins-Nginx
=============

> Docker build for running a jenkins server behind nginx (w/ google oAuth as authentication)

## Container setup

### Supervisor

The docker container will run the supervisor daemon on startup (through `/scripts/start.sh`). 
Supervisor will start all processes as defined in `./conf/supervisor`, which includes `jenkins server` and `nginx`

### Nginx variables

The nginx variables are dynamically populated upon container startup. The list of variables populated is inside `/scripts/nginx_env.sh`.
These allow the nginx configuration to be dynamically populated at run time, so proxy endpoints for example can be modified dynamically.
See [run](#Run) example below for how to pass an env file on run time.
 
### Nginx Configuration

See [the nginx config readme](conf/nginx/README.md) for more details


## Managing & running containers

### Build

Inside any of the subcontainers, run

`docker build -t jenkins-nginx ./`

where -t is the tag name we give the container

### Run

To run the container, execute

`docker run -d -p 80:80 -p 443:443 -v ~/jenkins_home:/var/jenkins_home --env-file ~/.jenkins_env jenkins-nginx`

- `-p` here is binding to the usual 80/443 ports
- `-v` param maps internal jenkins_home volume to a folder on host.
- `--env-file` sources the environment variables from the provided file
