---
title: 详细说明-CentOS7部署FastDFS+nginx模块
top: 
date: 
tags: 
- nginx
- FastDFS 
categories: 
- nginx
- FastDFS 
password: 
---
# 软件下载
```
# 已经事先把所需软件下载好并上传到/usr/local/src目录了
https://github.com/happyfish100/libfastcommon/archive/V1.0.43.tar.gz
https://github.com/happyfish100/fastdfs-nginx-module/archive/V1.22.tar.gz
https://github.com/happyfish100/fastdfs/archive/V6.06.tar.gz
https://github.com/happyfish100/fastdfs-client-java/archive/V1.28.tar.gz
https://openresty.org/download/openresty-1.15.8.3.tar.gz
```
# 基础环境设置
## 安装依赖组件
```
yum -y install  gcc gcc-c++ libevent
yum -y groupinstall 'Development Tools' 
```

`<escape><!-- more --></escape>`

## 安装libfastcommon
```
cd /usr/local/src
tar -zxvf libfastcommon-1.0.43.tar.gz
cd libfastcommon-1.0.43
./make.sh
./make.sh install

# 检查文件是否存在
[root@bogon libfastcommon-1.0.43]# ll /usr/lib64 | grep "libfastcommon.so" 
-rwxr-xr-x   1 root root  1035264 Apr  2 10:07 libfastcommon.so
[root@bogon libfastcommon-1.0.43]# ll /usr/lib | grep "libfastcommon.so"  
lrwxrwxrwx   1 root root    27 Apr  2 10:07 libfastcommon.so -> /usr/lib64/libfastcommon.so
```

## 安装fastdfs
```
cd /usr/local/src
tar -zxvf fastdfs-6.06.tar.gz
cd fastdfs-6.06
./make.sh
./make.sh install

# 安装成功后将解压目录下的conf下的俩文件拷贝到/etc/fdfs/下
cd conf
cp http.conf mime.types /etc/fdfs/
cd /etc/fdfs/
[root@bogon fdfs]# ll
total 68
-rw-r--r-- 1 root root  1909 Apr  2 10:15 client.conf.sample
-rw-r--r-- 1 root root   965 Apr  2 10:16 http.conf
-rw-r--r-- 1 root root 31172 Apr  2 10:16 mime.types
-rw-r--r-- 1 root root 10246 Apr  2 10:15 storage.conf.sample
-rw-r--r-- 1 root root   620 Apr  2 10:15 storage_ids.conf.sample
-rw-r--r-- 1 root root  9138 Apr  2 10:15 tracker.conf.sample
```

### fdfs_trackerd配置并启动
```
cd /etc/fdfs/
cp tracker.conf.sample tracker.conf
mkdir -p /opt/{fdfs_tracker,fdfs_storage,fdfs_storage_data}
vim tracker.conf
    base_path = /opt/fdfs_tracker

# 启动fdfs_trackerd
/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf start
# 查看端口号，验证启动情况
[root@bogon fdfs]# ps -ef | grep fdfs
root       2119      1  0 10:22 ?        00:00:00 /usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf start
[root@bogon fdfs]# ss -tulnp | grep 22122
tcp    LISTEN     0      128       *:22122                 *:*                   users:(("fdfs_trackerd",pid=2119,fd=5))

# 命令行选项
Usage: /usr/bin/fdfs_trackerd <config_file> [start|stop|restart]

# 注意：在/opt/fdfs_data目录下生成两个目录,一个是数据,一个是日志.
# 设置开机自启动
echo "/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf restart" | tee -a /etc/rc.d/rc.local
```
### fdfs_storaged配置并启动
```
cd /etc/fdfs/
cp storage.conf.sample storage.conf
vim storage.conf
    base_path = /opt/fdfs_storage # 注意,这个目录最好有大于50G的磁盘空间
    store_path0 = /opt/fdfs_storage_data # 若配置这个参数，则该目录为实际保存文件的路径
    tracker_server = 192.168.75.5:22122
# 启动fdfs_storaged
/usr/bin/fdfs_storaged /etc/fdfs/storage.conf start
[root@bogon fdfs]# ps -ef | grep "fdfs_storaged"
root       2194      1  7 10:36 ?        00:00:01 /usr/bin/fdfs_storaged /etc/fdfs/storage.conf start
[root@bogon fdfs]# ss -tulnp | grep "fdfs"
tcp    LISTEN     0      128       *:23000                 *:*                   users:(("fdfs_storaged",pid=2194,fd=5))
tcp    LISTEN     0      128       *:22122                 *:*                   users:(("fdfs_trackerd",pid=2119,fd=5))

# 命令行选项
Usage: /usr/bin/fdfs_trackerd <config_file> [start|stop|restart]
# 设置开机自启动
echo "/usr/bin/fdfs_storaged /etc/fdfs/storage.conf restart" | tee -a /etc/rc.d/rc.local
```

### 校验整合
要确定一下，storage是否注册到了tracker中去
```
/usr/bin/fdfs_monitor /etc/fdfs/storage.conf
```
成功后可以看到：ip_addr = 192.168.75.5  ACTIVE

### 使用FastDFS自带工具测试
```
cd /etc/fdfs/
cp client.conf.sample client.conf
vim client.conf
    base_path = /opt/fdfs_tracker #tracker服务器文件路径
    tracker_server = 192.168.75.5:22122 #tracker服务器IP地址和端口号
    http.tracker_server_port = 8080 # tracker服务器的http端口号,必须和tracker的设置对应起来
```
上传一张图片1.jpg到Centos服务器上的 /tmp 目录下，进行测试，命令如下：
```
/usr/bin/fdfs_test /etc/fdfs/client.conf upload /tmp/1.jpg
This is FastDFS client test program v6.06

Copyright (C) 2008, Happy Fish / YuQing

FastDFS may be copied only under the terms of the GNU General
Public License V3, which may be found in the FastDFS source kit.
Please visit the FastDFS Home Page http://www.fastken.com/ 
for more detail.

[2020-04-02 10:47:57] DEBUG - base_path=/opt/fdfs_tracker, connect_timeout=5, network_timeout=60, tracker_server_count=1, anti_steal_token=0, anti_steal_secret_key length=0, use_connection_pool=0, g_connection_pool_max_idle_time=3600s, use_storage_id=0, storage server id count: 0

tracker_query_storage_store_list_without_group: 
        server 1. group_name=, ip_addr=192.168.75.5, port=23000

group_name=group1, ip_addr=192.168.75.5, port=23000
storage_upload_by_filename
group_name=group1, remote_filename=M00/00/00/wKhLBV6FUl6AA0eTACSnIi51C7k037.jpg
source ip address: 192.168.75.5
file timestamp=2020-04-02 10:47:58
file size=2402082
file crc32=779422649
example file url: http://192.168.75.5:8080/group1/M00/00/00/wKhLBV6FUl6AA0eTACSnIi51C7k037.jpg
storage_upload_slave_by_filename
group_name=group1, remote_filename=M00/00/00/wKhLBV6FUl6AA0eTACSnIi51C7k037_big.jpg
source ip address: 192.168.75.5
file timestamp=2020-04-02 10:47:58
file size=2402082
file crc32=779422649
example file url: http://192.168.75.5:8080/group1/M00/00/00/wKhLBV6FUl6AA0eTACSnIi51C7k037_big.jpg

```
以上图中的文件地址：http://192.168.75.5:8080/group1/M00/00/00/wKhLBV6FUl6AA0eTACSnIi51C7k037.jpg对应storage服务器上的/opt/fdfs_storage_data/data/00/00/wKhLBV6FUl6AA0eTACSnIi51C7k037.jpg文件;

> 注意图片路径中的8080端口,这个是tracker的端口，

但是查看该目录，会有四个图片文件:
```
[root@bogon 00]# pwd
/opt/fdfs_storage_data/data/00/00
[root@bogon 00]# ll
total 4704
-rw-r--r-- 1 root root 2402082 Apr  2 10:47 wKhLBV6FUl6AA0eTACSnIi51C7k037_big.jpg
-rw-r--r-- 1 root root      49 Apr  2 10:47 wKhLBV6FUl6AA0eTACSnIi51C7k037_big.jpg-m
-rw-r--r-- 1 root root 2402082 Apr  2 10:47 wKhLBV6FUl6AA0eTACSnIi51C7k037.jpg
-rw-r--r-- 1 root root      49 Apr  2 10:47 wKhLBV6FUl6AA0eTACSnIi51C7k037.jpg-m
```

## FastDFS和nginx结合使用

### 在tracker上安装 nginx
在每个tracker上安装nginx的主要目的是做负载均衡及实现高可用。如果只有一台tracker服务器可以不配置nginx.
一个tracker对应多个storage，通过nginx对storage负载均衡;

### 在storage上安装nginx(openresty)
```
cd /usr/local/src/
tar -zxvf fastdfs-nginx-module-1.22.tar.gz
cd fastdfs-nginx-module-1.22/src
cp mod_fastdfs.conf /etc/fdfs/
vim /etc/fdfs/mod_fastdfs.conf
    base_path=/opt/fdfs_storage
    tracker_server=192.168.75.5:22122
    url_have_group_name = true #url中包含group名称
    store_path0=/opt/fdfs_storage_data #与storage.conf中的路径保持一致
```
```
yum -y install pcre pcre-devel openssl openssl-devel
cd /usr/local/src
tar -zxvf openresty-1.15.8.3.tar.gz
cd openresty-1.15.8.3
./configure \
    --with-luajit \
    --with-http_stub_status_module \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_gzip_static_module \
    --add-module=/usr/local/src/fastdfs-nginx-module-1.22/src
gmake
gmake install

# 启动
vim /usr/local/openresty/nginx/conf/nginx.conf
    error_log  logs/error.log;
    pid      logs/nginx.pid;
    server{
        server_name  192.168.75.5; 
    }
/usr/local/openresty/nginx/sbin/nginx -c /usr/local/openresty/nginx/conf/nginx.conf
# 浏览器访问，出现openresty欢迎页面

# 设置nginx开机启动
echo "/usr/local/openresty/nginx/sbin/nginx -c /usr/local/openresty/nginx/conf/nginx.conf" | tee -a /etc/rc.d/rc.local

vim /usr/local/openresty/nginx/conf/nginx.conf
    server{
        location /group1/M00/ {
            root /opt/fdfs_storage/data;
            ngx_fastdfs_module;
        }
    }

/usr/local/openresty/nginx/sbin/nginx -s reload

# 参考上面测试的那一步图片url地址：http://192.168.75.5:8080/group1/M00/00/00/wKhLBV6FUl6AA0eTACSnIi51C7k037.jpg
使用nginxf访问的话，实际地址是：http://192.168.75.5/group1/M00/00/00/wKhLBV6FUl6AA0eTACSnIi51C7k037.jpg
需要把tracker使用的8080端口去掉，否则无法访问
```
```
# 进一步完善nginx配置文件
    # 这个server设置的是storage nginx
    server {
        listen       9991;
        server_name  localhost;

        location / {
            root   html;
            index  index.html index.htm;
        }

        location ~/group1/M00 {
            root /opt/fastdfs_storage/data;
            ngx_fastdfs_module;
        }

        location = /50x.html {
            root   html;
        }
    }
    
    # 若访问不到图片需要配置这个软连接
    # ln -s /opt/fastdfs_storage_data/data/ /opt/fastdfs_storage_data/data/M00
    
    # 这个server设置的是tracker nginx
    upstream fdfs_group1 {
        server 127.0.0.1:9991;
    }
    
    server {
        listen       80;
        server_name  localhost;
        
        location /group1/M00 {
            proxy_pass http://fdfs_group1;
        }
        
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
```

