FROM debian:stretch
LABEL maintainer "Patrick Ringl"
LABEL version="0.17"
RUN echo 'deb http://deb.debian.org/debian stretch-backports main' > /etc/apt/sources.list.d/backports.list
RUN apt-get update && apt-get install -y git libssl-dev python-dev vim python-apt python-pip libffi-dev libyaml-perl procps systemd
RUN pip install virtualenv
WORKDIR /opt
RUN virtualenv ansible-2.6.1.0
RUN virtualenv ansible-2.5.6.0
RUN virtualenv ansible-2.4.5.0
RUN virtualenv ansible-2.3.3.0
COPY requirements.txt /opt/requirements.txt
RUN ansible-2.6.1.0/bin/pip install ansible==2.6.1.0 -r requirements.txt
RUN ansible-2.5.6.0/bin/pip install ansible==2.5.6.0 -r requirements.txt
RUN ansible-2.4.5.0/bin/pip install ansible==2.4.5.0 -r requirements.txt
RUN ansible-2.3.3.0/bin/pip install ansible==2.3.3.0 -r requirements.txt
