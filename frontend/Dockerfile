FROM node

ARG API_URL

RUN apt-get update
RUN apt-get install -y ruby-dev build-essential
#RUN gem install compass --pre

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

RUN npm install

RUN npm run build build

CMD ["/bin/bash", "./run.sh"]
