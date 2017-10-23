# IBM® SDK for Node.js and Docker

Dockerfiles and build scripts for generating various Docker Images related to IBM® SDK for Node.js.

### Overview

The Docker images in this repository contain the IBM SDK for Node.js for Linux, which is based on Ubuntu. Version 4, 6, and 8 of the SDK are provided in the Docker image; these versions are based on the three latest LTS versions of Node.js. Version 6 is the default.

##### Architectures Supported

Docker Images for the following architectures are available:

-   x86_64
-   ppc64le
-   s390x

For any architecture, you can just
`docker pull ibmnode`

### License

The Dockerfiles and associated scripts are licensed under the [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).

Licenses for the IBM SDK for Node.js are installed within the image at `/usr/local/license`.

#### Issues

For issues relating specifically to this Docker image, please use the [GitHub issue tracker](https://github.com/ibmruntimes/ci.docker/issues).

For more general issues relating to the IBM® SDK for Node.js you can ask questions in the developerWorks forum: [IBM® SDK for Node.js](https://www.ibm.com/developerworks/community/groups/community/node#fullpageWidgetId=Wca143b2f9b91_4fc1_9180_94ad850643e2).
