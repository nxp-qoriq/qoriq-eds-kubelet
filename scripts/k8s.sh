#####################################
#
# Copyright 2017 NXP
#
#####################################

#!/bin/bash

HOSTNAME=$(hostname)
MasterIP=int.app.edgescale.org
IP_ADDRESS=$(ip -o -4 addr list $(ip -o -4 route show to default | awk '{print $5}' | head -1) | awk '{print $4}' | cut -d/ -f1 | head -1)



echo "Start kubelet"
mkdir -p /etc/kubernetes/ssl/
if [ -d /data/certs ];then
	cp /data/certs/edgescale.pem /etc/kubernetes/ssl/kubelet-client.crt
	cp /data/private_keys/edgescale.key /etc/kubernetes/ssl/kubelet-client.key

else
	echo "Error cert file is not found";exit -1
fi

podpause="edgerepos/pause-arm64:3.0"

docker pull $podpause >/dev/null 2>&1 &

# Starting kubelet, 6443 with encryted port have been enabled, 8080 is also working for debug in fsl network envrionment. 8080 port will be disabled in production envrioment later.

killall  kubelet >/dev/null 2>&1;mkdir -p /var/lib/kubelet/;mkdir -p /etc/kubernetes/ssl

/usr/local/bin/kubelet --pod-infra-container-image=$podpause --image-gc-high-threshold=99 --image-gc-low-threshold=95 --image-pull-progress-deadline=10m --kubeconfig=/etc/kubernetes/kubelet.kubeconfig --require-kubeconfig --cert-dir=/etc/kubernetes/ssl --node-ip=$IP_ADDRESS --cluster-dns=10.96.0.2   --cluster-domain=cluster.local. --allow-privileged=true --logtostderr=true  --v=2 > /var/log/kubelet.log 2>&1 &

