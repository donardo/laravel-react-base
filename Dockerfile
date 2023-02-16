FROM php:8.2-apache

RUN cp /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
RUN echo "America/Sao_Paulo" >  /etc/timezone
ENV TZ America/Sao_Paulo
ENV LANG pt_BR.UTF-8
ENV LANGUAGE pt_BR.UTF-8
ENV LC_ALL pt_BR.UTF-8

# Install dependencies
RUN apt-get update && apt-get install -y libpq-dev locales sqlite3 libsqlite3-dev libzip-dev zip unzip git libicu-dev libonig-dev

RUN docker-php-ext-install \    
    bcmath \
    calendar \
    iconv \
    intl \
    mbstring \    
    pdo_mysql \
    zip    


# 2. Apache configs + document root.
RUN echo "ServerName laravel-app.local" >> /etc/apache2/apache2.conf

ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN a2enmod rewrite
RUN a2enmod rewrite headers

ARG uid

RUN useradd -G www-data,root -u $uid -d /home/devuser devuser
RUN mkdir -p /home/devuser/.composer \
    && chown -R devuser:devuser /home/devuser \
    && chown -R devuser:devuser /var/www

WORKDIR /var/www

CMD ["apache2-foreground"]