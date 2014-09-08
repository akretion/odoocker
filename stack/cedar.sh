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

xargs apt-get install -y --force-yes < packages.txt
pip install setuptools --upgrade
wget https://raw.githubusercontent.com/rvalyi/voodoo-image/master/requirements.txt
sudo pip install -r requirements.txt
wget -O- https://gist.githubusercontent.com/rvalyi/fb2f76ef3ed07d796771/raw/76822a8acd679dcb12465a23cc808b22f13fd981/gistfile1.txt | sh
wget -O- https://gist.githubusercontent.com/rvalyi/19a759ca0ee1fe24fb52/raw/b01dc47e9793eeb0db24ae64ae889ce214fbc978/gistfile1.txt | sh

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
