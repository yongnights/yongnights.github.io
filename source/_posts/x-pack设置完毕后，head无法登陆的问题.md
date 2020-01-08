---
title: x-pack设置完毕后，head无法登陆的问题
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
在elasticsearch.yml中添加如下三行配置
```
http.cors.enabled: true
http.cors.allow-origin: "*"
http.cors.allow-headers: Authorization,X-Requested-With,Content-Length,Content-Type
```

重启服务，并通过如下形式访问head端口
`http://192.168.36.61:9100/?auth_user=elastic&auth_password=passwd`