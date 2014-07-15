#!/bin/bash

exec 2>&1
set -e
set -x

git clone https://github.com/odoo/odoo.git /opt/odoo -b master --depth=15
cd /opt/odoo
git fetch origin 7.0:7.0 --depth=15
git fetch origin 8.0:8.0 --depth=15
git checkout 8.0 # TODO really required?
#TODO OCB branches
