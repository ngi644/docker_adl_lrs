############################################################
# Dockerfile to run ADL_LRS Containers
# Based on Ubuntu 14.04 Image
############################################################

# base image to use to Ubuntu
FROM ubuntu:14.04

# maintainer
MAINTAINER Maintaner ngi644

# Update the default application repository sources list
RUN sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list
RUN apt-get update -y
RUN apt-get upgrade -y

# install modules
RUN sudo apt-get install -y vim ssh build-essential libssl-dev libxml2-dev libxslt1-dev python-setuptools \
                            python-dev mercurial git fabric
RUN sudo apt-get install -y postgresql postgresql-server-dev-all
RUN sudo sudo easy_install pip
RUN sudo pip install virtualenv

# create lrs user
RUN adduser --disabled-password lrs

# set password for root and plone
RUN bash -c 'echo "root:root" | chpasswd'
RUN bash -c 'echo "lrs:lrs" | chpasswd'

RUN bash -c 'echo "lrs ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/lrs'

ENV INSTALL_DIR adl_lrs
ENV ADL_USER lrs
ENV DB_USER $ADL_USER
ENV DB_PASSWORD postgres

# run postgres
RUN sudo service postgresql start &&\
 sudo -u postgres createuser -s -w $ADL_USER &&\
 sudo -u postgres psql --command "\password" &&\
 sudo -u postgres psql --command "alter role ${ADL_USER} with password '${DB_PASSWORD}';" &&\
 sudo -u postgres psql --command "CREATE DATABASE lrs OWNER ${ADL_USER} encoding 'UTF8' TEMPLATE template0;" &&\
 sudo -u postgres psql --command "\q"

# setup sshd
RUN apt-get install -y openssh-server
RUN mkdir -p /var/run/sshd && chmod 755 /var/run/sshd

# expose ports
EXPOSE 22 8000 11211

# install adl_lrs
USER $ADL_USER
WORKDIR /home/lrs
RUN mkdir $INSTALL_DIR
RUN git clone https://github.com/adlnet/ADL_LRS.git $INSTALL_DIR/
WORKDIR /home/lrs/$INSTALL_DIR
RUN sed -i "s/Django==1.4/Django==1.4.20/g" requirements.txt
WORKDIR /home/lrs/$INSTALL_DIR/adl_lrs
RUN sed -i "s/root/${ADL_USER}/g" settings.py &&\
    sed -i "s/password/${DB_PASSWORD}/g" settings.py
WORKDIR /home/lrs/$INSTALL_DIR
RUN fab setup_env

RUN . ../env/bin/activate &&\
    sudo service postgresql start &&\
    sleep 30s &&\
    fab setup_lrs

# Define default command.
USER root
CMD /usr/sbin/sshd -D