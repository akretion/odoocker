FROM ubuntu:trusty
MAINTAINER rvalyi "rvalyi@akretion.com"

# Ensure UTF-8 locale
RUN echo "LANG=\"en_US.UTF-8\"" > /etc/default/locale
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales


RUN mkdir /tmp/build
ADD ./stack/ /tmp/build
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive cd /tmp/build && ./cedar.sh
RUN rm -rf /tmp/build


ENV PATH $PATH:/opt/rubies/ruby-2.1.2/bin

# Install ruby-install
RUN cd /tmp &&\
  wget -O ruby-install-0.4.3.tar.gz https://github.com/postmodern/ruby-install/archive/v0.4.3.tar.gz &&\
  tar -xzvf ruby-install-0.4.3.tar.gz &&\
  cd ruby-install-0.4.3/ &&\
  make install

# Install MRI Ruby 2.1.2
RUN ruby-install ruby 2.1.2

# Add Ruby binaries to $PATH
RUN ln -s /opt/rubies/ruby-2.1.2/bin/ruby /usr/bin/ruby
RUN ln -s /opt/rubies/ruby-2.1.2/bin/gem /usr/bin/gem
RUN ln -s /opt/rubies/ruby-2.1.2/bin/bundle /usr/bin/bundle
RUN ln -s /opt/rubies/ruby-2.1.2/bin/bundler /usr/bin/bundler
RUN ln -s /opt/rubies/ruby-2.1.2/bin/rake /usr/bin/rake
RUN ln -s /opt/rubies/ruby-2.1.2/bin/irb /usr/bin/irb
ADD ./ruby.sh /etc/profile.d/ruby.sh
RUN chmod a+x /etc/profile.d/ruby.sh

# Install bundler gem globally
RUN /bin/bash -l -c 'gem install bundler'
RUN /bin/bash -l -c 'gem install nokogiri'
RUN /bin/bash -l -c 'gem install ooor'
RUN /bin/bash -l -c 'gem install pg'

RUN wget http://downloads.sourceforge.net/project/wkhtmltopdf/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb && \
    dpkg -i wkhtmltox-0.12.1_linux-trusty-amd64.de

RUN locale-gen pt_BR.UTF-8
RUN git clone https://github.com/renatonlima/PySPED.git -b certificado /tmp/PySPED && cd /tmp/PySPED && sudo python setup.py install
RUN pip install geraldo
RUN bzr branch lp:aeroolib /tmp/aeroolib --stacked && cd /tmp/aeroolib/aeroolib && sudo python setup.py install

RUN useradd -d /home/odoo -m odoo
USER odoo
