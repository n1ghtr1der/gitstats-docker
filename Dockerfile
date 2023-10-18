FROM ubuntu:22.04 as build

ARG STATS_DIR
ARG REPO
ARG REPO_NAME
ARG SSH_PRV_KEY
ARG SSH_PUB_KEY

WORKDIR /app
COPY . .
RUN apt-get update
RUN apt install -y python2 && apt install -y gnuplot && apt install -y git

RUN mkdir ~/.ssh
RUN echo "${SSH_PRV_KEY}" > /root/.ssh/id_rsa && \
    echo "${SSH_PUB_KEY}" > /root/.ssh/id_rsa.pub && \
    chmod 600 /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa.pub && \
    ssh-keyscan github.com >> /root/.ssh/known_hosts

RUN git clone ${REPO}
    
RUN rm /root/.ssh/id_rsa*

RUN mkdir /${STATS_DIR}

RUN cd /app && ./gitstats /app/${REPO_NAME} /${STATS_DIR}

# FROM build