FROM progrium/buildstep

RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y libsasl2-dev bzr mercurial libxmlsec1-dev graphviz xfonts-base xfonts-75dpi && \
    apt-get install -y python-pip python-cups python-dbus python-openssl python-libxml2 && \
    apt-get clean && \
    pip install --upgrade setuptools zc.buildout && \
    mkdir /workspace && \
    mkdir -p /opt/devstep/addons/voodoo

RUN wget http://downloads.sourceforge.net/project/wkhtmltopdf/0.12.2.1/wkhtmltox-0.12.2.1_linux-trusty-amd64.deb && \
    dpkg -i wkhtmltox-0.12.2.1_linux-trusty-amd64.deb

RUN https://raw.githubusercontent.com/akretion/voodoo-image/master/stack/build/build_all && \
    chmod +x build_all && \
    ./build_all
