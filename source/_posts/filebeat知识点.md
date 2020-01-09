---
title: filebeat知识点
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
在Filebeat的根目录下，有一个叫做filebeat.yml的文件。
```
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - ./sample.log
 
output.logstash:
```

这里需要注意的是之前有的文章里第一行写的是filebeat.prospectors。经过测试在新的版本里不再适用。

通过如下的命令来运行filebeat:
```
./filebeat
```
在默认的情况下，filebeat会自动寻找定义在filebeat.yml文件里的配置。如果配置文件是另外的名字，可以通过如下的命令来执行filebeat:
```
./filebeat -c YourYmlFile.yml
```

<escape><!-- more --></escape>

Filebeat的registry文件存储Filebeat用于跟踪上次读取位置的状态和位置信息。

- data/registry 针对 .tar.gz and .tgz 归档文件安装
- /var/lib/filebeat/registry 针对 DEB 及 RPM 安装包
- c:\ProgramData\filebeat\registry 针对 Windows zip 文件

如果想重新运行一遍数据，可以直接到相应的目录下删除那个叫做registry的目录即可。针对.tar.gz的安装包来说，可以直接删除这个文件。
那么重新运行上面的`./filebeat`命令即可。它将会重新把数据从头再进行处理一遍。这对于我调试来说是非常有用的。

