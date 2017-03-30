FROM gliderlabs/herokuish

# Ensure UTF-8 locale
RUN echo "LANG=\"en_US.UTF-8\"" > /etc/default/locale
RUN locale-gen en_US.UTF-8 && locale-gen pt_BR.UTF-8
RUN dpkg-reconfigure locales

RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y libsasl2-dev bzr mercurial libxmlsec1-dev graphviz && \
    apt-get install -y python-cups python-dbus python-openssl python-libxml2 && \
    apt-get install -y python-pip xfonts-base xfonts-75dpi npm vim && \
    apt-get install -y libffi-dev poppler-utils && \
    apt-get clean && \
    npm install -g less less-plugin-clean-css && \
    ln -sf /usr/bin/nodejs /usr/bin/node && \
    mkdir /workspace && \
    mkdir -p /opt/devstep/addons/voodoo

RUN wget http://download.gna.org/wkhtmltopdf/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb && \
    dpkg -i wkhtmltox-0.12.1_linux-trusty-amd64.deb

RUN cd /workspace && \
    wget https://raw.githubusercontent.com/akretion/voodoo-image/master/stack/build/build_all && \
    wget https://raw.githubusercontent.com/akretion/voodoo-image/master/stack/build/buildout.dockerfile.cfg && \
    wget https://raw.githubusercontent.com/akretion/voodoo-image/master/stack/build/buildout.bootstrap.cfg && \
    wget https://raw.githubusercontent.com/akretion/voodoo-image/master/stack/build/fake_odoo7 && \
    wget https://raw.githubusercontent.com/akretion/voodoo-image/master/stack/build/fake_odoo8 && \
    wget https://raw.githubusercontent.com/akretion/voodoo-image/master/stack/build/fake_odoo9 && \
    sh build_all

RUN easy_install -U setuptools

RUN pip install pudb && pip install watchdog

VOLUME ["/data"]

RUN useradd -d /home/deploy -m deploy
RUN git clone git://github.com/c9/core.git /home/deploy/c9sdk && cd /home/deploy/c9sdk && scripts/install-sdk.sh
