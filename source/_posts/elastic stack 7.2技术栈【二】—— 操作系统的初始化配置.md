---
title: elastic stack 7.2技术栈【二】操作系统的初始化配置
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
操作系统使用centos7 minimual版本。elasticsearch技术栈均采用 7.2版本，默认使用basic许可，可免费使用xpack部分安全管理服务。

## 部署使用的主机资源规划
使用3个主机节点
- 10.20.0.11 es-node1
- 10.20.0.12 es-node2
- 10.20.0.13 es-node3
## 升级至最新的系统小版本
```
yum -y update && hostnamectl set-hostname es-node1
```
- 在设置节点2，节点3时请注意变更为正确的主机名
## 禁用swap
因为es是在jvm中运行的，在内存使用上涉及不到使用swap。
```
swapoff -a
sed -i '/swap/d' /etc/fstab
```
## 系统可用资源限制
文件句柄与最大线程并发数量：
```
cat << EOF >>  /etc/security/limits.conf
*               soft    nofile           65535
*               hard    nofile           65535
*               soft    nproc           4096
*               hard    nproc           4096
*               soft    memlock         unlimited
*               hard    memlock         unlimited
EOF
```

<escape><!-- more --></escape>

## 虚拟内存
Elasticsearch uses a mmapfs directory by default to store its indices.
```
cat << EOF >> /etc/sysctl.conf
vm.max_map_count=262144
EOF

sysctl -p
```
MMap FS类型通过将文件映射到内存（mmap）来将分片索引存储在文件系统上（映射到Lucene MMapDirectory）。 内存映射使用进程中虚拟内存地址空间的一部分等于要映射的文件的大小。 在使用此类之前，请确保您已经拥有足够的虚拟地址空间。

## 创建es专用的系统用户
`useradd elastic`

## 配置firewalld防火墙规则
```
firewall-cmd --zone=public --permanent --add-rich-rule="rule family='ipv4' source address='10.20.0.0/24' accept"
firewall-cmd --reload
firewall-cmd --list-all
```
## 关闭selinux
```
setenforce 0
sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config
```
## 配置/etc/hosts
```
cat << EOF >> /etc/hosts
10.20.0.11  es-node1
10.20.0.12  es-node2
10.20.0.13  es-node3
EOF
```
重启系统验证各项配置生效后，继续本系列文章的下面章节的配置。