# NOTE this is mostly a copy of https://github.com/akretion/voodoo-image/blob/master/Dockerfile
# a different base image is needed to support the git deploy and all the web stacks we want
FROM gliderlabs/herokuish

USER root

RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y libsasl2-dev bzr mercurial libxmlsec1-dev \
    python-setuptools graphviz xfonts-base xfonts-75dpi npm git \
    python-cups python-dbus python-libxml2 \
    wget libpq-dev libjpeg8-dev libldap2-dev \
    libffi-dev vim telnet ghostscript poppler-utils && \
    npm install -g less less-plugin-clean-css && \
    ln -sf /usr/bin/nodejs /usr/bin/node && \
    apt-get clean

# Force to install the version 0.12.1 of wkhtmltopdf as recomended by odoo
RUN wget https://downloads.wkhtmltopdf.org/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb && \
    dpkg -i wkhtmltox-0.12.1_linux-trusty-amd64.deb

RUN locale-gen pt_BR.UTF-8 && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

#Install fonts
RUN wget https://github.com/akretion/voodoo-image/raw/master/stack/fonts/c39hrp24dhtt.ttf -O /usr/share/fonts/c39hrp24dhtt.ttf
RUN chmod a+r /usr/share/fonts/c39hrp24dhtt.ttf && fc-cache -f -v

RUN mkdir -p /workspace

# Pre-build environement for odoo
RUN wget https://raw.githubusercontent.com/akretion/voodoo-image/master/stack/build/build -O /workspace/build
RUN wget https://raw.githubusercontent.com/akretion/voodoo-image/master/stack/build/buildout.cfg -O /workspace/buildout.cfg
RUN wget https://raw.githubusercontent.com/akretion/voodoo-image/master/stack/build/frozen.cfg -O /workspace/frozen.cfg
RUN sh /workspace/build

RUN adduser odoo

RUN easy_install pip
RUN pip install --upgrade setuptools
RUN pip install flake8 && \
    pip install git+https://github.com/oca/pylint-odoo.git
RUN pip install pudb && pip install watchdog

RUN useradd -d /home/deploy -m deploy
RUN git config --global user.email "voodoo@fake.com" &&\
    git config --global user.name "Voodoo"
#RUN git clone git://github.com/c9/core.git /home/deploy/c9sdk && cd /home/deploy/c9sdk && scripts/install-sdk.sh
