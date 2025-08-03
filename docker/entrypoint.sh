#!/bin/sh
# Start php-fpm w tle
php-fpm &


# Uruchom nginx w trybie foreground
nginx -g 'daemon off;'
