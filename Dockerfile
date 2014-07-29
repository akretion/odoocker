FROM ubuntu:trusty
MAINTAINER rvalyi "rvalyi@akretion.com"

# Ensure UTF-8 locale
RUN echo "LANG=\"en_US.UTF-8\"" > /etc/default/locale
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales


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
ADD ./ruby.sh /etc/profile.d/ruby.sh
RUN chmod a+x /etc/profile.d/ruby.sh

# Install bundler gem globally
RUN /bin/bash -l -c 'gem install bundler'


RUN mkdir /tmp/build
ADD ./stack/ /tmp/build
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive cd /tmp/build && ./cedar.sh
RUN rm -rf /tmp/build


RUN useradd -d /home/daemon -m daemon
USER daemon
