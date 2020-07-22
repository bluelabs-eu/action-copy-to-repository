FROM ubuntu:bionic

RUN apt update
RUN apt install -y git

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
