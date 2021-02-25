#!/usr/bin/env bash

apt-get update
apt-get install -y --no-install-recommends apt-utils openjdk-8-jre-headless ca-certificates-java procps
apt-get update
apt-get install -y --no-install-recommends gpg net-tools curl dirmngr unzip
rm -rf /var/lib/apt/lists/*


HADOOP_VERSION=3.3.0
HADOOP_PREFIX=/opt/hadoop-${HADOOP_VERSION}
HADOOP_URL="https://www.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz"

# Setup env
#cat <<EOF > ~/.hadooprc
#JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
#HADOOP_VERSION=${HADOOP_VERSION}

#HADOOP_PREFIX=${HADOOP_PREFIX}
#HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}
#HADOOP_CLASSPATH=$HADOOP_CLASSPATH:/opt/hadoop-${HADOOP_VERSION}/share/hadoop/tools/lib/*
#HADOOP_CONF_DIR=/etc/hadoop
#export HADOOP_OPTIONAL_TOOLS="hadoop-azure,hadoop-azure-datalake,hadoop-aws"
#MULTIHOMED_NETWORK=1
#PATH=${HADOOP_PREFIX}/bin/:$PATH
#EOF
#. ~/.hadooprc
#echo ". ~/.hadooprc" >> ~/.bashrc

if [ ! -d "${HADOOP_PREFIX}" ]
then
  curl -fSL "$HADOOP_URL" -o /tmp/hadoop.tar.gz
  curl -fSL "$HADOOP_URL.asc" -o /tmp/hadoop.tar.gz.asc
  curl -fSL https://www.apache.org/dist/hadoop/common/KEYS -o KEYS
  gpg --import KEYS
  gpg --verify /tmp/hadoop.tar.gz.asc
  tar -xvf /tmp/hadoop.tar.gz -C /opt/ --exclude=hadoop-${HADOOP_VERSION}/share/doc
  rm /tmp/hadoop.tar.gz*
  ln -sf /opt/hadoop-${HADOOP_VERSION}/etc/hadoop /etc/hadoop
  #RUN cp /etc/hadoop/mapred-site.xml.template /etc/hadoop/mapred-site.xml
  mkdir -p /opt/hadoop-${HADOOP_VERSION}/logs
  mkdir -p /hadoop-data

  # Set up $JAVA_HOME for Hadoop.
  # This locates the JAVA_HOME and updates it in Hadoop's environment file.
  export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
  sed -i "s@# export JAVA_HOME=.*@export JAVA_HOME=${JAVA_HOME}@g" ${HADOOP_PREFIX}/etc/hadoop/hadoop-env.sh

fi


# Turn on Hadoop-AWS optional tools.
# We need this to be able to fetch s3://, s3a:// and s3n:// URIs.
sudo sed -i "s@# export HADOOP_OPTIONAL_TOOLS=.*@export HADOOP_OPTIONAL_TOOLS=\"hadoop-aws\"@g" ${HADOOP_PREFIX}/etc/hadoop/hadoop-env.sh

# Ask Hadoop to load the AWS SDK.
# This assumes '/root' is $HOME.
# If the default user in your Marathon is not 'root' (as it should be), change this to the home directory of that user.
cat <<EOF | sudo tee ~/.hadooprc
hadoop_add_to_classpath_tools hadoop-aws

EOF

# Add Hadoop to $PATH and customize a few parameters.
# $PATH is available inside each container sandbox, making fetcher work.
# HADOOP_HOME will be picked up by Mesos in place of the --hadoop-home agent flag.
cat <<EOF | sudo tee /etc/profile.d/A00-add-hadoop.sh
export PATH="$PATH:${HADOOP_PREFIX}/bin"
export HADOOP_HOME="${HADOOP_PREFIX}"
export HADOOP_LOG_DIR="${HADOOP_LOG_DIR}"
export HADOOP_ROOT_LOGGER=WARN,console

EOF

# Set up Hadoop executables to be discoverable for all users.
# This is so that just running 'hadoop' will work for everyone.
sudo sed -i -e "/ENV_SUPATH/ s[=.*[&:${HADOOP_PREFIX}/bin[" /etc/login.defs
sudo sed -i -e "/ENV_PATH/ s[=.*[&:${HADOOP_PREFIX}/bin[" /etc/login.defs

# Set up core-site.xml, set azure and Oracle settings
azureDatalakeName= ##########
azureDatalakeSecret = ############
azureContainer = ##########

oracleAccessKey = #########
oracleSecretKey = #########
oracleEndpoint = #########

cat <<EOF > /etc/hadoop/core-site.xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>abfs://${azureContainer}@${azureDatalakeName}.dfs.core.windows.net/</value>
  </property>
  <property>
    <name>fs.azure.account.auth.type.${azureDatalakeName}.dfs.core.windows.net</name>
    <value>SharedKey</value>
  </property>
  <property>
    <name>fs.azure.account.key.${azureDatalakeName}.dfs.core.windows.net</name>
    <value>${azureDatalakeSecret}</value>
  </property>
  <property>
    <name>fs.azure.createRemoteFileSystemDuringInitialization</name>
    <value>true</value>
  </property>

  <property>
    <name>fs.s3a.access.key</name>
    <value>${oracleAccessKey}</value>
  </property>
  <property>
    <name>fs.s3a.secret.key</name>
    <value>${oracleSecretKey}</value>
  </property>
  <property>
    <name>fs.s3a.endpoint</name>
    <value>${oracleEndpoint}</value>
  </property>
  <property>
    <name>fs.s3a.path.style.access</name>
    <value>true</value>
  </property>
  <property>
    <name>fs.s3a.paging.maximum</name>
    <value>1000</value>
  </property>

  <property>
    <name>fs.oci.client.hostname</name>
    <value>https://objectstorage.us-ashburn-1.oraclecloud.com</value>
  </property>
  <property>
    <name>fs.oci.client.hostname.trustford-objectstore.idr4rwcctgzw</name>
    <value>https://objectstorage..eu-amsterdam-1oraclecloud.com</value><!-- Use Phoenix for myBucket@myNamespace -->
  </property>
  <property>
    <name>fs.oci.client.auth.tenantId</name>
    <value>ocid1.tenancy.oc1..######</value>
  </property>
  <property>
    <name>fs.oci.client.auth.userId</name>
    <value>ocid1.user.oc1..############</value>
  </property>
  <property>
    <name>fs.oci.client.auth.fingerprint</name>
    <value>###########</value>
  </property>
  <property>
    <name>fs.oci.client.auth.pemfilepath</name>
    <value>~/.oci/oci_api_key.pem</value>
  </property>

</configuration>
EOF

# You can now access the ABFS filesystem on this URL from any of the HDFS nodes:
#
# abfs://<container>@<StorageAccountName>.dfs.core.windows.net/
#
# And Oracle s3 bucket at:
# s3a://bucketname/path