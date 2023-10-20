FROM ubuntu:22.04 as statsGen

ARG REPO
ARG REPO_NAME
ARG SSH_PRV_KEY
ARG BRANCH

WORKDIR /app

RUN apt-get update
RUN apt install -y python2 && apt install -y gnuplot && apt install -y git

RUN git clone https://github.com/hoxu/gitstats.git

RUN mkdir ~/.ssh
RUN echo "${SSH_PRV_KEY}" > /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa && \
    ssh-keyscan ssh.dev.azure.com >> /root/.ssh/known_hosts

RUN git clone ${REPO} && \
    cd ${REPO_NAME} && \
    git checkout origin/${BRANCH} && cd ..
    
RUN rm /root/.ssh/id_rsa*

RUN mkdir stats

RUN ./gitstats/gitstats /app/${REPO_NAME} /app/stats

FROM alpine

WORKDIR /stats
COPY --from=statsGen /app/stats .
