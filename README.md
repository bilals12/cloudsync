# cloudsync

this little tool gets your environment set up with aws + docker without any hard work. 

## how does it work?
1. **detects your os**: script figures out what OS you're on, linux or mac. i've just added support for the ARM architecture.
2. **sets up a home for cloudsync**: creates a directory called "cloudsync".
3. **installs aws cli**: downloads and installs aws cli if it's missing from your machine.
4. **aws creds from environment**: have your aws creds ready in the form of environment variables (more secure than hardcoding them into the script)
5. **docker login and image pull**: you will also need the url of the docker image you want to pull. the script logs into aws ecr and pulls the image for you.
6. **docker-compose ready**: if there's no `docker-compose.yml`, the script will create one. it's a blank canvas for you to define your docker services however you want.
7. **spins up the services**: the script then fires up all the services armed with docker-compose.

## usage
1. **keep your aws creds ready**: make sure you've exported your aws access key id and secret access key as environment variables.
2. **run the script**: execute the script with the docker image url as an arg

```bash
chmod +x cloudsync.sh
./cloudsync.sh <docker_image_url>
```