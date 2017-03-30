# Pushing a Java Tomcat application built using Maven to IBM Containers on Bluemix.

This consists of an example Java web application based on tomcat that is available on github. The sources are downloaded and built using the IBM Maven Docker image and then packaged with an IBM Java sfj-alpine Docker image. This image is then pushed to IBM Containers on Bluemix. 

### Overview

This demo indicates the use of two IBM provided Docker images available on hub.docker.com and how they can be incorporated into the everyday process that is followed by a developer to push application updates to the cloud.

* [IBM® SDK, Java™ Technology Edition, Version 8, SFJ package](https://hub.docker.com/r/ibmcom/ibmjava/tags/)
* [Apache Maven Image with IBM Java](https://hub.docker.com/r/ibmcom/ibmjava/tags/)

#### Small Footprint JRE

The Small Footprint JRE ([SFJ](http://www.ibm.com/support/knowledgecenter/en/SSYKE2_8.0.0/com.ibm.java.lnx.80.doc/user/small_jre.html)) is designed specifically for web developers who want to develop and deploy cloud-based Java applications. Java tools and functions that are not required in the cloud environment, such as the Java control panel, are removed. The runtime environment is stripped down to provide core, essential function that has a greatly reduced disk and memory footprint.

##### Alpine Linux

Consider using [Alpine Linux](http://alpinelinux.org/) if you are concerned about the size of the overall image. Alpine Linux is a stripped down version of Linux that is based on [musl glibc](http://wiki.musl-libc.org/wiki/Functional_differences_from_glibc) and Busybox, resulting in a [Docker image](https://hub.docker.com/_/alpine/) size of approximately 5 MB. Due to its extremely small size and reduced number of installed packages, it has a much smaller attack surface which improves security. However, because the IBM SDK has a dependency on gnu glibc, installing this library adds an extra 8 MB to the image size.

##### Size comparison of the various Java packages.

```console
ibmcom/ibmjava   8-maven             5c3c8936f41c        5 days ago          376.9 MB
ibmcom/ibmjava   8-jre               d239d0beeee7        5 days ago          309.9 MB
ibmcom/ibmjava   8-sfj               6a31e424a59a        5 days ago          227.1 MB
ibmcom/ibmjava   8-jre-alpine        06ee538632b2        5 days ago          183.8 MB
ibmcom/ibmjava   8-sfj-alpine        81ac3b9476a3        5 days ago          101.2 MB
```

#### Apache Maven Docker Image with IBM Java

This image provides [Apache Maven](http://apache.osuosl.org/maven/maven-3/3.3.9/binaries/) installed on top of the IBM Java SDK Docker image.


#### Creating the application Docker image

The script `build-app.sh` does the following

* Clones the latest application sources from the github repo.
* Build the application using the Maven image and package the same.
* Create a Docker image with the sfj-alpine image and the above built package with the Dockerfile provided.
* Push the image to Bluemix.
