#!/bin/bash
systemctl disable firewalld.service
systemctl stop firewalld.service

yum install etcd -y
yum install docker -y

chkconfig docker on
service docker start

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
setenforce 0
yum install -y kubelet kubeadm kubectl
systemctl enable kubelet && systemctl start kubelet

systemctl daemon-reload 
systemctl enable kube-apiserver.service
systemctl start kube-apiserver.service
systemctl enable kube-controller-manager.service
systemctl start kube-controller-manager.service
systemctl enable kube-scheduler.service
systemctl start kube-scheduler.service


# docker pull mirrorgooglecontainers/kube-apiserver-amd64:v1.13.1
# docker pull mirrorgooglecontainers/kube-controller-manager-amd64:v1.13.1
# docker pull mirrorgooglecontainers/kube-scheduler-amd64:v1.13.1
# docker pull mirrorgooglecontainers/kube-proxy-amd64:v1.13.1

swapoff -a && sysctl -w vm.swappiness=0

cat << EOF | tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl -p /etc/sysctl.d/k8s.conf
