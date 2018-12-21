#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

KUBE_VERSION=v$1
KUBE_PAUSE_VERSION=3.1
ETCD_VERSION=3.2.18
DNS_VERSION=1.1.3

GCR_URL=gcr.io/google-containers
ALIYUN_URL=mirrorgooglecontainers

images=(kube-proxy-amd64:${KUBE_VERSION}
kube-scheduler-amd64:${KUBE_VERSION}
kube-controller-manager-amd64:${KUBE_VERSION}
kube-apiserver-amd64:${KUBE_VERSION}
pause:${KUBE_PAUSE_VERSION}
etcd-amd64:${ETCD_VERSION}
coredns:${DNS_VERSION})

for imageName in ${images[@]} 
do
  docker pull $GCR_URL/$imageName
  docker tag $GCR_URL/$imageName $ALIYUN_URL/$imageName
  docker push $ALIYUN_URL/$imageName
  docker rmi $ALIYUN_URL/$imageName
done

swapoff -a && sysctl -w vm.swappiness=0

cat << EOF | tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl -p /etc/sysctl.d/k8s.conf
