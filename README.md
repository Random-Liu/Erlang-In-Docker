Erlang-In-Docker
================
Enable connection between Erlang VMs from different docker containers on different hosts by reimplementing the distributed connection protocol of

Introduction
------------
Erlang VMs need connect with each other to work together, so they are usually used in one subnet.
However. dockers on different hosts are usually in differnt subnets (one subnet per host). So it's difficult to build Erlang cluster on dockers from different hosts.

Erlang Network
--------------
![github]: (http://github.com/taotaotheripper/Erlang-In-Docker/master/images/Erlang_Network.jpg "Erlang Network")

Erlang Network in Dockers
-------------------------
![github]: (http://github.com/taotaotheripper/Erlang-In-Docker/master/images/Erlang_Network_in_Dockers.jpg "Erlang Network in Dockers")

问题描述
问题概述
docker问题
erlang连接原理

解决方案
解决方案图

安装配置
docker配置
eid安装配置

演示

docker image


