# Base image:
FROM nginx
 
# Install dependencies
RUN apt-get update -qq && apt-get -y install apache2-utils
 
# establish where Nginx should look for files
ENV RAILS_ROOT /var/www/app
 
COPY default.conf /tmp/default.conf
RUN mkdir -p /var/www/log/
 
# substitute variable references in the Nginx config template for real values from the environment
# put the final config in its place
RUN envsubst '$RAILS_ROOT' < /tmp/default.conf > /etc/nginx/conf.d/default.conf
 
EXPOSE 80

# Use the "exec" form of CMD so Nginx shuts down gracefully on SIGTERM (i.e. `docker stop`)
CMD [ "nginx", "-g", "daemon off;" ]