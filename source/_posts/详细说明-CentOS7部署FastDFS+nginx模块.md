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

# 检查文件是否存在，确保在/usr/lib路径下有libfastcommon.so和libfdfsclient.so
ll /usr/lib | grep "libf"
lrwxrwxrwx   1 root root     27 Apr  2 10:07 libfastcommon.so -> /usr/lib64/libfastcommon.so
-rwxr-xr-x   1 root root 356664 Apr  2 10:15 libfdfsclient.so
```

## 安装fastdfs
```
cd /usr/local/src
tar -zxvf fastdfs-6.06.tar.gz
cd fastdfs-6.06
./make.sh
./make.sh install

# FastDFS的配置文件默认安装到/etc/fdfs目录下

# 安装成功后将fastdfs-6.06/conf下的俩文件拷贝到/etc/fdfs/下
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
# 创建tracker工作目录,storage存储目录(选择大磁盘空间)等
mkdir -p /opt/{fdfs_tracker,fdfs_storage,fdfs_storage_data}

cd /etc/fdfs/
cp tracker.conf.sample tracker.conf
vim tracker.conf
    disabled = false # 配置tracker.conf这个配置文件是否生效，因为在启动fastdfs服务端进程时需要指定配置文件，所以需要使次配置文件生效。false是生效，true是屏蔽。
    bind_addr = # 程序的监听地址，如果不设定则监听所有地址，可以设置本地ip地址
    port = 22122 #tracker监听的端口
    base_path = /opt/fdfs_tracker # tracker保存data和logs的路径
    http.server_port=8080 # http服务端口，保持默认

# 启动fdfs_trackerd
/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf start

# 查看/opt/fdfs_tracker目录，发现目录下多了data和logs两个目录

# 查看端口号，验证启动情况
[root@bogon fdfs]# ps -ef | grep fdfs
root       2119      1  0 10:22 ?        00:00:00 /usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf start
[root@bogon fdfs]# ss -tulnp | grep 22122
tcp    LISTEN     0      128       *:22122      *:*    users:(("fdfs_trackerd",pid=2119,fd=5))

# 命令行选项
Usage: /usr/bin/fdfs_trackerd <config_file> [start|stop|restart]

# 设置开机自启动
echo "/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf restart" | tee -a /etc/rc.d/rc.local
```

### fdfs_storage配置并启动
与tracker不同的是，storage还需要一个目录用来存储数据，所以在上面步骤中另外多建了两个目录fdfs_storage_data,fdfs_storage
```
cd /etc/fdfs/
cp storage.conf.sample storage.conf
vim storage.conf
    disabled=false # 启用这个配置文件
    group_name=group1 #组名，根据实际情况修改，文件链接中会用到
    port=23000 #设置storage的端口号，默认是23000，同一个组的storage端口号必须一致
    base_path = /opt/fdfs_storage # #设置storage数据文件和日志目录，注意,这个目录最好有大于50G的磁盘空间
    store_path_count=1 #存储路径个数，需要和store_path个数匹配 
    store_path0 = /opt/fdfs_storage_data # 实际保存文件的路径，注意,这个目录最好有大于50G的磁盘空间
    tracker_server = 192.168.75.5:22122 # tracker监听地址和端口号，要与tracker.conf文件中设置的保持一致
    http.server_port=8888 #设置 http 端口号
    
# 启动fdfs_storaged
/usr/bin/fdfs_storaged /etc/fdfs/storage.conf start

# 查看端口号，验证启动情况
[root@bogon fdfs]# ps -ef | grep "fdfs_storaged"
root       2194      1  7 10:36 ?        00:00:01 /usr/bin/fdfs_storaged /etc/fdfs/storage.conf start
[root@bogon fdfs]# ss -tulnp | grep "fdfs"
tcp    LISTEN     0      128       *:23000      *:*     users:(("fdfs_storaged",pid=2194,fd=5))
tcp    LISTEN     0      128       *:22122      *:*     users:(("fdfs_trackerd",pid=2119,fd=5))

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
    base_path = /opt/fdfs_tracker # tracker服务器文件路径
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

> 组名：group1 
> 磁盘：M00 
> 目录：00/00 
> 文件名称：wKhLBV6FUl6AA0eTACSnIi51C7k037.jpg
> 注意图片路径中的8080端口,这个是tracker的端口

上传的图片会被上传到我们创建的fdfs_storage_data目录下，会有四个图片文件:
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

data下有256个1级目录，每级目录下又有256个2级子目录，总共65536个文件，新写的文件会以hash的方式被路由到其中某个子目录下，然后将文件数据直接作为一个本地文件存储到该目录中。

## FastDFS和nginx结合使用

FastDFS通过Tracker服务器,将文件放在Storage服务器存储,但是同组之间的服务器需要复制文件,有延迟的问题.
假设Tracker服务器将文件上传到了172.20.132.57,文件ID已经返回客户端,这时,后台会将这个文件复制到172.20.132.57,如果复制没有完成,客户端就用这个ID在172.20.132.57取文件,肯定会出现错误。
这个fastdfs-nginx-module可以重定向连接到源服务器取文件,避免客户端由于复制延迟的问题,出现错误。 
正是这样，FastDFS需要结合nginx，所以取消原来对HTTP的直接支持。

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
    base_path=/opt/fdfs_storage # 与storage.conf配置中的保持一致
    tracker_server=192.168.75.5:22122 #tracker服务器的IP地址以及端口号
    url_have_group_name = true # url中包含group名称
    store_path0=/opt/fdfs_storage_data #与storage.conf中的路径保持一致
    group_count = 1 #设置组的个数
```
```
yum -y install pcre pcre-devel openssl openssl-devel zlib zlib-devel 
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

# 修改配置文件
vim /usr/local/openresty/nginx/conf/nginx.conf
    error_log  logs/error.log;
    pid      logs/nginx.pid;
    server{
        server_name  192.168.75.5; 
    }

# 启动
/usr/local/openresty/nginx/sbin/nginx -c /usr/local/openresty/nginx/conf/nginx.conf

# 浏览器访问，出现openresty欢迎页面

# 设置nginx开机启动
echo "/usr/local/openresty/nginx/sbin/nginx -c /usr/local/openresty/nginx/conf/nginx.conf" | tee -a /etc/rc.d/rc.local

# 再次修改配置文件，加载fastdfs模块
vim /usr/local/openresty/nginx/conf/nginx.conf
    server{
        location /group1/M00/ {
            root /opt/fdfs_storage/data;
            ngx_fastdfs_module;
        }
    }

# 重载nginx
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

# 搭建集群

## 集群规划(单tracker,双storage)
```
虚拟机 	    IP 	                说明
tracker 	192.168.75.5 	tracker 服务器
storage01 	192.168.75.6 	storage01服务器【group1】
storage02 	192.168.75.7 	storage02服务器【group2】
```
## 软件清单
```
fastdfs-6.06.tar.gz
fastdfs-client-java-1.28.tar.gz
fastdfs-nginx-module-1.22.tar.gz
libfastcommon-1.0.43.tar.gz
openresty-1.15.8.3.tar.gz
```
## 安装步骤

### 1.tracker服务器
```
# 1. 安装libfastcommon 模块
# 2. 编译安装 FastDFS
# 3. 修改配置文件tarcker.conf和client.conf(测试上传)

# vim /etc/fdfs/tracker.conf
    store_lookup=0  #采用轮询策略进行存储，0：轮询 1：始终定向到某个group 2：选择存储空间最大的进行存储

# 4. 开机启动
```

### 2.storage服务器
```
# 1. 安装libfastcommon 模块
# 2. 编译安装 FastDFS
# 3. 修改配置文件storage.conf

# storage01 配置
# vim /etc/fdfs/storage.conf
group_name=group1
base_path=/home/fastdfs_storage
store_path0=/home/fastdfs_storage
tracker_server=192.168.75.6:22122
http.server_port=8888

# storage02 配置
# vim /etc/fdfs/storage.conf
group_name=group2
base_path=/home/fastdfs_storage
store_path0=/home/fastdfs_storage
tracker_server=192.168.75.7:22122
http.server_port=8888

# 4. 开机启动
# 5. 安装nginx和fastdfs-nginx-module模块

# storage01 配置：
# vim /etc/fdfs/mod_fastdfs.conf
connect_timeout=10
base_path=/home/fastdfs_storage
url_have_group_name=true
store_path0=/home/fastdfs_storage
tracker_server=192.168.75.6:22122
group_name=group1

# storage02 配置：
# vim /etc/fdfs/mod_fastdfs.conf
connect_timeout=10
base_path=/home/fastdfs_storage
url_have_group_name=true
store_path0=/home/fastdfs_storage
tracker_server=192.168.75.7:22122
group_name=group2

# 6. 复制 FastDFS 安装目录的部分配置文件到 /etc/fdfs 目录
cp http.conf mime.types /etc/fdfs/

# 7. 配置nginx
server {
    listen 8888;  
    server_name localhost; 
     
    location ~/group([0-9])/M00 {
        ngx_fastdfs_module;  
    }
    error_page 500 502 503 504 /50x.html;  
    location = /50x.html {  
        root html;  
    }  
}
```

### 3.测试
```
# vim /etc/fdfs/client.conf
    base_path=/home/fastdfs_tracker
    tracker_server=192.168.75.5:22122

/usr/bin/fdfs_upload_file /etc/fdfs/client.conf test.jpg 
```

### 4. tracker安装nginx
```
http {  
    include mime.types;  
    default_type application/octet-stream;  
    sendfile on;  
    keepalive_timeout 65;
    
    #group1
    upstream fdfs_group1 {
       server 192.168.75.6:8888;
    }
    
    #group2
    upstream fdfs_group2 {
       server 192.168.75.7:8888;
    }
    
    server {  
        listen 8000;  
        server_name localhost;
        
        location /group1/M00 {
           proxy_pass http://fdfs_group1;
        }

        location /group2/M00 {
           proxy_pass http://fdfs_group2;
        }

        error_page 500 502 503 504 /50x.html;  
        location = /50x.html {  
            root html;  
        }  
    }  
} 
```