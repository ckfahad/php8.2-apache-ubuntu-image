FROM ubuntu:latest AS base

ENV DEBIAN_FRONTEND noninteractive

# Set working directory
WORKDIR /var/www/html

# Enable necessary Apache modules
RUN apt update && apt install -y apache2

# Install dependencies
RUN apt update
RUN apt install -y software-properties-common
RUN add-apt-repository -y ppa:ondrej/php
RUN apt update
RUN apt install -y php8.2\
    php8.2-cli\
    php8.2-common\
    php8.2-fpm\
    php8.2-mysql\
    php8.2-zip\
    php8.2-gd\
    php8.2-mbstring\
    php8.2-curl\
    php8.2-xml\
    php8.2-bcmath\
    php8.2-pdo \
    && a2enmod proxy_fcgi setenvif \
    && a2enconf php8.2-fpm \
    && a2enmod rewrite

# Install php-fpm
RUN apt install -y php8.2-fpm php8.2-cli

# Update and install dependencies
RUN apt-get update && apt-get install -y build-essential pkg-config autoconf bison re2c libxml2-dev \
    libssl-dev libsqlite3-dev libcurl4-openssl-dev libpng-dev libjpeg-dev \
    libonig-dev libfreetype6-dev libzip-dev libtidy-dev libwebp-dev libltdl7 libltdl-dev

# Install wget and git
RUN apt install -y wget git

# # Set PHP version and download distribution
# RUN VERSION=8.2.18 && wget -qO- https://www.php.net/distributions/php-${VERSION}.tar.gz | tar -xz && cd php-${VERSION}/ext && git clone --depth=1 https://github.com/krakjoe/parallel.git

# Set PHP version
ENV PHP_VERSION=8.2.18

# Download PHP source code
RUN wget -qO- "https://www.php.net/distributions/php-${PHP_VERSION}.tar.gz" | tar -xz

# Clone Parallel extension
RUN git clone --depth=1 https://github.com/krakjoe/parallel.git

# Build and install PHP (ZTS) with parallel
RUN cd php-${PHP_VERSION} && ./buildconf --force -shared && ./configure \
    --prefix=/etc/php8z \
    --with-config-file-path=/etc/php8z \
    --with-config-file-scan-dir=/etc/php8z/conf.d \
    --disable-cgi \
    --with-zlib \
    --with-zip \
    --with-openssl \
    --with-curl \
    --enable-mysqlnd \
    --with-mysqli=mysqlnd \
    --with-pdo-mysql=mysqlnd \
    --enable-pcntl \
    --enable-gd \
    --enable-exif \
    --with-jpeg \
    --with-freetype \
    --with-webp \
    --enable-bcmath \
    --enable-mbstring \
    --enable-calendar \
    --with-tidy \
    --enable-zts \
    --enable-parallel && make -j$(nproc) && make install

# Copy php.ini-development to /etc/php8z/php.ini and create a symbolic link to /usr/bin/phpz
RUN cp php-${PHP_VERSION}/php.ini-development /etc/php8z/php.ini && ln -s /etc/php8z/bin/php /usr/bin/phpz

# Adding memory configurations
RUN mkdir /etc/php8z/conf.d
RUN echo "max_execution_time = 700" >> /etc/php8z/conf.d/additional.ini
RUN echo "max_input_time = 700" >> /etc/php8z/conf.d/additional.ini
RUN echo "memory_limit = 512M" >> /etc/php8z/conf.d/additional.ini

# Copy files from local to the root of the server
COPY index.php /var/www/html/index.php
COPY modrewrite.php /var/www/html/modrewrite.php
COPY zts.php /var/www/html/zts.php

# Expose port 80 for Apache
EXPOSE 80

# Start Apache service
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]