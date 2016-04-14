#!/bin/sh

set -e

# This script takes a .jar file has an argument.
# The .jar file needs to be in a volume mounted at /opt/app
# docker run -it -v /path/on/host/system/jars:/opt/app ibmjava:latest foo.jar
for val in $*
do
	case $val in 
	*.jar)
		if [ ! -f /opt/app/$val ]; then
			echo "ERROR: Unable to find file /opt/app/$val"
			echo "Make sure that the .jar file is mounted in a data volume at /opt/app"
			ls -l /opt/app
			echo
			exit
		fi
		/opt/ibm/java/jre/bin/java -jar /opt/app/$val
		exit
		;;
	*)
		;;
	esac
done

# Run whatever the user wanted like "bash"
exec "$@"

# No .jar parameter passed, just print the javac version and exit
# /opt/ibm/java/jre/bin/java -version
# /opt/ibm/java/jre/bin/javac -version

# The following are -X options for optimizing IBM Java.

# Turn on shared class cache with size 50 MB
#/opt/ibm/java/jre/bin/java -Xshareclasses:name=sharedCC,cacheDir=/opt/ibm/java/cache,nonfatal,silent -Xscmx50M -version

# See link for more info on Shared class cache
# http://www-01.ibm.com/support/knowledgecenter/SSYKE2_8.0.0/com.ibm.java.lnx.80.doc/diag/appendixes/cmdline/Xshareclasses.html?lang=en

