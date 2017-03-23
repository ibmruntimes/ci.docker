FROM ibmjava:8-sfj-alpine

ADD java-tomcat-example-app /opt/app

WORKDIR /opt/app

# Set IBM Java specific options to ensure the best Bluemix experience
ENV JAVA_OPTS="-Xtune:virtualized"

CMD ["sh","target/bin/webapp"]
