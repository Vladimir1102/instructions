#!/bin/bash
#
# DON'T FORGET to set:   chmod +x net-setting-kafka.sh
#


docker network create --driver bridge \
--subnet 10.11.0.0/16 \
--gateway 10.11.0.1 \
kafka_network


