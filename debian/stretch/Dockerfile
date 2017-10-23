FROM debian:stretch
LABEL maintainer "Patrick Ringl"
LABEL version="0.7"
RUN apt-get update && apt-get install -y git libssl-dev python-dev vim python-apt python-pip libffi-dev libyaml-perl procps systemd
RUN pip install virtualenv
WORKDIR /opt
RUN virtualenv ansible-2.4.0.0
RUN virtualenv ansible-2.3.2.0
RUN virtualenv ansible-2.2.3.0
RUN virtualenv ansible-2.1.6.0
RUN ansible-2.4.0.0/bin/pip install ansible==2.4.0.0 jmespath
RUN ansible-2.3.2.0/bin/pip install ansible==2.3.2.0 jmespath
RUN ansible-2.2.3.0/bin/pip install ansible==2.2.3.0 jmespath
RUN ansible-2.1.6.0/bin/pip install ansible==2.1.6.0 jmespath
