#!/usr/bin/env bash
cd /tmp

export SPARK_FILE="spark-2.2.0-bin-hadoop2.7.tgz"
export SPARK_FILE_UNZIP="spark-2.2.0-bin-hadoop2.7"
export SPARK_URL="https://d3kbcqa49mib13.cloudfront.net/"
export SPARK_LOCATION="spark-2.2.0"
export SPARK_HOME=/usr/local/$SPARK_LOCATION
echo "SPARK_HOME=\"${SPARK_HOME}\"" >> /etc/environment
export SPARK_SHA256=97fd2cc58e08975d9c4e4ffa8d7f8012c0ac2792bcd9945ce2a561cf937aebcc
# https://spark.apache.org/downloads.html

# download SPARK with SHA check (This is important)
yum install wget unzip bzip2 -y \
&& wget -c -O "$SPARK_FILE" --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "$SPARK_URL$SPARK_FILE" \
&& echo "$SPARK_SHA256 $SPARK_FILE" | shasum -a 256 - \
&& tar -xvzf $SPARK_FILE \
&& mkdir -p $SPARK_HOME \
&& mv -f $SPARK_FILE_UNZIP/* $SPARK_HOME \
&& rm -f $SPARK_FILE \
&& rm -rf $SPARK_FILE_UNZIP

#install
cd $SPARK_HOME
sudo bin/pyspark

exit 0