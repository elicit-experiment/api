# Base image:
FROM nginx

ARG SITE_SUFFIX
ARG API_SCHEME

ENV API_SCHEME=${API_SCHEME}

# Install dependencies
RUN apt-get update -qq && apt-get -y install apache2-utils

# establish where Nginx should look for files
ENV RAILS_ROOT /var/www/app

COPY *.conf /tmp/
RUN mkdir -p /var/www/log/

# substitute variable references in the Nginx config template for real values from the environment
# put the final config in its place
RUN mkdir -p /etc/nginx/conf.d/sites/
RUN envsubst '${RAILS_ROOT} ${SITE_SUFFIX}' < /tmp/default.conf > /etc/nginx/conf.d/default.conf
RUN envsubst '${RAILS_ROOT} ${SITE_SUFFIX}' < /tmp/default_http.conf > /etc/nginx/conf.d/default_http.conf
RUN envsubst '${RAILS_ROOT} ${SITE_SUFFIX}' < /tmp/api.conf > /etc/nginx/conf.d/sites/api.conf
RUN envsubst '${RAILS_ROOT} ${SITE_SUFFIX}' < /tmp/experiment.conf > /etc/nginx/conf.d/sites/experiment.conf

# RUN [ "${API_SCHEME}" = "http" ] && echo cp /etc/nginx/conf.d/default_http.conf /etc/nginx/conf.d/default.conf
RUN bash -c 'if [ "${API_SCHEME}" = "http" ]; then mv /etc/nginx/conf.d/default_http.conf /etc/nginx/conf.d/default.conf; else rm /etc/nginx/conf.d/default_http.conf; fi'

EXPOSE 80

# Use the "exec" form of CMD so Nginx shuts down gracefully on SIGTERM (i.e. `docker stop`)
CMD [ "nginx", "-g", "daemon off;" ]
