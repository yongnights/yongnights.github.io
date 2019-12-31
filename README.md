# yongnights.github.io
个人博客网站项目

网址：https://yongnights.github.io

# 分支说明
- hexo分支
    默认分支

- master分支
    这个分支存放的是编译后的网页html文件
    
# 日常操作说明
切换到hexo分支进行操作,新建/修改/删除文件等操作完毕后,
- 第一步：按照正常的git操作流程,把本地hexo分支推送到hexo分支上去.
- 第二步：打开命令行,执行命令："hexo g",生成静态文件,然后执行命令："hexo s -p 5555",表示的是在开启本地5555端口进行测试查看.最后再执行命令："hexo d" 表示把生成的静态文件推送到master分支上(这个已经在配置文件中写死的了)

> 说明：若不需要在本机进行查看效果,可以直接执行命令："hexo g -d"

# md文件编写格式
1. 开头
title字段必填外,其他字段非必填,另外需要说明的是tags和categories字段多个写法格式
```
---
title: 
top: 
date: 
tags: 
- elk
- xxx 
categories: 
- elk
- xxx
password: 
---
```
2. 页面查看显示"阅读原文"
在md文件大约二十多行的地方添加如下信息：`<escape><!-- more --></escape>`

3. 图片
尽可能使用本地图片,不使用外链图片
在md文件中图片格式如下：`![](/image_jquery/logo.png)`,其中image_jquery为主题下存放图片的文件夹


