FROM node

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

RUN git clone https://github.com/cosound/Cockpit.Experiments.Web.git

WORKDIR Cockpit.Experiments.Web

RUN sed -i'' -E 's/(\s+portalPath\: ).*/\1"http:\/\/docker.local"/g' gulpfile.js 

RUN cat gulpfile.js | grep portalPath

RUN npm install

RUN gulp build

COPY ./run.sh .

CMD ["/bin/bash", "./run.sh"]
