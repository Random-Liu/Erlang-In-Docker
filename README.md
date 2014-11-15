Erlang-In-Docker
================
Enable Erlang connection among `distributed dockers` (docker containers on different hosts) by reimplementing the distributed connection protocol of `net_kernel`.

Introduction
------------
Erlang nodes need connect with each other to work together, so they are usually used in one subnet.
However, dockers on different hosts are in different subnets (one subnet per host). So it's difficult to build Erlang cluster on distributed docker cluster.

Erlang Network
--------------
When an Erlang node attempts to connect another node, it must create a tcp connection to the node. Because different Erlang nodes listen on different ports, there should be a naming service with a known port which can tell us the port of a Erlang node. That's [epmd](www.erlang.org/doc/man/epmd.html).

The following figure shows the connection buiding process of Erlang nodes:
![image](https://raw.githubusercontent.com/taotaotheripper/Erlang-In-Docker/master/images/Erlang_Network.jpg "Erlang Network")

Erlang Network in Dockers
-------------------------
### Difficulty of Connecting Nodes among Distributed Dockers
It is difficult to connect nodes among distributed dockers, because:<br />
  * Dockers on different hosts are in different subnets. If a process in a docker wants to communicate with a process on another docker, it should access the host IP and published host port of the target process.<br />
  * It is difficult to publish ports used by Erlang node. It is because the port which an Erlang node listens on is allocated dynamically when the node starts.<br />
  * It is hard to get the published port of an Erlang node. If we use `-P` or `-p xxx:xxx` to fix the port mapping, we can start only one docker with Erlang on one host because of port conflict. If we use `-p xxx` to map the port to an arbitrary host port, we can only get the published port from the docker daemon.<br />

### Solution
In this project, we implement a new connection protocol module `eid_tcp_dist.erl` instead of `inet_tcp_dist.erl`. The following figure shows the new protocol of Erlang connection.
![image](https://raw.githubusercontent.com/taotaotheripper/Erlang-In-Docker/master/images/Erlang_Network_in_Dockers.jpg "Erlang Network in Dockers")
We mainly did the following modifications on the connection protocol:<br />
  * Limit that each docker can only hold one Erlang node.<br />
  * Rule that the Erlang node name should be `DockerContainerID@HostIP`.<br />
  * Fix the port used by Erlang. (Default 4243)<br />
  * Use Docker Remote API to get the published port of Erlang node.<br />

Install
-------
### Docker Configuration
Docker Remote API should be enabled by following steps:<br />
1. add `DOCKER_OPTS="-H tcp://0.0.0.0:4243"` in `/etc/default/docker.io` or `/etc/default/docker`.<br />
2. Restart docker daemon by `sudo service docker restart`.<br />
>PS: `4243` is the default port used by docker HTTP API. It can also be set to some other value such as `4321`, but eid should be configured the same docker port value by adding `-kernel docker_dameon_port 4321` when starting VM.

### Erlang-In-Docker Installation and Configuration
#### Erlang-In-Docker Installation


安装配置
docker配置
eid安装配置

演示

docker image


