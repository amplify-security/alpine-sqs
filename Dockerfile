# Copyright 2017 Ronald E. Oribio R.
#
# This file is part of alpine-sqs which is released under the GPLv3.
# See https://github.com/roribio/alpine-sqs for details.

FROM appropriate/curl as Builder

ARG elasticmq_version=1.6.1

WORKDIR /tmp/sqs-alpine

RUN \
  apk add --update git \
  && rm -rf /var/cache/apk/* \
  && git clone --verbose --depth=1 https://github.com/kobim/sqs-insight.git \
  && curl -LO https://s3-eu-west-1.amazonaws.com/softwaremill-public/elasticmq-server-${elasticmq_version}.jar \
  && mv elasticmq-server-${elasticmq_version}.jar elasticmq-server.jar

FROM anapsix/alpine-java:8
LABEL maintainer="Ronald E. Oribio R. https://github.com/roribio"

COPY --from=Builder /tmp/sqs-alpine/ /opt/
COPY etc/ /etc/
COPY opt/ /opt/

RUN \
  apk add --update \
    nodejs \
    nodejs-npm \
    supervisor \
    libtasn1=4.14-r0 \
  && apk upgrade musl \
  && rm -rf \
    /var/cache/apk/* \
    /etc/supervisord.conf \
  && ln -s /etc/supervisor/supervisord.conf /etc/supervisord.conf \
  && cd /opt/sqs-insight \
  && npm install

EXPOSE 9324 9325 

ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]

