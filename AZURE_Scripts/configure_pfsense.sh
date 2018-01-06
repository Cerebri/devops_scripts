#! /bin/sh

# After installation, log in and choose:
#  14) to enable sshd
#  8) to login shell

pkg upgrade

pkg install -y python27 py27-setuptools bash git sudo
ln -s /usr/local/bin/python2.7 /usr/bin/python

echo 'ifconfig_hn0="SYNCDHCP"' >> /etc/rc.conf
echo 'boot_multicons="YES"' >> /boot/loader.conf.local
echo 'boot_serial="YES"' >> /boot/loader.conf.local
echo 'console="comconsole,vidconsole"' >> /boot/loader.conf.local
echo 'comconsole_speed="115200"' >> /boot/loader.conf.local
echo 'udf_load="YES"'  >> /boot/loader.conf
echo 'vfs.mountroot.timeout=300'  >> /boot/loader.conf
echo 'legal.intel_ipw.license_ack=1' >> /boot/loader.conf
echo 'legal.intel_iwi.license_ack=1' >> /boot/loader.conf
curl -O https://raw.githubusercontent.com/Cerebri/devops_scripts/master/AZURE_Scripts/udf.ko
mv udf.ko /boot/kernel/
chmod 0555 /boot/kernel/udf.ko

git clone https://github.com/Azure/WALinuxAgent.git
cd WALinuxAgent
git checkout v2.2.14
python setup.py install
ln -sf /usr/local/sbin/waagent /usr/sbin/waagent
ln -sf /usr/local/sbin/waagent2.0 /usr/sbin/waagent2.0
curl -O https://raw.githubusercontent.com/Cerebri/devops_scripts/master/AZURE_Scripts/waagent.sh
mv waagent.sh /usr/local/etc/rc.d/
#echo '#! /bin/sh' >> /usr/local/etc/rc.d/waagent.sh
#echo '/usr/local/sbin/waagent --daemon' >> /usr/local/etc/rc.d/waagent.sh
chmod +x /usr/local/etc/rc.d/waagent.sh
echo "y" |  /usr/local/sbin/waagent -deprovision+user
echo  'waagent_enable="YES"' >> /etc/rc.conf
