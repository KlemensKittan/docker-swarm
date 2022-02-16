# Create a swarm

## Introduction

Getting started with swarm mode.

## Configuring

You  require three Linux hosts which have Docker installed and can communicate
over a network. All nodes in the swarm need to connect to the manager at.

The following ports must be available.

- TCP port 2377 for cluster management communications
- TCP and UDP port 7946 for communication among nodes
- UDP port 4789 for overlay network traffic

### Use swarm mode routing mesh

Docker Engine swarm mode makes it easy to publish ports for services to make
them available to resources outside the swarm. All nodes participate in an
ingress routing mesh. The routing mesh enables each node in the swarm to accept
connections on published ports for any service running in the swarm, even if
there’s no task running on the node. The routing mesh routes all incoming
requests to published ports on available nodes to an active container.

![Use swarm mode routing mesh](images/ingress-routing-mesh.png)

### Bypass the routing mesh

You can bypass the routing mesh, so that when you access the bound port on a
given node, you are always accessing the instance of the service running on that
node. This is referred to as **host** mode. There are a few things to keep in
mind.

- If you access a node which is not running a service task, the service does not
  listen on that port. It is possible that nothing is listening, or that a
  completely different application is listening.

 - If you expect to run multiple service tasks on each node, you cannot specify
   a static target port. Either allow Docker to assign a random high-numbered
   port (by leaving off the **published**), or ensure that only a single
   instance of the service runs on a given node, by using a global service
   rather than a replicated one, or by using placement constraints.

To bypass the routing mesh, you must use the long **--publish** service and set
**mode** to **host**. If you omit the mode key or set it to ingress, the routing
mesh is used. The following command creates a global service using host mode and
bypassing the routing mesh:

    docker service create --name [NAME] --publish published=80,target=80,mode=host --mode global [IMAGE]

![Bypass the routing mesh](images/ingress-lb.png)

### Deploy the core-stack

After creating the swarm, some containers should be running for administration.

Create traefik network on the master:

    docker network create --driver overlay --attachable traefik

Deploy the core-stack to the swarm:

    docker stack deploy --compose-file core/core-stack.yml core-stack

## Commands

### Manage nodes in a swarm

Set up master:

    docker swarm init --advertise-addr [MANAGER_IP]

Get token to join workers:

    docker swarm join-token manager

Get token to join new manager:

    docker swarm join-token worker

Join host as a Manager:

    docker swarm join --token [TOKEN_MANAGER] [MANAGER_IP]:2377

Join host as a Worker:

    docker swarm join --token [TOKEN_WORKER] [MANAGER_IP]:2377

To view a list of nodes in the swarm:

    docker node ls

Inspect an individual node:

    docker node inspect --pretty [NODE-ID]

You can promote a worker node to the manager role. This is useful when a manager
node becomes unavailable or if you want to take a manager offline for
maintenance.

To promote a node:

    docker node promote [NODE-ID]

To demote a node:

    docker node demote [NODE-ID]

Run the `docker swarm leave` command on a node to remove it from the swarm.
After a node leaves the swarm, you can run the `docker node rm` command on a
manager node to remove the node from the node list.

    docker node rm [NODE-ID]

### Deploy services to a swarm

Create a new service:

    docker service create [IMAGE]

    docker service create --name [NAME] [IMAGE]

Create a replicated service:

    docker service create --name [NAME] --replicas 3 [IMAGE]

List services:

    docker service ls

Remove one or more services:

    docker service rm [NAME]

### Deploy a stack to a swarm

When running Docker Engine in swarm mode, you can use `docker stack` deploy to
deploy a complete application stack to the swarm.

Deploy the stack to the swarm:

    docker stack deploy --compose-file docker-compose.yml [STACK]

Check if the stack is running:

    docker stack services [STACK]

List stacks:

    docker stack ls

Bring the stack down with:

    docker stack rm [STACK]

## Resources

The pictures and parts of the documentation are borrowed from the documentation
on https://docs.docker.com/engine/swarm/ingress/.

- <https://docs.docker.com/engine/swarm/>
- <https://docs.docker.com/engine/swarm/admin_guide/>
- <https://docs.docker.com/engine/swarm/ingress/>
