---
title: zabbix邮件报警
date: 2019-06-17 08:50:31
tags: 
- CentOS
- Zabbix
categories: 
- CentOS 
- Zabbix 
---

# 邮件报警情况分类

- 第一种情况：Zabbix服务端只是单纯的发送报警邮件到指定邮箱，发送报警邮件的这个邮箱账号是Zabbix服务端的本地邮箱账号（例如：root@localhost.localdomain），只能发送，不能接收外部邮件。
- 第二种情况：使用一个可以在互联网上正常收发邮件的邮箱账号（例如：xxx@163.com），通过在Zabbix服务端中设置，使其能够发送报警邮件到指定邮箱。

此两种方法，优先使用第一种方法，(收件人邮箱需要添加白名单)

<escape><!-- more --></escape>

# 使用Zabbix服务端本地邮箱账号发送邮件

## 1. 安装sendmail或者postfix

```bash
# 以sendmail为例，sendmail和postfix只需要安装一个并开启服务即可
[root@localhost ~]# yum install sendmail
[root@localhost ~]# systemctl start sendmail.service
[root@localhost ~]# systemctl enable sendmail.service
[root@localhost ~]# systemctl daemon-reload
```

## 2. 安装邮件发送工具mailx

```bash
[root@localhost ~]# yum install mailx
```

## 3. 测试发送邮件

```bash
[root@localhost ~]# echo "zabbix test mail" | mail -s "zabbix" 1103324414@qq.com
```

![](/zabbix_email/微信截图_20190615132406.png)

## 4. 配置Zabbix服务端邮件报警

管理，报警媒介类型，把自带的三个全都给禁用，然后右上角“创建媒体类型”。

![](/zabbix_email/微信截图_20190615132730.png)

注意：若上图中的127.0.0.1填写成localhost的话，发送邮件时则会报错：cannot connect to SMTP server [localhost]: cannot connect to [[localhost]:25]: [111] Connection refused

备注：SMTP服务器和SMPT HELO填写的是Zabbix监控端主机名称，建议修改，否则使用默认的localhost.localdomain发送邮件会被当做垃圾邮件拦截。

## 5. 设置Zabbix用户报警邮箱地址

管理，用户，点击Admin，点击报警媒介，点击添加，在类型中选择上一步添加的媒体类型，在这里选择：“邮件报警”，在收件人中输入收件人邮箱，然后点击添加。

![](/zabbix_email/微信截图_20190615134430.png)


## 5. 设置Zabbix触发报警的动作

配置，动作，右上角创建动作，如图所示：

![](/zabbix_email/11.png)

![](/zabbix_email/22.png)

![](/zabbix_email/33.png)

![](/zabbix_email/33-1.png)

```text
名称：Action-Email
默认标题：故障{TRIGGER.STATUS},服务器:{HOSTNAME1}发生: {TRIGGER.NAME}故障!
消息内容：
        告警主机:{HOSTNAME1}
        告警时间:{EVENT.DATE} {EVENT.TIME}
        告警等级:{TRIGGER.SEVERITY}
        告警信息: {TRIGGER.NAME}
        告警项目:{TRIGGER.KEY1}
        问题详情:{ITEM.NAME}:{ITEM.VALUE}
        当前状态:{TRIGGER.STATUS}:{ITEM.VALUE1}
        事件ID:{EVENT.ID}


恢复主题：恢复{TRIGGER.STATUS}, 服务器:{HOSTNAME1}: {TRIGGER.NAME}已恢复!
恢复信息：
        告警主机:{HOSTNAME1}
        告警时间:{EVENT.DATE} {EVENT.TIME}
        告警等级:{TRIGGER.SEVERITY}
        告警信息: {TRIGGER.NAME}
        告警项目:{TRIGGER.KEY1}
        问题详情:{ITEM.NAME}:{ITEM.VALUE}
        当前状态:{TRIGGER.STATUS}:{ITEM.VALUE1}
        事件ID:{EVENT.ID}
```

## 6. 测试Zabbix报警
```bash
# 停止zabbix-agent
[root@localhost ~]# systemctl stop zabbix-agent.service 
```
报表，动作日志：
![](/zabbix_email/微信截图_20190615135509.png)

```bash
# 恢复启动zabbix-agent
[root@localhost ~]# systemctl start zabbix-agent.service 
```

![](/zabbix_email/微信截图_20190615135616.png)

## 7. 问题
1. 需要先配置好监控主机，尤其是监控项：Agent ping，不然触发动作和测试报警都需要根据实际情况而定
2. 在web界面看到报警邮件已送达，但是邮箱里并没有收到邮件，垃圾箱中也没有。
但是文件/var/spool/mail/root中有相应的报错信息，暂时不知道如何处理。
解决办法：因为被收件邮箱给拦截了，需要添加发件人白名单才能收到邮件：
zabbix@localhost.localdomain和zabbix@127.0.0.1

# 使用外部邮箱账号发送报警邮件设置

使用外部邮箱账号时，不需要启动sendmail或者postfix。如果在sendmail或者postfix启动的同时使用外部邮箱发送报警邮件，首先会读取外部邮箱。

## 1. 停用sendmail或者postfix
```bash
# 以sendmail为例，sendmail和postfix只需要安装一个并停用服务即可
[root@localhost ~]# systemctl stop sendmail.service
[root@localhost ~]# systemctl disable sendmail.service
[root@localhost ~]# systemctl daemon-reload
```

## 2. 安装邮件发送工具mailx

```bash
[root@localhost ~]# yum install mailx
```

## 3.  配置Zabbix服务端外部邮箱
```bash
[root@localhost ~]# vim /etc/mail.rc 
set sendcharsets=iso-8859-1,utf-8
set from=payment@ejubei.cn
set smtp=smtp.mxhichina.com
set smtp-auth-user=payment@ejubei.cn
set smtp-auth-password=xxxxxxxxx
set smtp-auth=login 
```

## 4. 测试发送邮件

```bash
[root@localhost ~]# echo "zabbix test mail" | mail -s "zabbix" 1103324414@qq.com
```

![](/zabbix_email/微信截图_20190615144629.png)

## 5. 配置Zabbix服务端邮件报警

管理，报警媒介类型，把自带的三个全都给禁用，然后右上角“创建媒体类型”。

![](/zabbix_email/微信截图_20190615144834.png)

## 6. 设置Zabbix用户报警邮箱地址

管理，用户，点击Admin，点击报警媒介，点击添加，在类型中选择上一步添加的媒体类型，在这里选择：“Sendmail”，在收件人中输入收件人邮箱，然后点击添加。

![](/zabbix_email/微信截图_20190615144959.png)

## 7. 设置Zabbix触发报警的动作

配置，动作，右上角创建动作，如图所示：

![](/zabbix_email/微信截图_20190615145253.png)

![](22.png)

![](/zabbix_email/微信截图_20190615145423.png)

![](/zabbix_email/微信截图_20190615145321.png)

```text
名称：Action-Email
默认标题：故障{TRIGGER.STATUS},服务器:{HOSTNAME1}发生: {TRIGGER.NAME}故障!
消息内容：
        告警主机:{HOSTNAME1}
        告警时间:{EVENT.DATE} {EVENT.TIME}
        告警等级:{TRIGGER.SEVERITY}
        告警信息: {TRIGGER.NAME}
        告警项目:{TRIGGER.KEY1}
        问题详情:{ITEM.NAME}:{ITEM.VALUE}
        当前状态:{TRIGGER.STATUS}:{ITEM.VALUE1}
        事件ID:{EVENT.ID}


恢复主题：恢复{TRIGGER.STATUS}, 服务器:{HOSTNAME1}: {TRIGGER.NAME}已恢复!
恢复信息：
        告警主机:{HOSTNAME1}
        告警时间:{EVENT.DATE} {EVENT.TIME}
        告警等级:{TRIGGER.SEVERITY}
        告警信息: {TRIGGER.NAME}
        告警项目:{TRIGGER.KEY1}
        问题详情:{ITEM.NAME}:{ITEM.VALUE}
        当前状态:{TRIGGER.STATUS}:{ITEM.VALUE1}
        事件ID:{EVENT.ID}
```

## 8. 添加Zabbix服务端邮件发送脚本

```bash
# 查看默认情况下脚本存放路径
[root@localhost ~]# cat /etc/zabbix/zabbix_server.conf | grep 'alert'
AlertScriptsPath=/usr/lib/zabbix/alertscripts
[root@localhost ~]# cd /usr/lib/zabbix/alertscripts
[root@localhost alertscripts]# vim sendmail.sh 
#!/bin/bash

messages=`echo $3 | tr '\r\n' '\n'`
subject=`echo $2 | tr '\r\n' '\n'`
echo "${messages}" | mail -s "${subject}" $1 >>/tmp/sendmail.log 2>&1

[root@localhost ~]# chown zabbix.zabbix /usr/lib/zabbix/alertscripts/sendmail.sh
[root@localhost ~]# chmod +x /usr/lib/zabbix/alertscripts/sendmail.sh

[root@localhost ~]# chown zabbix.zabbix /tmp/sendmail.log
```

## 9. 测试Zabbix报警

```bash
# 停止zabbix-agent
[root@localhost ~]# systemctl stop zabbix-agent.service 
```
报表，动作日志：
![](/zabbix_email/微信截图_20190615150232.png)

```bash
# 恢复启动zabbix-agent
[root@localhost ~]# systemctl start zabbix-agent.service 
```

![](/zabbix_email/微信截图_20190615150303.png)

## 10. 问题

1. 需要先配置好监控主机，尤其是监控项：Agent ping，不然触发动作和测试报警都需要根据实际情况而定

# 若zabbix部署在阿里云主机上的问题处理

因为阿里云主机默认屏蔽25端口，经测试可以使用ssl的465端口，所以此时采用第二种方法。但是就算使用第二种方法也得做一些其他额外的操作，否则zabbix上提示邮件已送达，但是邮箱收不到邮件。

这个额外的办法就是使用465端口来发邮件需要使得ssl证书认证。

## 1. 关闭其它邮件工具
```bash
[root@localhost ~]# systemctl stop sendmail.service
[root@localhost ~]# systemctl stop postfix.service
```

## 2. 安装mailx
```bash
[root@localhost ~]# yum install mailx
```

## 3. 注册使用阿里云企业邮箱
该步骤实现完成，接下来的步骤都是使用该邮箱作为发件箱

## 4. 请求数字证书
因为使用的发件箱是阿里云的企业邮箱，所以向阿里云请求证书，其他步骤操作类似。

```bash
[root@localhost ~]# mkdir .certs
[root@localhost ~]# echo -n | openssl s_client -connect smtp.mxhichina.com:465 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /root/.certs/aliyun.crt
[root@localhost ~]# certutil -A -n "GeoTrust SSL CA" -t "C,," -d /root/.certs -i /root/.certs/aliyun.crt
[root@localhost ~]# certutil -A -n "GeoTrust Global CA" -t "C,," -d /root/.certs -i /root/.certs/aliyun.crt
[root@localhost ~]# certutil -A -n "GeoTrust SSL CA - G3" -t "Pu,Pu,Pu" -d /root/.certs/./ -i /root/.certs/aliyun.crt
Notice: Trust flag u is set automatically if the private key is present.
[root@localhost ~]# ls /root/.certs/
aliyun.crt  cert8.db  key3.db  secmod.db
[root@localhost ~]# certutil -L -d /root/.certs

Certificate Nickname                                         Trust Attributes
                                                             SSL,S/MIME,JAR/XPI

GeoTrust SSL CA                                              P,P,P
```

## 5. 配置/etc/mail.rc
```bash
set sendcharsets=iso-8859-1,utf-8
set from=alram@lrcq.com.cn
set smtp="smtps://smtp.mxhichina.com:465"
set smtp-auth-user=alram@lrcq.com.cn
set smtp-auth-password=xxxxxxxxxxx
set smtp-auth=login
set ssl-verify=ignore
set nss-config-dir=/root/.certs
```

## 6. 发送邮件测试
```bash
[root@localhost ~]# echo "邮件正文" | mail -s "邮件主题" 1103324414@qq.com
```

## 7. 证书权限处理
这个证书文件是给zabbix用户使用的，如果是在/root/.certs目录下，zabbix用户无法访问，发送邮件时会出现：Error initializing NSS: Unknown error -8015.
此时需要把证书移动到zabbix用户可以访问你的地方，比如移动到/etc/zabbix/目录下
```bash
[root@localhost ~]# mv /root/.certs /etc/zabbix/.
# 修改/etc/mail.rc文件中的证书路径
[root@localhost ~]# vim /etc/mail.rc
set nss-config-dir=/etc/zabbix/.certs
```

## 8. 其他操作
1. 管理，报警媒介类型，创建媒介类型

![](/zabbix_email/01.png)

2. 配置，用户，点击“Admin”，报警媒介，添加
多次添加则可以添加多个收件人

![](/zabbix_email/02.png)

3. 配置，动作，创建动作

![](/zabbix_email/03.png)

![](/zabbix_email/04.png)

![](/zabbix_email/05.png)

![](/zabbix_email/06.png)

