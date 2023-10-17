FROM ubuntu:22.04

ARG STATS_DIR
ARG REPO
ARG REPO_NAME

WORKDIR /app
COPY . .
RUN apt-get update
RUN apt install -y python2 && apt install -y gnuplot && apt install -y git

RUN cd / && git clone ${REPO}

RUN mkdir ${STATS_DIR}

RUN cd /app && ./gitstats /${REPO_NAME} /${STATS_DIR}

CMD ['tail', '-f', '/dev/null']