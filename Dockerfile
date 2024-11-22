FROM debian:stable

RUN apt-get -qq update; apt-get -qq install curl git jq

RUN git clone http://github.com/bil/timestamping

WORKDIR /timestamping/example
