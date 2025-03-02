FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && \
    apt-get install -y apache2 php libapache2-mod-php php-mysql curl unzip && \
    rm -rf /var/lib/apt/lists/*

# Set the ServerName directive to suppress Apache warnings
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Download and set up WordPress
WORKDIR /var/www/html
RUN curl -O https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz --strip-components=1 && \
    rm latest.tar.gz

# Set permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Configure Apache virtual host for Render instance
RUN echo '<VirtualHost *:80>
    ServerName $RENDER_EXTERNAL_HOSTNAME
    DocumentRoot /var/www/html
    <Directory /var/www/html>
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Enable mod_rewrite for WordPress permalinks
RUN a2enmod rewrite

# Expose necessary ports
EXPOSE 10000

# Set environment variables for database connection
ENV WORDPRESS_DB_HOST=mysql-fc26a74-saveetha-f45b.l.aivencloud.com
ENV WORDPRESS_DB_USER=avnadmin
ENV WORDPRESS_DB_PASSWORD=AVNS_6J6WUE9J_4Hln6g0kNq
ENV WORDPRESS_DB_NAME=defaultdb
ENV WORDPRESS_DB_PORT=11659

# Set the WordPress site URL dynamically based on Render's external hostname
RUN echo "define('WP_HOME', 'http://'.getenv('RENDER_EXTERNAL_HOSTNAME'))" >> /var/www/html/wp-config.php && \
    echo "define('WP_SITEURL', 'http://'.getenv('RENDER_EXTERNAL_HOSTNAME'))" >> /var/www/html/wp-config.php

# Restart Apache to apply changes
RUN service apache2 restart

# Start Apache in the foreground
CMD ["apachectl", "-D", "FOREGROUND"]
