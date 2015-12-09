FROM debian:jessie

MAINTAINER Nikita Tarasov <nikita@mygento.ru>

RUN echo 'deb-src http://httpredir.debian.org/debian jessie main' >> /etc/apt/sources.list
RUN echo 'deb-src http://httpredir.debian.org/debian jessie-updates main' >> /etc/apt/sources.list
RUN echo 'deb-src http://security.debian.org jessie/updates main' >> /etc/apt/sources.list

ENV PATH $HOME/.phpenv/bin:$HOME/.phpenv/shims:$PATH

RUN apt-get -y -q update

## Install packages to compile php and Force some packages to be installed
RUN apt-get install -y -q git wget unzip build-essential libxml2-dev libssl-dev \
    pkg-config \
    libcurl4-gnutls-dev libjpeg-dev libpng12-dev libmcrypt-dev \
    libreadline-dev libtidy-dev libxslt1-dev autoconf \
    re2c bison && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

##
# PHPENV.
##

RUN rm -fR /root/.phpenv && rm -fR /tmp/phpenv && git clone https://github.com/CHH/phpenv.git /tmp/phpenv
RUN /tmp/phpenv/bin/phpenv-install.sh
RUN scp /tmp/phpenv/extensions/* /root/.phpenv/libexec/

RUN echo 'eval "$(phpenv init -)"' >> /root/.bashrc
ENV PATH /root/.phpenv/shims:/root/.phpenv/bin:$PATH

RUN git clone https://github.com/php-build/php-build.git /root/.phpenv/plugins/php-build
RUN /root/.phpenv/plugins/php-build/install.sh

RUN rm /usr/local/share/php-build/plugins.d/apc.sh && \
    # rm /usr/local/share/php-build/plugins.d/xdebug.sh && \
    rm /usr/local/share/php-build/plugins.d/uprofiler.sh && \	
    rm /usr/local/share/php-build/plugins.d/xhprof.sh && \
    rm /root/.phpenv/plugins/php-build/share/php-build/plugins.d/apc.sh && \
    # rm /root/.phpenv/plugins/php-build/share/php-build/plugins.d/xdebug.sh && \
    rm /root/.phpenv/plugins/php-build/share/php-build/plugins.d/uprofiler.sh && \
    rm /root/.phpenv/plugins/php-build/share/php-build/plugins.d/xhprof.sh

# Install php tools (composer / phpunit)
RUN cd $HOME && \
    wget http://getcomposer.org/composer.phar && \
    chmod +x composer.phar && \
    mv composer.phar /usr/local/bin/composer && \
    wget https://phar.phpunit.de/phpunit.phar && \
    chmod +x phpunit.phar && \
    mv phpunit.phar /usr/local/bin/phpunit

#RUN phpenv install 5.3.29 not compiling
RUN MAKEFLAGS=' -j8' phpenv install 5.4.44
RUN MAKEFLAGS=' -j8' phpenv install 5.5.30
RUN MAKEFLAGS=' -j8' phpenv install 5.6.16

RUN rm -rf /tmp/* /var/tmp/*

RUN phpenv rehash

RUN phpenv versions
