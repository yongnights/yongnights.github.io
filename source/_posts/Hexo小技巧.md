---
title: Hexo小技巧
copyright: true
permalink: 1
top: 0
date: 2019-03-08 16:28:57
tags:
- hexo
categories:
- hexo
password:
---
## 编写的Markdown文件如何引用图片
### 使用网络文件
    我是使用MarkdownPad 2软件编写Markdown文件文件的，该软件自带的有图片上传功能，如下图所示：
![](https://i.imgur.com/GGMMztr.png)
    
    当你需要在文中插入图片时，选用此功能，点击“浏览并上传”,此时会弹出选择本地图片对话框，选好图片后点击“确定”。
    此时就把图片上传到网上了，页面上会自动出现该图片的网络地址引用url。需要主题的是这个url一定要顶行写。
    如下图所示：
![](https://i.imgur.com/FsLUdbL.png)
  
<escape><!-- more --></escape>
  
### 使用本地文件
    不论Hexo采用何种主题，默认采用的路径都是themes/主题名/source,可以在此source目录下新建一个专门存放图片的文件夹，比如image,然后把图片(a.jpg)保存到该image文件下里。
    在Markdown文件引用图片时，需要这样写：![](/images/a.jpg),也需要顶行写，如下图所示：
![](https://i.imgur.com/pqZzXzJ.png)

### 如何显示部分文章，点击“查看全文”才能看到全部文章
    在Markdown文件中输入<escape><!-- more --></escape>即可实现如下效果：
![](https://i.imgur.com/KeG4HNz.png)

    注意：这个也要顶行写，一般放在文件的二十行左右就行，如下图所示：
![](https://i.imgur.com/aAtqu6e.png)

### 文章加密
    在文章开头设置password的值即可

## 错误集锦

### 错误类型1
    错误描述:FATAL end of the stream or a document separator is expected at line 10, column 9
    错误说明:缺少分隔符，一般都是因为缺少空格
    解决方案:出现这种情况，一般都是缺少空格，在:冒号之后要有空格！检查x行y列附近的冒号，其之后是否跟了空格。
    
### 错误类型2
    错误描述:ValidationError: ‘null’ is not a string!
    错误说明:一般都是因为文章无内容，可能是因为在这篇博客文章中，有某些属性没有填写，比如author属性，tag属性，categories属性等，导致该属性是空的，即null，所以报错。

    友情提示：如果你是用MarkdownPad 2来进行博文写作（我就是），可能在打开该md文件之后，对文件名进行了修改，导致出现了两篇文章。就会出现错误。
    解决方案:既然是属性缺失，那就把为空的那个属性给补上.
    
### 错误类型3
    错误描述:generate的时候是没问题的，但是网页预览的时候，发现引用块有问题，原本引用块下方的内容跑到引用块里边去了！
    解决方案:引用块都是由一对三个**所包起来的，如果在最后一个点**之后有空格，界面会错乱，所以，把这个多余的空格去掉吧。
