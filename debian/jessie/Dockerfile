FROM debian:jessie
LABEL maintainer "Patrick Ringl"
LABEL version="0.8"
RUN echo 'deb http://deb.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/backports.list
RUN apt-get update && apt-get install -y git libssl-dev python-dev vim python-apt python-pip libffi-dev libyaml-perl
RUN pip install virtualenv
WORKDIR /opt
RUN virtualenv ansible-2.4.2.0
RUN virtualenv ansible-2.3.3.0
RUN virtualenv ansible-2.2.3.0
RUN virtualenv ansible-2.1.6.0
RUN ansible-2.4.2.0/bin/pip install ansible==2.4.2.0 jmespath passlib
RUN ansible-2.3.3.0/bin/pip install ansible==2.3.3.0 jmespath passlib
RUN ansible-2.2.3.0/bin/pip install ansible==2.2.3.0 jmespath passlib
RUN ansible-2.1.6.0/bin/pip install ansible==2.1.6.0 jmespath passlib
