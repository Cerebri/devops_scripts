#!/usr/bin/env bash

cd /tmp

export ANACONDA_LOCATION="anaconda2"
export ANACONDA_FILE="Anaconda2-4.3.1-Linux-x86_64.sh"
#export ANACONDA_FILE="Anaconda2-5.0.1-Linux-x86_64.sh"
export ANACONDA_URL="https://repo.continuum.io/archive/"
export ANACONDA_HOME=/usr/$ANACONDA_LOCATION
echo "ANACONDA_HOME=\"${ANACONDA_HOME}\"" >> /etc/environment
export ANACONDA_SHA256=e9b8f2645df6b1527ba56d61343162e0794acc3ee8dde2a6bba353719e2d878d
#export ANACONDA_SHA256=23c676510bc87c95184ecaeb327c0b2c88007278e0d698622e2dd8fb14d9faa4
# Get the SHA256 from https://docs.anaconda.com/anaconda/install/hashes/lin-2-64

# install anaconda with SHA check (This is important)
yum install wget unzip bzip2 -y \
&& wget -c -O "$ANACONDA_FILE" --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "$ANACONDA_URL$ANACONDA_FILE" \
&& echo "$ANACONDA_SHA256 $ANACONDA_FILE" | sha256sum -c - \
&& bash $ANACONDA_FILE -b -p $ANACONDA_HOME -f \
&& rm -f $ANACONDA_FILE

# Fix so that users can find this first (Users get PATH=/usr/lib64/qt-3.3/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/spark/.local/bin:/home/spark/bin)
# So the link in /usr/local/bin gets found before /bin or /usr/bin
# root does not have /usr/local/bin so yum keeps working for it
ln -sf $ANACONDA_HOME/bin/python /usr/local/bin/python

exit 0