---
title: SecureFX连接Linux后文件夹中文乱码问题解决
date: {{date}}
tags:
- SecureFX
- Linux
categories:
- Linux
password: 
---
### 在选项中设置字符编码为UTF-8
![](https://i.imgur.com/4TN2GUH.png)

### 在全局选项中找到Securefx的配置文件
![](https://i.imgur.com/gBdpDaT.png)

<escape><!-- more --></escape>

### 进入到该目录中，选择“Sessions”
![](https://i.imgur.com/E0jtC6k.png)

    在“Sessions”中找到当前连接linux服务器地址的ini文件，并用文本编辑器打开。
    在打开的ini文件中，查找：Filenames Always Use UTF8；Filenames Always Use UTF8后面的值修改为：00000001，保存退出；
![](https://i.imgur.com/C5rXjOa.png)

    再次打开SecureFX，进入到含有中文名称的文件目录中，可以看到含有中文名称的文件已经能够正常显示了。