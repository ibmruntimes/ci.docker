## Tools to build IBM® SDK, Java™ Technology Edition docker images and push updated images to the official repos.

Use the scripts in this dir to build or pull docker images and push updated images to the official repos. This works for the currently supported hardware architectures of x86\_64, s390x and ppc64le.

### Hardware architectures supported and Setup

Need the following setup to be in place on a local host to create/pull the docker images and push it to the official repos.

#### x86\_64

* Make sure that Docker is [installed](https://docs.docker.com/engine/installation).
* Since the x86\_64 docker images are auto-built on [hub.docker.com](https://hub.docker.com/r/dinogun/ij), we just pull the images from there and push it to the official [repo](https://hub.docker.com/r/ibmcom/ibmjava).

#### s390x

* Install [Docker](http://www.ibm.com/developerworks/linux/linux390/docker.html).
* The s390x docker images are built locally on a s390x LPAR and pushed to the official [repo](https://hub.docker.com/r/s390x/ibmjava).

#### ppc64le

* Install Docker. 
  * Ubuntu 16.04 is recommended. 
    ```console
    $ sudo apt-get install docker.io
    ```
  * on RHEL (7.x LE), you need to install it manually from [here](http://ftp.unicamp.br/pub/ppc64el/rhel/7_1/docker-ppc64el/).
* The ppc64le docker images are built locally on a ppc64le LPAR and pushed to the official [repo](https://hub.docker.com/r/ppc64le/ibmjava).

#### Unsupported architectures

* Currently i386 and s390 are not supported and the corresponding docker images are not available.

### Scripts Overview

#### build\_images.sh

* This script iterates through all the relevant Dockerfiles for the current hardware architecture and builds the corresponding Docker Images.

#### update\_images.sh

* This script pushes the Docker images to the official repos. Depending on the architecture, it can be used to pull down images from the source repo or check for the presence of the images locally.

#### cleanup\_images.sh

* This script removes all containers that have exited, all images that are not tagged and old versions of ibmjava images in anticipation of a full build.

See example script below to update the official repos.

```bash
#!/bin/bash

# Remove any old versions of the git repo and clone a fresh copy of the runtimes ci.docker repo.
git clone https://github.com/ibmruntimes/ci.docker.git

# Go to the tools dir.
pushd ci.docker/ibmjava/tools

# Login to DockerHub with the right userid
sudo docker login --username=userid

# Cleanup any old images, we will build everything fresh.
sudo ./cleanup_images.sh fclean

# Depending on the arch, build everything fresh !
# Skip this step for x86_64 arch.
sudo ./build_images.sh

# Push images to the target.
sudo ./update_repo.sh

popd
```
