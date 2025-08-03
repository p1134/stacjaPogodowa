# --- stage 1: build frontend ---
FROM node:20-alpine3.22 AS frontend-build
WORKDIR /app
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ .
RUN npm run build


# --- stage 2: php + nginx ---
FROM php:8.2-fpm


# Zależności systemowe + nginx
RUN apt-get update && apt-get install -y \
   nginx \
   git \
   unzip \
   curl \
   libicu-dev \
   libzip-dev \
   zip \
   libpq-dev \
   && docker-php-ext-install intl pdo pdo_pgsql opcache zip \
   && rm -rf /var/lib/apt/lists/*


# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer


# Aplikacja Symfony
WORKDIR /var/www/html
COPY backend/ ./


# Kopiuj frontend build do public/build
RUN rm -rf public/build
COPY --from=frontend-build /app/dist public/build


RUN rm -rf var/cache/* \
&& COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader --no-interaction --no-scripts \
&& php bin/console cache:clear --env=prod \
&& chown -R www-data:www-data var/ public/ vendor/




# Skonfiguruj Nginx: załaduj swój config
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf


# Zmień listen na 8080 (Fly oczekuje tego portu)
RUN sed -i 's/listen 80;/listen 8080;/' /etc/nginx/conf.d/default.conf


# Entry point: uruchom php-fpm i nginx
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh


EXPOSE 8080


CMD ["/usr/local/bin/entrypoint.sh"]
