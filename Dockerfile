FROM debian:jessie

MAINTAINER Nikita Tarasov <nikita@mygento.ru>
ENV DEBIAN_FRONTEND noninteractive
ENV PATH $HOME/.phpenv/bin:$HOME/.phpenv/shims:$PATH

RUN echo 'deb-src http://httpredir.debian.org/debian jessie main' >> /etc/apt/sources.list && \
    echo 'deb-src http://httpredir.debian.org/debian jessie-updates main' >> /etc/apt/sources.list && \
    echo 'deb-src http://security.debian.org jessie/updates main' >> /etc/apt/sources.list

RUN apt-get -y -q update

## Install packages to compile php and Force some packages to be installed
RUN apt-get install -y -q git wget php5 curl unzip build-essential libxml2-dev libssl-dev \
    pkg-config \
    libcurl4-gnutls-dev libjpeg-dev libpng12-dev libmcrypt-dev \
    libreadline-dev libtidy-dev libxslt1-dev autoconf \
    re2c bison && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#PHPbrew

RUN cd /tmp && \
    curl -L -O https://raw.github.com/phpbrew/phpbrew/master/phpbrew && \
    chmod +x phpbrew && \
    mv phpbrew /usr/bin/phpbrew && \
    phpbrew init && \
    echo  "\\nsource ~/.phpbrew/bashrc\\n" >> /root/.bashrc

RUN phpbrew install 5.4.45 +default && phpbrew clean
RUN phpbrew install 5.5.31 +default && phpbrew clean
RUN phpbrew install 5.6.17 +default && phpbrew clean
RUN phpbrew install 7.0.2 +default && phpbrew clean

# Install php tools (composer / phpunit)
RUN cd $HOME && \
    wget http://getcomposer.org/composer.phar && \
    chmod +x composer.phar && \
    mv composer.phar /usr/local/bin/composer && \
    wget https://phar.phpunit.de/phpunit.phar && \
    chmod +x phpunit.phar && \
    mv phpunit.phar /usr/local/bin/phpunit
