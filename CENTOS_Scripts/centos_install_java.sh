#!/usr/bin/env bash

cd /tmp

export JCE_FILE="jce_policy-8.zip"
export JCE_URL="http://download.oracle.com/otn-pub/java/jce/8/"

export JAVA_LOCATION="jdk1.8.0_131"
export JAVA_FILE="jdk-8u131-linux-x64.rpm"
export JAVA_URL="http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/"
export JAVA_HOME=/usr/java/$JAVA_LOCATION
# 121 Checksum ENV JAVA_SHA256=bd9f42e0725b32391c72f2800cdbb8a0c7db0ab2429b5f9e5bcf14b0090470a2
export JAVA_SHA256=3d1e8cc66f4fd77acef6093329d5dd95bd06e4a03926c52df794f311a0c093f8
# Get the SHA256 from https://www.oracle.com/webfolder/s/digest/8u131checksum.html

# install java with SHA check (This is important)
yum install wget unzip -y \
&& wget -c -O "$JAVA_FILE" --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "$JAVA_URL$JAVA_FILE" \
&& echo "$JAVA_SHA256 $JAVA_FILE" | sha256sum -c - \
&& yum localinstall jdk-*.rpm -y \
&& rm -f jdk-*.rpm \
&& wget -c -O "$JCE_FILE" --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "$JCE_URL$JCE_FILE" \
&& unzip jce_policy-8.zip \
&& rm jce_policy-8.zip \
&& mv --force --verbose --backup --suffix=bak ./UnlimitedJCEPolicyJDK8/*.jar /usr/java/$JAVA_LOCATION/jre/lib/security/ \
&& rm -rf ./UnlimitedJCEPolicyJDK8

# Fix alternatives
/usr/sbin/alternatives --install "/usr/bin/java" "java" "/usr/java/default/bin/java" 2 \
--slave /usr/bin/javac javac /usr/java/default/bin/javac \
--slave /usr/bin/javadoc javadoc /usr/java/default/bin/javadoc \
--slave /usr/bin/jar jar /usr/java/default/bin/jar \
--slave /usr/bin/keytool keytool /usr/java/default/bin/keytool \
--slave /usr/bin/orbd orbd /usr/java/default/bin/orbd \
--slave /usr/bin/pack200 pack200 /usr/java/default/bin/pack200 \
--slave /usr/bin/rmid rmid /usr/java/default/bin/rmid \
--slave /usr/bin/rmiregistry rmiregistry /usr/java/default/bin/rmiregistry \
--slave /usr/bin/servertool servertool /usr/java/default/bin/servertool \
--slave /usr/bin/tnameserv tnameserv /usr/java/default/bin/tnameserv \
--slave /usr/bin/unpack200 unpack200 /usr/java/default/bin/unpack200

ln -sf /etc/alternatives/java /usr/bin/java \
&& rm -f /usr/bin/java && rm -f /var/lib/alternatives/java && alternatives --install /usr/bin/java java /usr/java/$JAVA_LOCATION/bin/java 20000 \
&& rm -f /usr/bin/jar && rm -f /var/lib/alternatives/jar && alternatives --install /usr/bin/jar jar /usr/java/$JAVA_LOCATION/bin/jar 20000 \
&& rm -f /usr/bin/javac && rm -f /var/lib/alternatives/javac && alternatives --install /usr/bin/javac javac /usr/java/$JAVA_LOCATION/bin/javac 20000 \
&& rm -f /usr/bin/javaws && rm -f /var/lib/alternatives/javaws && alternatives --install /usr/bin/javaws javaws /usr/java/$JAVA_LOCATION/bin/javaws 20000 \
&& alternatives --set java /usr/java/$JAVA_LOCATION/bin/java \
&& alternatives --set jar /usr/java/$JAVA_LOCATION/bin/jar \
&& alternatives --set javac /usr/java/$JAVA_LOCATION/bin/javac \
&& alternatives --set javaws /usr/java/$JAVA_LOCATION/bin/javaws