=====================================
A Dockerfile for ADL LRS
=====================================


Build Image
==========================

$ sudo docker build -t adl_lrs .


Start Container
==========================

$ sudo docker run --name lrs_cn -d -p 10022:22 -p 8080:80 adl_lrs


Access to container using SSH
================================

$ ssh -p 10022 lrs@localhost


View ADL LRS site
================================

http://localhost:8080


