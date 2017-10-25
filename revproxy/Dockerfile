# Base image:
FROM nginx
 
# Install dependencies
RUN apt-get update -qq && apt-get -y install apache2-utils
 
# establish where Nginx should look for files
ENV RAILS_ROOT /var/www/app
 
COPY *.conf /tmp/
RUN mkdir -p /var/www/log/
 
# substitute variable references in the Nginx config template for real values from the environment
# put the final config in its place
RUN mkdir -p /etc/nginx/conf.d/sites/
RUN envsubst '$RAILS_ROOT' < /tmp/default.conf > /etc/nginx/conf.d/default.conf
RUN envsubst '$RAILS_ROOT' < /tmp/api.conf > /etc/nginx/conf.d/sites/api.conf
RUN envsubst '$RAILS_ROOT' < /tmp/experiment.conf > /etc/nginx/conf.d/sites/experiment.conf
 
EXPOSE 80

# Use the "exec" form of CMD so Nginx shuts down gracefully on SIGTERM (i.e. `docker stop`)
CMD [ "nginx", "-g", "daemon off;" ]