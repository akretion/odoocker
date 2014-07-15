FROM rvalyi/odoocker
MAINTAINER rvalyi "rvalyi@akretion.com"

RUN mkdir /tmp/build
ADD . /tmp/build
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive cd /tmp/build && ./odoo_src.sh
RUN rm -rf /tmp/build
