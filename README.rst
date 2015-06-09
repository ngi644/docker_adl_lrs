# docker_adl_lrs

=====================================
A Dockerfile for ADL_LRS
=====================================


Build Image
==========================

$ sudo docker build -t adl_lrs .


Start Container
==========================

$ sudo docker run --name lrs_cn -d -p 10022:22 -p 18000:8000 adl_lrs


Access to container using SSH
================================

$ ssh -p 10022 lrs@localhost


View ADL_LRS site
================================

http://localhost:18000

