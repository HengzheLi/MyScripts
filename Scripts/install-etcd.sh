#!/bin/bash
yum install etcd -y

systemctl daemon-reload
systemctl enable etcd.service
systemctl start etcd.service
