FROM php:8.2-apache

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git unzip libicu-dev libonig-dev libzip-dev libpng-dev \
    libjpeg-dev libfreetype6-dev libxml2-dev libssl-dev \
    libbz2-dev libc-client-dev libkrb5-dev libgd-dev curl \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install intl pdo pdo_mysql zip bcmath imap gd \
    && a2enmod rewrite

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy Symfony files
COPY . .

# Add this before the composer install line
RUN echo "memory_limit = 2048M" > /usr/local/etc/php/conf.d/memory-limit.ini

# Then your existing line
RUN composer install --no-dev --optimize-autoloader

# Set permissions
RUN chown -R www-data:www-data /var/www/html/var /var/www/html/vendor /var/www/html/config

# Set recommended PHP.ini settings
COPY ./docker/php.ini /usr/local/etc/php/php.ini

# Expose port 80
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2-foreground"]