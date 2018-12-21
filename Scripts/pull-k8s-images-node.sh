#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

KUBE_VERSION=v$1
KUBE_PAUSE_VERSION=$2
ETCD_VERSION=$3
DNS_VERSION=$4

GCR_URL=k8s.gcr.io
ALIYUN_URL=mirrorgooglecontainers

images=(kube-proxy:${KUBE_VERSION}
kube-scheduler:${KUBE_VERSION}
kube-controller-manager:${KUBE_VERSION}
pause:${KUBE_PAUSE_VERSION}
etcd:${ETCD_VERSION}
)

for imageName in ${images[@]} 
do
  docker pull $ALIYUN_URL/$imageName
  docker tag $ALIYUN_URL/$imageName $GCR_URL/$imageName 
done

docker pull coredns/coredns:$DNS_VERSION
docker tag coredns/coredns:$DNS_VERSION $GCR_URL/coredns:$DNS_VERSION
