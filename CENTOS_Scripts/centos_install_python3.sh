#!/usr/bin/env bash
cd /tmp

# update Conda to current
sudo ./usr/anaconda3/bin/conda update -n conda

export PYTHON_FILE="Python-3.6.5.tgz"
export PYTHON_FILE_UNZIP="Python-3.6.5"
export PYTHON_URL="https://www.python.org/ftp/python/"
export PYTHON_LOCATION="Python-3.6.5"
export PYTHON_VERSION="3.6.5"
export PYTHON_HOME=/usr/local/$PYTHON_LOCATION
echo "PYTHON_HOME=\"${PYTHON_HOME}\"" >> /etc/environment
export PYTHON_SHA256=53a3e17d77cd15c5230192b6a8c1e031c07cd9f34a2f089a731c6f6bd343d5c6

# download PYTHON with SHA check (This is important)
yum install wget unzip bzip2 gcc zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel expat-devel -y \
&& wget -c -O "$PYTHON_FILE" --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "$PYTHON_URL$PYTHON_VERSION/$PYTHON_FILE" \
&& echo "$PYTHON_SHA256 $PYTHON_FILE" | shasum -a 256 - \
&& tar -xvzf $PYTHON_FILE \
&& mkdir -p $PYTHON_HOME \
&& mv -f $PYTHON_FILE_UNZIP/* $PYTHON_HOME \
&& rm -f $PYTHON_FILE \
&& rm -rf $PYTHON_FILE_UNZIP

#configure Python
cd $PYTHON_HOME 
sudo ./configure --prefix=/usr/local --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib"
sudo make && make altinstall

exit 0
