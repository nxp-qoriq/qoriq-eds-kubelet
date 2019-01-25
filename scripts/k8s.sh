#####################################
#
# Copyright 2017 NXP
#
#####################################

#!/bin/bash

echo "Start kubelet"

podpause="edgerepos/pause-arm64:3.0"

docker pull $podpause >/dev/null 2>&1 &


killall -9 kubelet >/dev/null 2>&1
mkdir -p /dev/kubelet; mkdir -p /var/lib/kubelet/;mkdir -p /var/log/edgescale

export PATH=/usr/local/edgescale/bin/:$PATH


kubelet --address=127.0.0.1 --pod-infra-container-image=$podpause --image-gc-high-threshold=99 --image-gc-low-threshold=95 --image-pull-progress-deadline=10m --pod-manifest-path=/dev/kubelet/ --allow-privileged=true --logtostderr=true  --v=1 > /var/log/edgescale/kubelet.log 2>&1 &

