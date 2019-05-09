---
title: Hexo搭建教程(2)
date: {{ date }}
tags: 
- hexo
categories: 
- hexo 
top: 
---

# 第一部分

## hexo搭建步骤

1. 安装Git
2. 安装Node.js
3. 安装Hexo
4. GitHub创建个人仓库
5. 生成SSH添加到GitHub
6. 将hexo部署到GitHub
7. 设置个人域名
8. 发布文章

<escape><!-- more --></escape>

### 安装Git

    Git是目前世界上最先进的分布式版本控制系统，可以有效、高速的处理从很小到非常大的项目版本管理。
    也是用来管理你的hexo博客文章，上传到GitHub的工具。
    
    windows：到git官网上下载,下载安装后会有一个Git Bash的命令行工具，以后就用这个工具来使用git。
    linux：因为最早的git就是在linux上编写的，只需要一行代码：yum install git (apt-get install git)
    安装好后，用git --version 来查看一下版本
![](https://i.imgur.com/cr1thaV.png)

    注意:一定要安装最新的版本，若版本太低后面使用git时会有如下错误情况：
    
    错误提示：
    fatal: unable to access 'https://github.com/iissnan/hexo-theme-next.git': error
    :1407742E:SSL routines:SSL23_GET_SERVER_HELLO:tlsv1 alert protocol version
    错误分析：github 2月1日发了个公告Weak cryptographic standards removal notice，简而言之就是不支持TLSv1/TLSv1.1
    解决办法：
    第一种：更新git和tortoisegit至最新版
    第二种：检查TLS版本：git config http.sslVersion
    如果是tlsv1.0，则用下面一句命令行更新至tlsv1.2
    git config --global http.sslVersion tlsv1.2


### 安装nodejs

    Hexo是基于nodejs编写的，需要安装一下nodejs和里面的npm工具。
    
    windows：nodejs选择LTS版本，下载，安装。
    linux：yum install nodejs && yum install npm
        或者：sudo apt-get install nodejs
             sudo apt-get install npm
    
    安装完后，打开命令行，检查一下有没有安装成功
    node -v
    npm -v
![](https://i.imgur.com/U0SjRFv.png)

### 安装hexo

    前面git和nodejs安装好后，就可以安装hexo了。先创建一个文件夹my-blog，然后cd到这个文件夹下（或者在这个文件夹下直接右键git bash打开）。
    
    安装Hexo脚手架工具，输入命令：npm install -g hexo-cli
    用hexo -v查看一下版本
![](https://i.imgur.com/OhqQ3nR.png)

    至此所需要的软件就全部安装完了。
    
    接下来初始化一下hexo： 
    
    $ hexo init my-blog # 创建并初始化博客目录
    $ cd my-blog        # 进入该博客目录
    $ npm install       # 创建默认博客文件
    
    新建完成后，指定文件夹目录下有：
    myblog
    ├── node_modules  #依赖包
    ├── public        #存放生成的页面
    ├── scaffolds     #生成文章的一些模板
    ├── source        #用来存放你的文章
    |   ├── _drafts   #草稿目录
    |   └── _posts    #发布的文章目录
    └── themes        #主题
    ├── _config.yml   #博客配置文件
    ├── package.json  #模块和依赖项
    
    _config.yml博客配置文件说明：
    网站主题的的配置文件，和github page关联和切换主题时，需要使用到
    
        # Hexo Configuration
        ## Docs: https://hexo.io/docs/configuration.html
        ## Source: https://github.com/hexojs/hexo/
    
        # Site
        title: 网站标题如：Minstorm-blog
        subtitle: 网站副标题：Minstorm
        description: 网站描述：Minstorm:a blog for tech
        author: 网站作者：De scherpe
        language: 网站的语言，跟当前使用的主题下的语言文件有关
        timezone: 网站的时区，默认使用的是电脑的时区
        
        # URL
        ## If your site is put in a subdirectory, set url as 'http://yoursite.com/child' and root as '/child/'
        url: 网站地址，也就是https://xxx.github.io/ 地址
        root: 网站根目录,建议是用'/'
        permalink: 文章的永久链接格式，默认就好 :year/:month/:day/:title/
        permalink_defaults: 永久链接中各部分的默认值，不用填
        
        # Directory
        source_dir:资源文件夹，存放文章用的：source
        public_dir: 公共文件夹，用来存放编译之后的文件：public
        tag_dir: 标签文件夹：tags
        archive_dir: 归档文件夹，也就是你的全部文章生成的目录：archives
        category_dir: 分类文件夹：categories
        code_dir: Include code文件夹：downloads/code
        i18n_dir: 国际化（i18n）文件夹:lang
        skip_render: 需要跳过渲染的文件存放的文件夹
        
        # Writing
        new_post_name: :title.md # File name of new posts
        default_layout: 默认文章样式：post
        titlecase: false # Transform title into titlecase
        external_link: true # Open external links in new tab
        filename_case: 0
        render_drafts: false
        post_asset_folder: false
        relative_link: false
        future: true
        highlight:
          enable: true 
          line_number: true
          auto_detect: false
          tab_replace:
        
        # Home page setting
        # path: Root path for your blogs index page. (default = '')
        # per_page: Posts displayed per page. (0 = disable pagination)
        # order_by: Posts order. (Order by date descending by default)
        index_generator:
          path: ''
          per_page: 每一页显示的文章：10
          order_by: -date
        
        # Category & Tag
        default_category: uncategorized
        category_map:
        tag_map:
        
        # Date / Time format
        ## Hexo uses Moment.js to parse and display date
        ## You can customize the date format as defined in
        ## http://momentjs.com/docs/#/displaying/format/
        date_format: YYYY-MM-DD
        time_format: HH:mm:ss
        
        # Pagination
        ## Set per_page to 0 to disable pagination
        per_page: 10
        pagination_dir: page
        
        # Extensions
        ## Plugins: https://hexo.io/plugins/
        ## Themes: https://hexo.io/themes/
        theme: 主题：next
        
        # Deployment
        ## Docs: https://hexo.io/docs/deployment.html
        deploy: # 同步使用
          type: 
    
    接下来开启服务
    
    编译生成静态网页文件，执行如下命令：
    $ hexo generate
    可以简写为$ hexo g
    
    注意，如下图才是命令正确执行，否则按照提示解决错误
![](https://i.imgur.com/ra9wXhX.png)

    本地预览文章，执行如下命令：
    $ hexo server 
    可以简写为$ hexo s
    如果需要预览draft文件夹下面的文件，需要在后面加上--draft参数
    $ hexo s --draft
![](https://i.imgur.com/vmdZ0fv.png)

    在执行hexo s命令后，会出现一个网址http://localhost:4000/，将其复制(需要注意的是，在cmd中不可用ctrl + c 来复制，Ctrl + C为停止命令）。
    打开该网址后，可以看到网站的雏形，使用ctrl+c可以把服务关掉。
    
    注：以上的操作实现的效果如下:
        - 运行服务后，可以在本地预览博客。
        - 接下来的操作是把博客文件给推送到GitHub上，使用GitHub提供的域名访问博客

### GitHub创建个人仓库

    首先注册一个GitHub账户(注意：用户名跟你的博客域名有关，请慎重取名)
    注册完登录后，在GitHub.com中看到一个New repository，新建仓库。
    需要创建一个和你用户名相同的仓库，后面加.github.io，
    只有这样，将来要部署到GitHub page的时候，才会被识别，也就是xxx.github.io，
    其中xxx就是你注册GitHub的用户名。
![](https://i.imgur.com/8Pbc8Ic.png)
    
### 生成SSH添加到GitHub

    回到你的git bash中，输入如下两条命令：
    git config --global user.name "yourname"
    git config --global user.email "youremail"
    
    这里的yourname输入你的GitHub用户名，youremail输入你GitHub的邮箱。这样GitHub才能知道你是不是对应它的账户。
    
    可以用以下两条，检查一下你有没有输对：
    git config user.name
    git config user.email
    
    然后创建SSH,一路回车
    ssh-keygen -t rsa -C "youremail"
    youremail是你注册GitHub的邮箱
    
    这个时候它会告诉你已经生成了.ssh的文件夹。在你的电脑中找到这个文件夹。
    简单来讲，就是一个秘钥，其中，id_rsa是你这台电脑的私人秘钥，不能给别人看的，id_rsa.pub是公共秘钥，可以随便给别人看。
    把这个公钥放在GitHub上，这样当你链接GitHub自己的账户时，它就会根据公钥匹配你的私钥，当能够相互匹配时，才能够顺利的通过git上传你的文件到GitHub上。
    
    而后在GitHub的setting中，找到SSH keys的设置选项，点击New SSH key，把你的id_rsa.pub里面的信息复制进去。
![](https://i.imgur.com/uPTCxKK.png)
    
    在gitbash中，查看是否成功
    ssh -T git@github.com
![](https://i.imgur.com/D7DzK0d.png)

### 将hexo部署到GitHub

    这一步，我们就可以将hexo和GitHub关联起来，也就是将hexo生成的文章部署到GitHub上。
    
    需要用到hexo的GitHub插件hexo-deployer-git，首先用npm下载这个插件
    $ npm install hexo-deployer-git --save
    
    然后打开站点配置文件_config.yml，翻到最后，修改为YourgithubName就是你的GitHub账户
    deploy:
      type: git
      repo: git@github.com:用户名/用户名.github.io.git 
      branch: master
    
    配置好了deploy之后，就可以运行以下命令上传项目了
    hexo clean
    hexo generate
    hexo deploy
    
    其中 hexo clean清除了你之前生成的东西，也可以不加。
    hexo generate 顾名思义，生成静态文章，可以用 hexo g缩写
    hexo deploy 部署文章，可以用hexo d缩写
    
    注意deploy时可能要你输入username和password。
    
    得到下图就说明部署成功了，过一会儿就可以在https://yourname.github.io 这个网站看到你的博客了！
![](https://i.imgur.com/GVxDqDd.png)

### 设置个人域名

    现在你的个人网站的地址是 yourname.github.io，如果觉得这个网址逼格不太够，这就需要你设置个人域名了。但是需要花钱。
    注册一个阿里云账户,在阿里云上买一个域名，先去进行实名认证,然后在域名控制台中，看到你购买的域名。
    点解析进去，添加解析
    记录类型选A或CNAME，A记录的记录值就是ip地址，github(官方文档)提供了两个IP地址，192.30.252.153和192.30.252.154，
    这两个IP地址为github的服务器地址，两个都要填上，解析记录设置两个@，线路就默认就行了，CNAME记录值填你的github博客网址。
    如下图所示：
![](https://i.imgur.com/Mgj88RX.png)

    注意，解析线路选择默认，(解析线路:境外是后面来做国内外分流用的,在后面会讲到)。记得现在选择默认！
    
    登录GitHub，进入之前创建的仓库，点击settings，设置Custom domain，输入你的网站地址

![](https://i.imgur.com/xRs9XZG.png)

    顺便再勾选上强制使用https，"Enforce HTTPS" 
    
    然后在你的博客文件根目录的source中创建一个名为CNAME文件，不要后缀。写上你的网站地址。
![](https://i.imgur.com/c6iAOKb.png) 

    最后，在gitbash中，输入
    hexo clean
    hexo g
    hexo d
    
    稍等一会儿，再打开你的浏览器，输入你自己的网站地址(使用https的方式)，就可以看到搭建的网站啦！
    
    总结，GitHub上面的配置和CNAME里面的设置互相结合，有如下几种方式：
![](https://i.imgur.com/We1CT5T.png)
    
    接下来你就可以正式开始写文章了。
    
    使用命令行工具创建一篇文章
    $ hexo new [layout] <title>
    layout是文章的布局，默认是post布局
    <title> 是文章名称
    例如：hexo new post '我的第一篇文章'
    
    hexo还有一个文件夹是草稿文件夹_draft，可以用理解成私密文章的功能，
    只要有不想显示的文章但是又不想删除，就可以把文章拖进去_draft文件夹就可以实现隐藏的功能了，也可以用hexo的命令将文章放到草稿文件夹
    $ hexo publish <layout> <filename>
    
    然后在source/_post中打开markdown文件，就可以开始编辑了。当你写完的时候，再
    hexo clean
    hexo g
    hexo d
    就可以看到更新了。