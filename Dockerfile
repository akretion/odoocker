FROM ubuntu:trusty
MAINTAINER rvalyi "rvalyi@akretion.com"

RUN mkdir /tmp/build
ADD ./stack/ /tmp/build
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive cd /tmp/build && ./cedar.sh
RUN rm -rf /tmp/build
RUN adduser --disabled-password --home=/ --gecos "" odoo
USER odoo
