---
title: step
date: 2019-03-05 18:45:16
tags:
---
# 1说明
    博客是使用markdown文件来解析的，并且使用json来进行数据储存，完全不需要数据库来储存数据，文档也是比较完善，hexo官方的插件也很多，可以满足大部分的需求

# 2.安装Node

    首先，你要安装好Node，hexo需要用到Node的NPM（一个资源库管理工具）工具，如果没有安装过node的可以去Node官网下载，安装完了用cmd命令查看node的版本： 
    $ node -v
    如果出现以下信息，说明安装成功
    v10.15.2
# 3.安装Git
    当安装完Node之后，需要安装Git客户端，进入官网安装，安装完了可以用cmd命令查看Git的版本
    $ git --version
    如果出现以下信息，说明安装成功
    git version 1.9.0.msysgit.0

# 4.安装Hexo脚手架工具
    如果Git跟Node都安装完成了之后，就开始进入正式环节了！！！，首先，执行以下命令安装Hexo脚手架工具
    $ npm install -g hexo-cli

# 5.建立自己的博客
    $ hexo init my-blog # 创建并初始化博客目录
    $ cd my-blog        # 进入该博客目录
    $ npm install       # 创建博客文件    
    部署完了博客网站之后，可以看到整个博客网站的目录如下
    .
    ├── _config.yml #博客配置文件
    ├── package.json #模块和依赖项
    ├── scaffolds
    ├── source  #文章
    |   ├── _drafts #草稿目录
    |   └── _posts #发布的文章目录
    └── themes #主题

# 6.文件说明
###6.1 _config.yml
    网站主题的的配置文件，和github page关联和切换主题时，需要使用到

    # Hexo Configuration
    ## Docs: https://hexo.io/docs/configuration.html
    ## Source: https://github.com/hexojs/hexo/

    # Site
    title: 网站标题如：Minstorm-blog
    subtitle: 网站副标题：Minstorm
    description: 网站描述：Minstorm:a blog for tech
    author: 网站作者：De scherpe
    language: 网站的语言
    timezone:   网站的时间去，默认使用的是电脑的时区
    
    # URL
    ## If your site is put in a subdirectory, set url as 'http://yoursite.com/child' and root as '/child/'
    url: 网站地址：https://scherpe.github.io/blog/
    root: 网站根目录,建议是用'/'
    permalink: 文章的y永久链接格式，默认就好 :year/:month/:day/:title/
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
    theme: 主题：indigo
    
    # Deployment
    ## Docs: https://hexo.io/docs/deployment.html
    deploy:
      type: git
      repository: https://github.com/scherpe/blog.git
      branch: master

###6.2 package.json

    {
      "name": "hexo-site",
      "version": "1.0.0",
      "private": true,
      "hexo": {
        "version": "3.4.4"
      },
      "dependencies": {
        "hexo": "^3.2.0",
        "hexo-asset-image": "^0.0.3",
        "hexo-deployer-git": "^0.3.1",
        "hexo-generator-archive": "^0.1.4",
        "hexo-generator-category": "^0.1.3",
        "hexo-generator-feed": "^1.2.2",
        "hexo-generator-index": "^0.2.0",
        "hexo-generator-json-content": "^3.0.1",
        "hexo-generator-tag": "^0.2.0",
        "hexo-helper-qrcode": "^1.0.2",
        "hexo-qiniu-sync": "^1.4.7",
        "hexo-renderer-ejs": "^0.3.0",
        "hexo-renderer-less": "^0.2.0",
        "hexo-renderer-marked": "^0.3.0",
        "hexo-renderer-stylus": "^0.3.1",
        "hexo-server": "^0.2.0",
        "valine": "^1.1.9-beta3"
      }
    }

# 7.写作
    使用命令行工具创建一篇文章
    $ hexo new [layout] <title>
    # layout是文章的布局，默认是post布局
    # 例如：hexo new post '我的第一篇文章'

    hexo还有一个文件夹是草稿文件夹_draft，可以用理解成私密文章的功能，只要有不想显示的文章但是又不想删除，就可以把文章拖进去_draft文件夹就可以实现隐藏的功能了，也可以用hexo的命令将文章放到草稿文件夹
    $ hexo publish <layout> <filename>

# 8.编译文章
    写好文章的时候，需要预览一下，hexo的编译命令
    $ hexo generate
    可以简写为$ hexo g

# 9.预览文章
    $ hexo server 
    可以简写为$ hexo s
    如果需要预览draft文件夹下面的文件，需要在后面加上--draft参数
    $ hexo s --draft

# 10.部署博客
    当写完文章时，需要对文章编译然后上传，部署到GitHub仓库，我们去GitHub创建一个仓库然后开启GitHubPage
![](https://i.imgur.com/007Kg4h.jpg)

# 11.开启GitHub Page
    你会看到蓝色自己写着xxx.github.io/项目名，这个就是线上能访问你项目的地址
![](https://i.imgur.com/K2htiT6.jpg)

    若是感觉这个域名太长太难记了，可以去设置自定义的域名，如果你有域名的话可以进入管理控制台里面的dnsj解析那里设置新建一个解析
![](https://i.imgur.com/u3M938b.jpg)

    记录类型选CNAME，主机记录可以写你喜欢的名称，解析线路默认的就行了，记录值需要填写你的GitHub的个人主页，格式是你的GitHub名称.github.io，记住不能写http或者https，然后点击确定。
    
    接下来就在GitHubpage那里写上刚刚设置好的值
    设置好域名之后，在source文件夹下面新建一个CNAME文件，然后写入以下的内容
    您设置的域名,例如：blog.minstorm.cn

# 12.上传项目
    要上传项目，需要用到hexo的GitHub插件hexo-deployer-git，首先用npm下载这个插件
    $ npm install hexo-deployer-git --save
    然后在_config.yml增加以下配置
    deploy:
      type: git
      repo: <repository url>
      branch: [branch]
      message: [message]
    刚配置好了deploy之后，就可以运行以下命令上传项目了
    $ hexo d


# 13.开启服务
    $ hexo g
    注意，如下图才是命令正确执行，否则按照提示解决错误
![](https://i.imgur.com/ra9wXhX.png)

    $ hexo s
![](https://i.imgur.com/vmdZ0fv.png)

    在执行hexo s 后，会出现一个网址http://localhost:4000/，将其复制（需要注意的是，在cmd中不可用ctrl + c 来复制，Ctrl + C为停止命令）。打开该网址后，可以看到网站的雏形。


# 错误集锦

#### 错误类型1
    错误描述:FATAL end of the stream or a document separator is expected at line 10, column 9
    错误说明:缺少分隔符，一般都是因为缺少空格
    解决方案:出现这种情况，一般都是缺少空格，在:冒号之后要有空格！检查x行y列附近的冒号，其之后是否跟了空格。
    
#### 错误类型2
    错误描述:ValidationError: ‘null’ is not a string!
    错误说明:一般都是因为文章无内容，可能是因为在这篇博客文章中，有某些属性没有填写，比如author属性，tag属性，categories属性等，导致该属性是空的，即null，所以报错。

    友情提示：如果你是用MarkdownPad 2来进行博文写作（我就是），可能在打开该md文件之后，对文件名进行了修改，导致出现了两篇文章。就会出现错误。
    解决方案:既然是属性缺失，那就把为空的那个属性给补上.
    
####错误类型3
    错误描述:generate的时候是没问题的，但是网页预览的时候，发现引用块有问题，原本引用块下方的内容跑到引用块里边去了！
    解决方案:引用块都是由一对三个**所包起来的，如果在最后一个点**之后有空格，界面会错乱，所以，把这个多余的空格去掉吧。


# 自定义主题
####4.1、创建github仓库
    这里需要注意的是仓库名字前缀需要和Owner一致，如这里Owner为fuusy，那么我的仓库名为fuusy.github.io，前缀必须一致，后面就上github.io。
    （注意：用户名跟你的博客域名有关，请慎重取名）
![](https://i.imgur.com/LwT0ojZ.jpg)

    新建成功后，复制ssh。后续修改_config.yml文件会用到。
![](https://i.imgur.com/dbw4xBn.jpg)

#### 4.2、切换主题
    接着开始切换主题并且将文章上传到github上。
    以我的博客主题为例，我的主题为yilia，从github上克隆该主题。
    进入到博客目录执行如下命令，含义是克隆该主题并存入到博客文件夹下的thems文件下里
    git clone https://github.com/litten/hexo-theme-yilia.git themes/yilia

    错误提示：
    fatal: unable to access 'https://github.com/litten/hexo-theme-yilia.git/': error
    :1407742E:SSL routines:SSL23_GET_SERVER_HELLO:tlsv1 alert protocol version
    错误分析：
    github 2月1日发了个公告Weak cryptographic standards removal notice，简而言之就是不支持TLSv1/TLSv1.1
    解决办法：
    第一种：更新git和tortoisegit至最新版
    第二种：检查TLS版本，git config http.sslVersion
    如果是tlsv1.0，则用下面一句命令行更新至tlsv1.2
    git config --global http.sslVersion tlsv1.2

    执行后就会在博客目录文件夹的themes中可以找到有yilia的文件。

    找到_config.yml文件，修改里面的配置
    将theme 修改为theme: yilia，需要注意的是冒号后有空格
    将deploy修改为：
    type:git
    repository: git@github.com:fuusy/fuusy.github.io.git 
    branch: master

#### 4.3、发布
    接下来需要使用 Git bash 来进行命令的执行，在Test文件夹中右击鼠标，你会发现有Git bash 选项，点击进入。执行命令：npm install hexo-deployer-git --save
    最后就是发布了，执行以下命令：
    hexo g
    hexo d
    完成后，你就有属于自己的博客了，在github的setting中 可以看到自己的博客地址


# GitHub篇

    百度搜索github,进入官网注册。（注意：用户名跟你的博客域名有关，请慎重取名）
    选择free，点击start，验证邮箱，进入注册的邮箱，打开github给我们发送的邮件，点击验证链接，
    验证完成后点击start，创建仓库。仓库名必须为’用户名.github.io’
    创建好后我们来新建个文件，点击Create new file
    文件为index.html，内容为<h1>Hello Github Pages</h1>
    复制你的仓库名————用户名.github.io
    在浏览器中粘贴，访问。看到如下页面（即使我们刚刚输入的内容）

# Git篇

    百度搜索git for windows，点击进入官网点击下载，下载好后确认安装，选择Use Windows的这个选项，我们就可以在cmd窗口中使用git命令

    github SSH Key 配置
    来到我们git for win的安装目录下，打开git-bash，输入ssh-keygen -t rsa -C “github的注册邮箱地址”，一路回车生成密钥，默认生成在C:\Users\用户名.ssh目录下面。
    接下来来到github官网，点击头像选择setting
    再点击SSH and GPG keys，选择右边的New SSH key
    标题可以自定义，找到我们生成的密钥(id_rsa.pub)，默认生成在C:\Users\用户名.ssh目录下面，拷贝到Key下

# Hexo篇

    先在本地新建个blog文件夹（随意），在cmd命令行进入到blog文件夹下。（win+R打开运行对话框，输入cmd打开命令行程序），heox主页上的就是安装命令（npm install hexo-cli -g），复制下来，在cmd从粘贴，回车确认命令，安装。安装需要时间，请耐心等待。安装成功后，运行初始化命令(hexo init blog)
    初始化好后，进入文件夹，输入命令安装依赖 npm install(安装需要时间，请耐心等待)
    （网好的请无视）若网络较差，可以使用淘宝镜像：
    命令:npm install -g cnpm –registry=https://registry.npm.taobao.org
    使用就是把npm改成cnpm即可。
    网好的作者这里继续使用npm
    
    安装完成后，输入hexo s -p 5555(在端口5555启动服务)
    在网页上输入localhost:5555预览一下（localhost表示本地访问）

    打开_config.yml文件，需要修改的地方有：网站名，介绍，关键字（这部分自己取），url(即是“http://用户名.github.io)。使用Ctrl+S保存文件.

    现在我们打开github获取仓库地址,点击头像->Your profile,点击对应的仓库,点击Clone or download，复制仓库地址,在_config.yml的最后找到deploy，输入如下内容（注意要有空格和缩进，不然会报错）
    deploy: 
        type:git
        repository: git@github.com:用户名/用户名.github.io.git 
        branch: master

    接下来还需要安装git插件，命令 npm install hexo-deployer-git –save
    安装好后输入hexo g生成命令

    输入hexo d部署到github
    第一提交会提示您配置github的邮箱和用户名,在弹出的输入框中输入用户名，密码登录.
    显示出INFO Deploy done: git表示成功发布到github上
    在浏览器上输入 “用户名.github.io” 即可访问自己的博客

# 主题篇

    在hexo官网的Themes（主题）下，搜索next，搜索结果点击跳转到github仓库，点击CN查看中文介绍，点击详细安装步骤，下载最新版本(git clone),拷贝到博客目录的themes下.

    打开_config.yml，修改 theme: next。
    注意是博客目录下的_config.yml，不是主题目录下的

    hexo g 重新生成一下
    hexo s -p 5555本地端口部署
    打开浏览器输入：localhost:5555，预览一下主题效果

    next支持多种外观,试着换一个外观模式，打开主题next下的_config.yml文件，注释第一个，显示第二个。再在浏览器上预览效果


# 发布新文章
    win+r快捷键，打开cmd命令行，进入文件所在的路径，
    $ hexo new title (title就是新建的文章的名字)
    然后在cmd中即可看到新建文章的路径（如上，在\Desktop\my_blog\source_posts\hello.md中），找到、编辑保存即可
    .md文件就是用markdown编辑的，hello文件就是保存图片的，其中hello.md中调用hello文件中的图片时使用相对路径
# 本地调试
    hexo server
    上面命令在cmd命令行执行后，打开http://localhost:4000/，找到刚才编辑的文章，查看无误后执行下一步
# 发布
    生成静态网页：hexo generate
    发布网站（推送到github或者gitee）：hexo deploy 
    也可简写为（一起执行上边两个命令）：hexo g -d 或 hexo d -g

    若看不到效果，可以先执行hexo clean,清除缓存文件 (db.json) 和已生成的静态文件 (public)
    然后再执行hexo g -d
    