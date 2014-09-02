#!/bin/bash

exec 2>&1
set -e
set -x

cat > /etc/apt/sources.list <<EOF
deb http://archive.ubuntu.com/ubuntu trusty main
deb http://archive.ubuntu.com/ubuntu trusty-security main
deb http://archive.ubuntu.com/ubuntu trusty-updates main
deb http://archive.ubuntu.com/ubuntu trusty universe
EOF

apt-get update
apt-get install -y --force-yes python-software-properties
apt-get install -y --force-yes software-properties-common
apt-add-repository ppa:chris-lea/node.js


apt-get install -y --force-yes wget
wget http://launchpadlibrarian.net/153428081/libicu48_4.8.1.1-12ubuntu2_amd64.deb
dpkg -i libicu48_4.8.1.1-12ubuntu2_amd64.deb
wget https://launchpad.net/~irie/+archive/ubuntu/boost/+build/3978677/+files/libboost-date-time1.49.0_1.49.0-3.1ubuntu1irie1~precise1_amd64.deb
dpkg -i libboost-date-time1.49.0_1.49.0-3.1ubuntu1irie1~precise1_amd64.deb
wget http://cz.archive.ubuntu.com/ubuntu/pool/main/libc/libcmis/libcmis-0.3-3_0.3.1-1ubuntu2_amd64.deb
dpkg -i libcmis-0.3-3_0.3.1-1ubuntu2_amd64.deb

apt-add-repository ppa:libreoffice/libreoffice-4-1
echo "deb http://ppa.launchpad.net/libreoffice/libreoffice-4-1/ubuntu raring main" >> /etc/apt/sources.list
apt-get update
apt-get install -y --force-yes libreoffice-common=1:4.1.4~rc2-0ubuntu1~raring1~ppa1
apt-get install -y --force-yes libreoffice-core=1:4.1.4~rc2-0ubuntu1~raring1~ppa1
apt-get install -y --force-yes python-uno


xargs apt-get install -y --force-yes < packages.txt
sudo pip install -r requirements.txt
sudo pip install https://github.com/aricaldeira/pyxmlsec/archive/master.zip
sudo pip install https://github.com/aricaldeira/geraldo/archive/master.zip

cd /
rm -rf /var/cache/apt/archives/*.deb
rm -rf /var/lib/apt/lists/*
rm -rf /root/*
rm -rf /tmp/*

apt-get clean


# remove SUID and SGID flags from all binaries
function pruned_find() {
  find / -type d \( -name dev -o -name proc \) -prune -o $@ -print
}

pruned_find -perm /u+s | xargs -r chmod u-s
pruned_find -perm /g+s | xargs -r chmod g-s

# remove non-root ownership of files
chown root:root /var/lib/libuuid

# display build summary
set +x
echo -e "\nRemaining suspicious security bits:"
(
  pruned_find ! -user root
  pruned_find -perm /u+s
  pruned_find -perm /g+s
  pruned_find -perm /+t
) | sed -u "s/^/  /"

echo -e "\nInstalled versions:"
(
  git --version
  ruby -v
  python -V
) | sed -u "s/^/  /"

echo -e "\nSuccess!"
exit 0
