---
title: Hexo搭建教程(1)
date: {{ date }}
tags: 
- hexo
categories:
- hexo
top: 
password: 
---
## 简要说明

- 现在市面上的博客很多，如CSDN，博客园，简书等平台，可以直接在上面发表，用户交互做的好，写的文章百度也能搜索的到。缺点是比较不自由，会受到平台的各种限制和恶心的广告。 

- 自己购买域名和服务器，搭建博客的成本实在是太高了，不光是说这些购买成本，单单是花力气去自己搭这么一个网站，还要定期的维护它，对于我们大多数人来说，实在是没有这样的精力和时间。

- 那么就有第三种选择，直接在github page平台上托管我们的博客。这样就可以安心的来写作，又不需要定期维护，而且hexo作为一个快速简洁的博客框架，用它来搭建博客真的非常容易。

- Hexo是一款基于Node.js的静态博客框架，依赖少易于安装使用，可以方便的生成静态网页托管在GitHub和Coding上，是搭建博客的首选框架。

- Hexo 使用 Markdown（或其他渲染引擎）解析文章，并且使用json来进行数据储存，完全不需要数据库来储存数据，在几秒内，即可利用靓丽的主题生成静态网页。因为Hexo的创建者是台湾人，对中文的支持很友好，可以选择中文进行查看。

<escape><!-- more --></escape>

## 教程分三个部分

- 第一部分：hexo的初级搭建,部署到github page上，以及个人域名的绑定。
- 第二部分：hexo的基本配置，更换主题，实现多终端工作，以及在coding page部署实现国内外分流
- 第三部分：hexo添加各种功能

## 教程汇总

### GitHub篇

    百度搜索github,进入官网注册。（注意：用户名跟你的博客域名有关，请慎重取名）
    选择free，点击start，验证邮箱，进入注册的邮箱，打开github给我们发送的邮件，点击验证链接，
    验证完成后点击start，创建仓库。仓库名必须为’用户名.github.io’
    创建好后我们来新建个文件，点击Create new file
    文件为index.html，内容为<h1>Hello Github Pages</h1>
    复制你的仓库名————用户名.github.io
    在浏览器中粘贴,访问,就能看到我们刚刚输入的内容

### Git篇

    百度搜索git for windows，点击进入官网点击下载，下载好后确认安装，选择Use Windows的这个选项，我们就可以在cmd窗口中使用git命令
    
    github SSH Key 配置
    来到我们git for win的安装目录下，打开git-bash，输入ssh-keygen -t rsa -C “github的注册邮箱地址”，一路回车生成密钥，默认生成在C:\Users\用户名.ssh目录下面。
    接下来来到github官网，点击头像选择setting
    再点击SSH and GPG keys，选择右边的New SSH key
    标题可以自定义，找到我们生成的密钥(id_rsa.pub)，默认生成在C:\Users\用户名.ssh目录下面，拷贝到Key下，然后保存。

### Hexo篇

    先在本地新建个blog文件夹(随意)，在cmd命令行进入到blog文件夹下。（win+R打开运行对话框，输入cmd打开命令行程序）,
    在打开的命令行中输入如下命令：npm install hexo-cli -g，回车确认命令，安装。
    安装成功后，j接着在命令行中输入并运行初始化命令：hexo init blog
    初始化好后，进入文件夹，输入命令安装依： npm install
    
    若网络较差，可以使用淘宝镜像：
    命令:npm install -g cnpm –registry=https://registry.npm.taobao.org
    使用就是把npm改成cnpm即可。
    
    安装完成后，输入hexo s -p 5555(在指定端口5555启动服务)
    在网页上输入localhost:5555预览一下（localhost表示本地访问）
    
    打开_config.yml文件，需要修改的地方有：title(网站名)，author(作者)，description(介绍)，url(即是“https://用户名.github.io)。
    使用Ctrl+S保存文件.
    
    现在我们打开github获取仓库地址,点击头像->Your profile,点击对应的仓库,点击Clone or download，
    复制仓库地址,在_config.yml的最后找到deploy，输入如下内容（注意要有空格和缩进，不然会报错）
    deploy: 
        type:git
        repository: git@github.com:用户名/用户名.github.io.git 
        branch: master
    
    接下来还需要安装git插件，命令: npm install hexo-deployer-git –save
    安装好后输入hexo g，生成静态文件命令
    再输入命令:hexo d,部署到github
    
    第一提交会提示您配置github的邮箱和用户名,在弹出的输入框中输入用户名，密码登录.
    显示出INFO Deploy done: git表示成功发布到github上
    在浏览器上输入 “用户名.github.io” 即可访问自己的博客

### 主题篇

    在hexo官网的Themes下，搜索next，搜索结果点击跳转到github仓库，点击CN查看中文介绍，点击详细安装步骤，下载稳定版本(git clone),拷贝到博客目录的themes下.
    git clone https://github.com/iissnan/hexo-theme-next.git themes/next
    
    或者下载下来主题压缩包文件，解压后修改文件名称放到themes文件夹下
    
    打开_config.yml，修改 theme: next。
    注意是博客目录下的_config.yml，不是主题目录下的
    
    hexo g 重新生成一下
    hexo s -p 5555本地端口部署
    打开浏览器输入：localhost:5555，预览一下主题效果


​    