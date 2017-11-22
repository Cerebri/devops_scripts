#!/usr/bin/env bash

# Storage Account ID
export ACCOUNT_ID=$1
# Storage Account key
export ACCOUNT_KEY=$2

if [[ ! -d "/data" ]]; then
	apt-get install samba-client samba-common cifs-utils -y
	mkdir -p /data
	mkdir -p /scratch
	mkdir -p /jupyter-notebooks

	# Mount directories here
	mount -t cifs //$ACCOUNT_ID.file.core.windows.net/sftpdata /data -o vers=3.0,username=$ACCOUNT_ID,password=$ACCOUNT_KEY,dir_mode=0555,file_mode=0444,uid=dev,gid=dev
	echo "//$ACCOUNT_ID.file.core.windows.net/sftpdata    /data    cifs    vers=3.0,username=$ACCOUNT_ID,password=$ACCOUNT_KEY,dir_mode=0555,file_mode=0444,uid=dev,gid=dev 0 0" >> /etc/fstab

	mount -t cifs //$ACCOUNT_ID.file.core.windows.net/scratch /scratch -o vers=3.0,username=$ACCOUNT_ID,password=$ACCOUNT_KEY,dir_mode=0777,file_mode=0777,uid=dev,gid=dev
	echo "//$ACCOUNT_ID.file.core.windows.net/scratch    /scratch    cifs    vers=3.0,username=$ACCOUNT_ID,password=$ACCOUNT_KEY,dir_mode=0777,file_mode=0777,uid=dev,gid=dev 0 0" >> /etc/fstab

	mount -t cifs //$ACCOUNT_ID.file.core.windows.net/jupyter-notebooks /jupyter-notebooks -o vers=3.0,username=$ACCOUNT_ID,password=$ACCOUNT_KEY,dir_mode=0777,file_mode=0777,uid=dev,gid=dev
	echo "//$ACCOUNT_ID.file.core.windows.net/jupyter-notebooks    /jupyter-notebooks    cifs    vers=3.0,username=$ACCOUNT_ID,password=$ACCOUNT_KEY,dir_mode=0777,file_mode=0777,uid=dev,gid=dev 0 0" >> /etc/fstab

fi

cd /tmp

export ANACONDA_LOCATION="anaconda2"
export ANACONDA_FILE="Anaconda2-5.0.1-Linux-x86_64.sh"
export ANACONDA_URL="https://repo.continuum.io/archive/"
export ANACONDA_HOME=/usr/$ANACONDA_LOCATION
echo "ANACONDA_HOME=\"${ANACONDA_HOME}\"" >> /etc/environment
export ANACONDA_SHA256=23c676510bc87c95184ecaeb327c0b2c88007278e0d698622e2dd8fb14d9faa4
# Get the SHA256 from https://docs.anaconda.com/anaconda/install/hashes/lin-2-64

# install anaconda with SHA check (This is important)
apt-get install wget unzip bzip2 -y \
&& wget -c -O "$ANACONDA_FILE" --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "$ANACONDA_URL$ANACONDA_FILE" \
&& echo "$ANACONDA_SHA256 $ANACONDA_FILE" | sha256sum -c - \
&& bash $ANACONDA_FILE -b -p $ANACONDA_HOME -f \
&& rm -f $ANACONDA_FILE

# Fix so that users can find this first (Users get PATH=/usr/lib64/qt-3.3/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/spark/.local/bin:/home/spark/bin)
# So the link in /usr/local/bin gets found before /bin or /usr/bin
# root does not have /usr/local/bin so yum keeps working for it
ln -sf $ANACONDA_HOME/bin/python /usr/local/bin/python

# Add anaconda bin to end of dev users path so conda is easy to access
echo "export PATH=$PATH:/usr/anaconda2/bin" >> /home/dev/.bashrc

# Install dependencies for sparkmagic
apt-get install gcc libkrb5-dev -y

# Install sparkmagic kernels for jupyter
$ANACONDA_HOME/bin/pip install sparkmagic

cd $($ANACONDA_HOME/bin/pip show sparkmagic | grep Location | cut -f2 -d":")

$ANACONDA_HOME/bin/jupyter-kernelspec install sparkmagic/kernels/sparkkernel
$ANACONDA_HOME/bin/jupyter-kernelspec install sparkmagic/kernels/pysparkkernel
$ANACONDA_HOME/bin/jupyter-kernelspec install sparkmagic/kernels/pyspark3kernel
$ANACONDA_HOME/bin/jupyter-kernelspec install sparkmagic/kernels/sparkrkernel

$ANACONDA_HOME/bin/jupyter nbextension enable --py --sys-prefix widgetsnbextension

exit 0
