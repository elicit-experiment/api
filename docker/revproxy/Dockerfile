# Base image:
FROM nginx:1.19.2-alpine

ARG SITE_SUFFIX
ARG API_SCHEME

ENV SITE_SUFFIX=${SITE_SUFFIX}
ENV API_SCHEME=${API_SCHEME}

COPY *.conf.template /etc/nginx/templates/
RUN mkdir /etc/nginx/templates/sites
COPY sites/ /etc/nginx/templates/sites
RUN mkdir -p /var/www/log/

RUN sh -c 'if [ "${API_SCHEME}" = "http" ]; then echo "HTTP"; else echo "HTTPS"; fi'
RUN sh -c 'if [ "${API_SCHEME}" = "http" ]; then mv /etc/nginx/templates/default_http.conf.template /etc/nginx/templates/default.conf.template; else rm /etc/nginx/templates/default_http.conf.template; fi'

# Use the "exec" form of CMD so Nginx shuts down gracefully on SIGTERM (i.e. `docker stop`)
CMD [ "nginx", "-g", "daemon off;" ]
