---
title: Linux日志切割方法[Logrotate、python、shell实现方式]
top: 
date: 
tags: 
- shell
- Linux 
categories: 
- shell
- Linux 
password: 
---
**Linux日志切割方法[Logrotate、python、shell实现方式]**

​      对于Linux系统安全来说，日志文件是极其重要的工具。不知为何，我发现很多运维同学的服务器上都运行着一些诸如每天切分Nginx日志之类的cron脚本，大家似乎遗忘了Logrotate，争相发明自己的轮子，这真是让人沮丧啊！就好比明明身边躺着现成的性感美女，大家却忙着自娱自乐，罪过！logrotate程序是一个日志文件管理工具。用于分割日志文件，删除旧的日志文件，并创建新的日志文件，起到“转储”作用。可以节省磁盘空间。下面就对logrotate日志轮转操作做一梳理记录。

**1、什么是轮转？**

**日志轮循（轮转）：日志轮转，切割，备份，归档**

## **2、为什么需要轮转？**

☆ 避免日志过大占满/var/log的文件系统 

☆ 方便日志查看 ☆ 将丢弃系统中最旧的日志文件，以节省空间 ☆ 日志轮转的程序是logrotate 

☆ logrotate本身不是系统守护进程，它是通过计划任务crond每天执行

<escape><!-- more --></escape>

## **3、安装与配置logrotate**

```shell
 yum install logrotate -y
```

 3.1、配置文件介绍

Linux系统默认安装logrotate工具，它默认的配置文件在：

```shell
#/etc/logrotate.conf
#/etc/logrotate.d/
```

logrotate.conf  是主要的配置文件，logrotate.d  是一个目录，该目录里的所有文件都会被主动的读入/etc/logrotate.conf中执行。另外，如果 /etc/logrotate.d/  里面的文件中没有设定一些细节，则会以/etc/logrotate.conf这个文件的设定来作为默认值。

logrotate是基于cron来运行的，其脚本是/etc/cron.daily/logrotate，日志轮转是系统自动完成的。实际运行时，Logrotate会调用配置文件/etc/logrotate.conf。可以在/etc/logrotate.d目录里放置自定义好的配置文件，用来覆盖Logrotate的缺省值。

```shell
[root@huanqiu_web1 ~]# cat /etc/cron.daily/logrotate
#!/bin/sh

/usr/sbin/logrotate /etc/logrotate.conf >/dev/null 2>&1
EXITVALUE=$?
if [ $EXITVALUE != 0 ]; then 
	/usr/bin/logger -t logrotate "ALERT exited abnormally with [$EXITVALUE]"
fi
exit 0
```

**注意：如果等不及cron自动执行日志轮转，想手动强制切割日志，需要加 -f 参数；不过正式执行前最好通过Debug选项来验证一下（-d参数），这对调试也很重要**！

```shell
# /usr/sbin/logrotate -f /etc/logrotate.d/nginx
# /usr/sbin/logrotate -d -f /etc/logrotate.d/nginx
```

**logrotate命令格式**


```shell
logrotate [OPTION...] <configfile>
-d, --debug ：debug模式，测试配置文件是否有错误。
-f, --force ：强制转储文件。
-m, --mail=command ：压缩日志后，发送日志到指定邮箱。
-s, --state=statefile ：使用指定的状态文件。
-v, --verbose ：显示转储过程。
```

**根据日志切割设置进行操作，并显示详细信息**


```shell
[root@huanqiu_web1 ~]# /usr/sbin/logrotate -v /etc/logrotate.conf
[root@huanqiu_web1 ~]# /usr/sbin/logrotate -v /etc/logrotate.d/php
```

**根据日志切割设置进行执行，并显示详细信息,但是不进行具体操作，debug模式**


```shell
[root@huanqiu_web1 ~]# /usr/sbin/logrotate -d /etc/logrotate.conf
[root@huanqiu_web1 ~]# /usr/sbin/logrotate -d /etc/logrotate.d/nginx
```

**查看各log文件的具体执行情况**


```shell
[root@fangfull_web1 ~]# cat /var/lib/logrotate.status
```

### 3.2、logrotate配置文件


```shell
# vim /etc/logrotate.conf
1 # see "man logrotate" for details
2 # rotate log files weekly
3 weekly
4 # 以7天为一个周期(每周轮转)syslog子配置文件：
5 # keep 4 weeks worth of backlogs
6 rotate 4
# 一次将存储4个归档日志。对于第五个归档，时间最久的归档将被删除
7 8
# create new (empty) log files after rotating old ones
9 create
# 当老的转储文件被归档后,创建一个新的空的转储文件重新记录,权限和原来的转储文件权限一样
10
11 # use date as a suffix of the rotated file
12 dateext
# 用日期来做轮转之后的文件的后缀名
13
14 # uncomment this if you want your log files compressed
15 #compress
# 指定不压缩转储文件,如需压缩去掉注释就可以了，主要是通过gzip压缩
16
17 # RPM packages drop log rotation information into this directory
18 include /etc/logrotate.d
# 加载外部目录
19
20 # no packages own wtmp and btmp -- we'll rotate them here
21 /var/log/wtmp {
22 monthly 表示此文件是每月轮转，而不会用到上面的每周轮转
23 create 0664 root utmp 轮转之后创建新文件，权限是0664，属于root用户和utmp组
24 minsize 1M 文件大于1M，而且周期到了，才会轮转
# size 1M 文件大小大于1M立马轮转，不管有没有到周期
25 rotate 1 保留1份日志文件，每1个月备份一次日志文件
26 }
27
28 /var/log/btmp {
29 missingok 如果日志文件不存在，不报错
30 monthly
31 create 0600 root utmp
32 rotate 1
33 }
34
35 # system-specific logs may be also be configured here.
```

### 3.3、syslog 子配置文件


```shell
[root@yunwei ~]# cat /etc/logrotate.d/syslog
//这个子配置文件，没有指定的参数都会以默认方式轮转
/var/log/cron
/var/log/maillog
/var/log/messages
/var/log/secure
/var/log/spooler
{
sharedscripts
不管有多少个文件待轮转，prerotate 和 postrotate 代码只执行一次
postrotate日志轮转常见参数：
4、实践：SSH服务日志轮转
要求：
☆ 每天进行轮转，保留5天的日志文件
☆ 日志文件大小大于5M进行轮转，不管是否到轮转周期
思路：
☆ 将ssh服务的日志单独记录 /var/log/ssh.log
☆ 修改logrotate程序的主配置文件或者在/etc/logrotate.d/目录创建一个文件
轮转完后执行postrotate 和 endscript 之间的shell代码
/bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true
上面这一句话表示轮转后对rsyslog的pid进行刷新（但pid其实不变)
endscript
} 
思考：
为什么轮转后需要对rsyslog的pid进行刷新呢？
```

### 3.4、日志轮转常见参数


```conf
常用的指令解释，这些指令都可以在man logrotate 中找得到。
daily 指定转储周期为每天
monthly 指定转储周期为每月
weekly <-- 每周轮转一次(monthly)
rotate 4 <-- 同一个文件最多轮转4次，4次之后就删除该文件
create 0664 root utmp <-- 轮转之后创建新文件，权限是0664，属于root用户和utmp组
dateext <-- 用日期来做轮转之后的文件的后缀名
compress <-- 用gzip对轮转后的日志进行压缩
minsize 30K <-- 文件大于30K，而且周期到了，才会轮转
size 30k <-- 文件必须大于30K才会轮转，而且文件只要大于30K就会轮转不管周期是否已到
missingok <-- 如果日志文件不存在，不报错
notifempty <-- 如果日志文件是空的，不轮转
delaycompress <-- 下一次轮转的时候才压缩
sharedscripts <-- 不管有多少文件待轮转，prerotate和postrotate 代码只执行一次
prerotate <-- 如果符合轮转的条件
则在轮转之前执行prerotate和endscript 之间的shell代码
postrotate <-- 轮转完后执行postrotate 和 endscript 之间的shell代码
```

### 3.5、logrotate默认生效以及相关配置进行解释


```shell
Logrotate是基于CRON来运行的，其脚本是/etc/cron.daily/logrotate，
实际运行时，Logrotate会调用配置文件/etc/logrotate.conf。
[root@test ~]# cat /etc/cron.daily/logrotate
#!/bin/sh

/usr/sbin/logrotate /etc/logrotate.conf
EXITVALUE=$?
if [ $EXITVALUE != 0 ]; then
    /usr/bin/logger -t logrotate "ALERT exited abnormally with [$EXITVALUE]"
fi
exit 0
   
  
Logrotate是基于CRON运行的，所以这个时间是由CRON控制的，
具体可以查询CRON的配置文件/etc/anacrontab（老版本的文件是/etc/crontab）
[root@test ~]# cat /etc/anacrontab
# /etc/anacrontab: configuration file for anacron
   
# See anacron(8) and anacrontab(5) for details.
   
SHELL=/bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
# the maximal random delay added to the base delay of the jobs
RANDOM_DELAY=45                                                                  
//这个是随机的延迟时间，表示最大45分钟
# the jobs will be started during the following hours only
START_HOURS_RANGE=3-22                                                          
 //这个是开始时间
   
#period in days   delay in minutes   job-identifier   command
1 5 cron.daily    nice run-parts /etc/cron.daily
7 25  cron.weekly   nice run-parts /etc/cron.weekly
@monthly 45 cron.monthly    nice run-parts /etc/cron.monthly
   
第一个是Recurrence period
第二个是延迟时间
所以cron.daily会在3:22+(5,45)这个时间段执行，/etc/cron.daily是个文件夹
   
通过默认/etc/anacrontab文件配置，会发现logrotate自动切割日志文件的默认时间是凌晨3点多。
   
=====================================================================================
现在需要将切割时间调整到每天的晚上12点，即每天切割的日志是前一天的0-24点之间的内容。
操作如下：
[root@kevin ~]# mv /etc/anacrontab /etc/anacrontab.bak          //取消日志自动轮转的设置
 
[root@G6-bs02 logrotate.d]# cat nstc_nohup.out
/data/nstc/nohup.out {
rotate 30
dateext
daily
copytruncate
compress
notifempty
missingok
}
 
[root@G6-bs02 logrotate.d]# cat syslog
/var/log/cron
/var/log/maillog
/var/log/messages
/var/log/secure
/var/log/history
{
    sharedscripts
    compress
    rotate 30
    daily
    dateext
    postrotate
    /bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true
    endscript
}
 
结合crontab进行自定义的定时轮转操作
[root@kevin ~]# crontab -l
#log logrotate
59 23 * * * /usr/sbin/logrotate -f /etc/logrotate.d/syslog >/dev/null 2>&1
59 23 * * * /usr/sbin/logrotate -f /etc/logrotate.d/nstc_nohup.out >/dev/null 2>&1
 
[root@G6-bs02 ~]# ll /data/nstc/nohup.out*
-rw------- 1 app app 33218 1月  25 09:43 /data/nstc/nohup.out
-rw------- 1 app app 67678 1月  25 23:59 /data/nstc/nohup.out-20180125.gz
```

## **4、相关案例**

### 4.1、logrotate实现Nginx日志切割



```shell
[root@master-server ~]# vim /etc/logrotate.d/nginx
/usr/local/nginx/logs/*.log {
daily
rotate 7
missingok
notifempty
dateext
sharedscripts
postrotate
    if [ -f /usr/local/nginx/logs/nginx.pid ]; then
        kill -USR1 `cat /usr/local/nginx/logs/nginx.pid`
    fi
endscript
}
kill -USR1 指的是Nginx平滑重启
```

### 4.2、shell脚本实现Nginx日志切割


```shell
[root@bastion-IDC ~]# vim /usr/local/sbin/logrotate-nginx.sh
#!/bin/bash
#创建转储日志压缩存放目录
mkdir -p /data/nginx_logs/days
#手工对nginx日志进行切割转换
/usr/sbin/logrotate -vf /etc/logrotate.d/nginx
#当前时间
time=$(date -d "yesterday" +"%Y-%m-%d")
#进入转储日志存放目录
cd /data/nginx_logs/days
#对目录中的转储日志文件的文件名进行统一转换
for i in $(ls ./ | grep "^\(.*\)\.[[:digit:]]$")
do
mv ${i} ./$(echo ${i}|sed -n 's/^\(.*\)\.\([[:digit:]]\)$/\1/p')-$(echo $time)
done
#对转储的日志文件进行压缩存放，并删除原有转储的日志文件，只保存压缩后的日志文件。以节约存储空间
for i in $(ls ./ | grep "^\(.*\)\-\([[:digit:]-]\+\)$")
do
tar jcvf ${i}.bz2 ./${i}
rm -rf ./${i}
done
#只保留最近7天的压缩转储日志文件
find /data/nginx_logs/days/* -name "*.bz2" -mtime 7 -type f -exec rm -rf {} \;
```

**crontab定时执行**



```shell
[root@bastion-IDC ~# crontab -e
#logrotate
0 0 * * * /bin/bash -x /usr/local/sbin/logrotate-nginx.sh > /dev/null 2>&1
```

**手动执行脚本**

 

```shell
[root@bastion-IDC ~]# /bin/bash -x /usr/local/sbin/logrotate-nginx.sh
[root@bastion-IDC ~]# cd /data/nginx_logs/days
[root@bastion-IDC days]# lshuantest.access_log-2017-01-18.bz2
```



### 4.3、PHP日志切割


```shell
[root@huanqiu_web1 ~]# cat /etc/logrotate.d/php
/Data/logs/php/*log {
    daily
    rotate 365
    missingok
    notifempty
    compress
    dateext
    sharedscripts
    postrotate
        if [ -f /Data/app/php5.6.26/var/run/php-fpm.pid ]; then
            kill -USR1 `cat /Data/app/php5.6.26/var/run/php-fpm.pid`
        fi
    endscript
    postrotate
        /bin/chmod 644 /Data/logs/php/*gz
    endscript
}
 
[root@huanqiu_web1 ~]# ll /Data/app/php5.6.26/var/run/php-fpm.pid
-rw-r--r-- 1 root root 4 Dec 28 17:03 /Data/app/php5.6.26/var/run/php-fpm.pid
 
[root@huanqiu_web1 ~]# cd /Data/logs/php
[root@huanqiu_web1 php]# ll
total 25676
-rw-r--r-- 1 root   root         0 Jun  1  2016 error.log
-rw-r--r-- 1 nobody nobody     182 Aug 30  2015 error.log-20150830.gz
-rw-r--r-- 1 nobody nobody     371 Sep  1  2015 error.log-20150901.gz
-rw-r--r-- 1 nobody nobody     315 Sep  7  2015 error.log-20150907.gz
.........
```

### 4.4、linux系统日志切割


```shell
[root@huanqiu_web1 ~]# cat /etc/logrotate.d/syslog
/var/log/cron
/var/log/maillog
/var/log/messages
/var/log/secure
/var/log/spooler
{
    sharedscripts
    postrotate
    /bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true
    endscript
}
 
[root@huanqiu_web1 ~]# ll /var/log/messages*
-rw------- 1 root root 34248975 Jan 19 18:42 /var/log/messages
-rw------- 1 root root 51772994 Dec 25 03:11 /var/log/messages-20161225
-rw------- 1 root root 51800210 Jan  1 03:05 /var/log/messages-20170101
-rw------- 1 root root 51981366 Jan  8 03:36 /var/log/messages-20170108
-rw------- 1 root root 51843025 Jan 15 03:40 /var/log/messages-20170115
[root@huanqiu_web1 ~]# ll /var/log/cron*
-rw------- 1 root root 2155681 Jan 19 18:43 /var/log/cron
-rw------- 1 root root 2932618 Dec 25 03:11 /var/log/cron-20161225
-rw------- 1 root root 2939305 Jan  1 03:06 /var/log/cron-20170101
-rw------- 1 root root 2951820 Jan  8 03:37 /var/log/cron-20170108
-rw------- 1 root root 3203992 Jan 15 03:41 /var/log/cron-20170115
[root@huanqiu_web1 ~]# ll /var/log/secure*
-rw------- 1 root root  275343 Jan 19 18:36 /var/log/secure
-rw------- 1 root root 2111936 Dec 25 03:06 /var/log/secure-20161225
-rw------- 1 root root 2772744 Jan  1 02:57 /var/log/secure-20170101
-rw------- 1 root root 1115543 Jan  8 03:26 /var/log/secure-20170108
-rw------- 1 root root  731599 Jan 15 03:40 /var/log/secure-20170115
[root@huanqiu_web1 ~]# ll /var/log/spooler*
-rw------- 1 root root 0 Jan 15 03:41 /var/log/spooler
-rw------- 1 root root 0 Dec 18 03:21 /var/log/spooler-20161225
-rw------- 1 root root 0 Dec 25 03:11 /var/log/spooler-20170101
-rw------- 1 root root 0 Jan  1 03:06 /var/log/spooler-20170108
-rw------- 1 root root 0 Jan  8 03:37 /var/log/spooler-20170115
```

### 4.5、Tomcat日志切割

 

```shell
[root@huanqiu_web1 ~]# cat /etc/logrotate.d/syslog
/var/log/cron
/var/log/maillog
/var/log/messages
/var/log/secure
/var/log/spooler
{
    sharedscripts
    postrotate
    /bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true
    endscript
}
 
[root@huanqiu_web1 ~]# ll /var/log/messages*
-rw------- 1 root root 34248975 Jan 19 18:42 /var/log/messages
-rw------- 1 root root 51772994 Dec 25 03:11 /var/log/messages-20161225
-rw------- 1 root root 51800210 Jan  1 03:05 /var/log/messages-20170101
-rw------- 1 root root 51981366 Jan  8 03:36 /var/log/messages-20170108
-rw------- 1 root root 51843025 Jan 15 03:40 /var/log/messages-20170115
[root@huanqiu_web1 ~]# ll /var/log/cron*
-rw------- 1 root root 2155681 Jan 19 18:43 /var/log/cron
-rw------- 1 root root 2932618 Dec 25 03:11 /var/log/cron-20161225
-rw------- 1 root root 2939305 Jan  1 03:06 /var/log/cron-20170101
-rw------- 1 root root 2951820 Jan  8 03:37 /var/log/cron-20170108
-rw------- 1 root root 3203992 Jan 15 03:41 /var/log/cron-20170115
[root@huanqiu_web1 ~]# ll /var/log/secure*
-rw------- 1 root root  275343 Jan 19 18:36 /var/log/secure
-rw------- 1 root root 2111936 Dec 25 03:06 /var/log/secure-20161225
-rw------- 1 root root 2772744 Jan  1 02:57 /var/log/secure-20170101
-rw------- 1 root root 1115543 Jan  8 03:26 /var/log/secure-20170108
-rw------- 1 root root  731599 Jan 15 03:40 /var/log/secure-20170115
[root@huanqiu_web1 ~]# ll /var/log/spooler*
-rw------- 1 root root 0 Jan 15 03:41 /var/log/spooler
-rw------- 1 root root 0 Dec 18 03:21 /var/log/spooler-20161225
-rw------- 1 root root 0 Dec 25 03:11 /var/log/spooler-20170101
-rw------- 1 root root 0 Jan  1 03:06 /var/log/spooler-20170108
-rw------- 1 root root 0 Jan  8 03:37 /var/log/spooler-20170115
```

### 4.6、使用python脚本进行jumpserver日志切割


```shell
[root@test-vm01 mnt]# cat log_rotate.py
#!/usr/bin/env python
   
import datetime,os,sys,shutil
   
log_path = '/opt/jumpserver/logs/'
log_file = 'jumpserver.log'
   
yesterday = (datetime.datetime.now() - datetime.timedelta(days = 1))
   
try:
    os.makedirs(log_path + yesterday.strftime('%Y') + os.sep + yesterday.strftime('%m'))
except OSError,e:
    print
    print e
    sys.exit()
   
   
shutil.move(log_path + log_file,log_path \
            + yesterday.strftime('%Y') + os.sep \
            + yesterday.strftime('%m') + os.sep \
            + log_file + '_' + yesterday.strftime('%Y%m%d') + '.log')
   
   
os.popen("sudo /opt/jumpserver/service.sh restart")
 
手动执行这个脚本：
[root@test-vm01 mnt]# chmod 755 log_rotate.py
[root@test-vm01 mnt]# python log_rotate.py
 
查看日志切割后的效果：
[root@test-vm01 mnt]# ls /opt/jumpserver/logs/
2017  jumpserver.log 
[root@test-vm01 mnt]# ls /opt/jumpserver/logs/2017/
09
[root@test-vm01 mnt]# ls /opt/jumpserver/logs/2017/09/
jumpserver.log_20170916.log
 
然后做每日的定时切割任务：
[root@test-vm01 mnt]# crontab -e
30 1 * * * /usr/bin/python /mnt/log_rotate.py > /dev/null 2>&1
```

### 4.7、使用python脚本进行Nginx日志切割



```shell
[root@test-vm01 mnt]# vim log_rotate.py
#!/usr/bin/env python
   
import datetime,os,sys,shutil
   
log_path = '/app/nginx/logs/'
log_file = 'www_access.log'
   
yesterday = (datetime.datetime.now() - datetime.timedelta(days = 1))
   
try:
    os.makedirs(log_path + yesterday.strftime('%Y') + os.sep + yesterday.strftime('%m'))
except OSError,e:
    print
    print e
    sys.exit()
   
   
shutil.move(log_path + log_file,log_path \
            + yesterday.strftime('%Y') + os.sep \
            + yesterday.strftime('%m') + os.sep \
            + log_file + '_' + yesterday.strftime('%Y%m%d') + '.log')
   
   
os.popen("sudo kill -USR1 `cat /app/nginx/logs/nginx.pid`")
```

## **5、logrotate无法自动轮询日志的解决办法**

起始原因：使用logrotate轮询nginx日志，配置好之后，发现nginx日志连续两天没被切割，这是为什么呢？？然后开始检查日志切割的配置文件是否有问题，检查后确定配置文件一切正常。于是怀疑是logrotate预定的cron没执行，查看了cron的日志，发现有一条"Dec  7 04:02:01 www crond[18959]: (root) CMD (run-parts  /etc/cron.daily)"的日志，证明cron在04:02分时已经执行/etc/cron.daily目录下的程序。接着查看/etc  /cron.daily/logrotate（这是logrotate自动轮转的脚本）的内容：

 

```shell
[root@huanqiu_test ~]# cat /etc/cron.daily/logrotate
#!/bin/sh

/usr/sbin/logrotate /etc/logrotate.conf >/dev/null 2>&1
EXITVALUE=$?
if [ $EXITVALUE != 0 ]; then
    /usr/bin/logger -t logrotate "ALERT exited abnormally with [$EXITVALUE]"
fi
exit 0
```

有发现异常，配置好的日志轮转操作都是由这个脚本完成的，一切运行正常，脚本应该就没问题。 直接执行命令：



```shell
[root@huanqiu_test ~]# /usr/sbin/logrotate /etc/logrotate.conf
```

这些系统日志是正常轮询了，但nginx日志却还是没轮询,接着强行启动记录文件维护操作，纵使logrotate指令认为没有需要，应该有可能是logroate认为nginx日志太小，不进行轮询。 故需要强制轮询，即在/etc/cron.daily/logrotate脚本中将 -t 参数替换成 -f 参数



```shell
[root@huanqiu_test ~]# cat /etc/cron.daily/logrotate
#!/bin/sh

/usr/sbin/logrotate /etc/logrotate.conf >/dev/null 2>&1
EXITVALUE=$?
if [ $EXITVALUE != 0 ]; then
    /usr/bin/logger -f logrotate "ALERT exited abnormally with [$EXITVALUE]"
fi
exit 0
```

**重启下cron服务**



```shell
[root@huanqiu_test ~]# /etc/init.d/crond restart
Stopping crond: [ OK ]Starting crond: [ OK ]
```