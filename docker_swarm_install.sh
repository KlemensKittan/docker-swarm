#!/bin/bash

# Description: Setting up Docker Swarm.
# Written by : Klemens Kittan, klemens.kittan@uni-potsdam.de.de, 14.02.22

clear

manager=("dh1" "dh2" "dh3")
manager_ip=$(dig +short ${manager[0]})
worker=()

if [ "${#manager[*]}" -lt 3 ]; then
  echo "You need at least three managers!"
  echo
  exit 1
fi

# Create Swarm Manager
echo "Setting up Docker Swarm"
echo
echo "${manager[0]} inits swarm and becomes a manager"
ssh -l root ${manager[0]} "docker swarm init --advertise-addr ${manager_ip}"

# Fetch tokens
token_manager=$(ssh -l root ${manager[0]} docker swarm join-token manager | grep token | awk '{ print $5 }')
token_worker=$(ssh -l root ${manager[0]} docker swarm join-token worker | grep token | awk '{ print $5 }')

# Add Managers
for index in $(seq 1 "$(expr ${#manager[@]} - 1)")
do
  echo "${manager[${index}]} join swarm as a Manager"
  ssh -l root ${manager[${index}]} "docker swarm join --token ${token_manager} ${manager_ip}:2377"
done
echo

# Add Workers
for index in ${!worker[*]}
do
  echo "${worker[${index}]} join swarm as a Worker"
  ssh -l root ${worker[${index}]} "docker swarm join --token ${token_worker} ${manager_ip}:2377"
done
echo
