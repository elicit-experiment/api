FROM node

ARG API_URL

RUN apt-get update
RUN apt-get install -y ruby-dev build-essential
#RUN gem install compass --pre

RUN npm install -g gulp
RUN npm install gulp
RUN npm install gulp-coffee
RUN npm install gulp-concat
RUN npm install gulp-uglify
RUN npm install gulp-compass

# Enable installing gems from git repos
RUN apt-get install git

# to handle running as a normal user
#RUN dnf -y install sudo

# run as a non-root user (Issue#57)
RUN adduser elicituser
# && \
#    echo "elicituser ALL=(root) NOPASSWD:ALL" >> /etc/sudoers

USER elicituser

RUN mkdir /experiment-frontend

COPY . /experiment-frontend

WORKDIR /experiment-frontend

RUN sed -i'' -E "s/(\s+portalPath\: ).*/\1\"http:\/\/$API_URL\"/g" gulpfile.js 

RUN cat gulpfile.js | grep portalPath

RUN npm install

RUN gulp build

CMD ["/bin/bash", "./run.sh"]
