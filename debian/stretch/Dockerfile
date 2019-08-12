FROM debian:stretch
ARG ANSIBLE_VERSION="2.8.3"
LABEL maintainer "Patrick Ringl"
LABEL version="0.25"
RUN echo 'deb http://deb.debian.org/debian stretch-backports main' > /etc/apt/sources.list.d/backports.list
RUN apt-get update && apt-get install -y git libssl-dev python-dev vim python-apt python-pip libffi-dev libyaml-perl procps systemd
RUN pip install virtualenv
WORKDIR /opt
RUN virtualenv ansible-$ANSIBLE_VERSION
COPY requirements.txt /opt/requirements.txt
RUN ansible-$ANSIBLE_VERSION/bin/pip install ansible==$ANSIBLE_VERSION -r requirements.txt
