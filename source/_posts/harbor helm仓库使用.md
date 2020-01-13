---
title: harbor helm仓库使用
top: 
date: 
tags: 
- Harbor
- Helm
categories: 
- Harbor
- Helm
password: 
---
harbor helm仓库使用

官方文档地址：https://github.com/goharbor/harbor

Monocular 从1.0 开始专注于helm 的UI展示，对于部署以及维护已经去掉了，官方也提供了相关的说明以及推荐了几个可选的部署工具，从使用以及架构上来说kubeapps 就是Monocular + helm 操作的集合，比Monocular早期版本有好多提升

# 安装
- 下载离线安装包
```bash
wget https://github.com/goharbor/harbor/releases/download/v1.9.3/harbor-offline-installer-v1.9.3.tgz
```

<escape><!-- more --></escape>

- 配置harbor

> 主要是harbor.cfg文件
目前主要配置hostname和port ,使用自己服务器的ip，修改默认端口号
```bash
hostname: 192.168.75.100
http:
  # port for http, default is 80. If https enabled, this port will redirect to https port
  port: 10000
```

- 生成docker-compose file
```bash
# 先安装docker-compose，地址：https://github.com/docker/compose/releases
# 需要docker-compose(1.18.0+)版本
curl -L https://github.com/docker/compose/releases/download/1.25.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# 查看docker-compose版本
[root@ks-allinone harbor]# docker-compose version
docker-compose version 1.25.0, build 0a186604
docker-py version: 4.1.0
CPython version: 3.7.4
OpenSSL version: OpenSSL 1.1.0l  10 Sep 2019

./install.sh   --with-clair --with-chartmuseum
```

- 使用
地址：http://192.168.75.100:10000
账号：admin
默认密码：Harbor12345

- 其他操作
```bash
# 安装helm
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash

# 安装push 插件
helm init 
helm plugin install https://github.com/chartmuseum/helm-push

# 查看安装的插件
helm plugin list
NAME    VERSION DESCRIPTION                      
push    0.7.1   Push chart package to ChartMuseum


# 添加harbor helm 私服
# 首先需要创建项目myrepo(当前设计的模式为public)
# chartrepo是必备的,不可缺少，不然就会推送到默认的library上面去了

helm repo add --username=admin --password=Harbor12345 myrepo http://192.168.75.100:10000/chartrepo/myrepo
"myrepo" has been added to your repositories

# or 添加特定仓库
helm repo add --username=admin --password=Harbor12345 myrepo https://xx.xx.xx.xx/chartrepo/myproject

# 创建demo
helm create app

	Creating app

# 推送到harbor,push
helm push --username=admin --password=Harbor12345 app myrepo
	Pushing app-0.1.0.tgz to myrepo...
	Done.
```

