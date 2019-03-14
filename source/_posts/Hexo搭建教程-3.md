---
title: Hexo搭建教程(3)
date: {{ date }}
tags: 
  - hexo
categories:
- hexo 
top: 
---

# 第二部分

## hexo基本配置

    在文件根目录下的_config.yml，就是整个hexo框架的配置文件了。可以在里面修改大部分的配置。详细可参考官方的配置描述。

### 网站

![](https://i.imgur.com/uzNRp60.png)
    
    description主要用于SEO，告诉搜索引擎一个关于您站点的简单描述，通常建议在其中包含您网站的关键词。
    author参数用于主题显示文章的作者。
    language可以用来解决菜单中文乱码，设置language字段如下:
        language: zh-Hans 或者 anguage: zh-CN
        取决于你的主题theme目录下的language目录下有zh-Hans.yml还是zh-CN.yml
    timezone，东八区设置是 Asia/Shanghai

<escape><!-- more --></escape>

### 网址

![](https://i.imgur.com/DuDMHGc.png)

    在这里需要把url改成你的网站域名，也就是第一步仓库地址的那个，https://xxx.github.io/
    permalink，也就是你生成某个文章时的那个链接格式。
    比如我新建一个文章叫temp.md，那么这个时候他自动生成的地址就是https://xxx.github.io/年/月/日/temp。
    
    以下是官方给出的示例，关于链接的变量还有很多，需要的可以去官网上查找 永久链接 。
![](https://i.imgur.com/w9srSbP.png)  

    网站存放在子目录
    如果您的网站存放在子目录中，例如 https://xxx.github.io/blog，则请将您的 url 设为 https://xxx.github.io/blog 并把 root 设为 /blog/。
    
    再往下翻，中间这些都默认就好了。
    
    theme: landscape
    theme就是选择什么主题，也就是在theme这个文件夹下，在官网上有很多个主题，默认给你安装的是lanscape这个主题。
    当你需要更换主题时，在官网上下载，把主题的文件放在theme文件夹下，再修改这个参数就可以了。
    
    同步到Git
    # Deployment
    ## Docs: https://hexo.io/docs/deployment.html
    deploy:
      type: git
      repo: <repository url>
      branch: [branch]
    deploy就是网站的部署的，repo就是仓库(Repository)的简写。branch选择仓库的哪个分支。而这个在后面进行双平台部署的时候会再次用到。

### Front-matter

    Front-matter 是文件最上方以 --- 分隔的区域，用于指定个别文件的变量，举例来说：
    title: Hello World
    date: 2013/7/13 20:46:25
    ---
    
    下面这些是预先定义的参数，您可在模板中使用这些参数值并加以利用。
![](https://i.imgur.com/JO3DePn.png)

    其中，分类和标签需要区别一下，分类具有顺序性和层次性，也就是说 Foo, Bar 不等于 Bar, Foo；而标签没有顺序和层次。

### layout(布局)

    当你每一次使用代码:hexo new paper,它其实默认使用的是post这个布局，也就是在source文件夹下的_post里面。
    
    Hexo 有三种默认布局：post、page 和 draft，它们分别对应不同的路径，而您自定义的其他布局和 post 相同，都将储存到 source/_posts 文件夹。
![](https://i.imgur.com/BJqguol.png)

    而new这个命令其实是：hexo new [layout] <title>,只不过这个layout默认是post罢了。

### page

    如果你想另起一页，那么可以使用:hexo new page board
    系统会自动给你在source文件夹下创建一个board文件夹，以及board文件夹中的index.md，这样你访问的board对应的链接就是https://xxx.github.io/board

### draft

    draft是草稿的意思，也就是你如果想写文章，又不希望被看到，那么可以:hexo new draft newpage
    
    这样会在source/_draft中新建一个newpage.md文件，如果你的草稿文件写的过程中，想要预览一下，那么可以使用:hexo server --draft,在本地端口中开启服务预览。
    
    如果你的草稿文件写完了，想要发表到post中，hexo publish draft newpage,就会自动把newpage.md发送到post中。

## 主题

### 更换主题

    如果觉得默认的landscape主题不好看，那么可以在官网的主题中，选择你喜欢的一个主题下载，然后进行修改就可以了。
    
    进入到博客目录执行如下命令，含义是克隆该主题并存入到博客文件夹下的thems文件下里
    git clone https://github.com/iissnan/hexo-theme-next.git themes/next
    
    执行后就会在博客目录文件夹的themes中可以找到有next的文件。
    找到博客根目录下的_config.yml文件，修改里面的配置
    将theme 修改为theme: next，需要注意的是冒号后有空格
    
    进入next这个文件夹，可以看到里面也有一个配置文件_config.yml，这个配置文件是整个主题的配置文件。
    
    以下关于主题的配置均是按照next主题设置的。

### menu(菜单栏)

    也即是如下图所示的这些东西：
![](https://i.imgur.com/LeIG3lQ.png)

    其中，About这个你是找不到网页的，因为你的文章中没有about这个东西。
    如果你想要的话，可以执行命令：hexo new page about
    它就会在根目录下source文件夹中新建了一个about文件夹，以及index.md，在index.md中写上你想要写的东西，就可以在网站上展示出来了。
    
    如果你想要自己再自定义一个菜单栏的选项，那么就：hexo new page yourdiy
    然后在主题配置文件的menu菜单栏添加一个 Yourdiy : /yourdiy，注意冒号后面要有空格，以及前面的空格要和menu中默认的保持整齐。
    然后在languages文件夹中，找到zh-CN.yml，在index中添加yourdiy: '中文意思'就可以显示中文了。
    
    意思是说在menu中写入的是英文，但是网站使用的话会根据网站使用的语言到相应的语言包中查找到该英语的释义，然后再网站上显示出来。
    比如menu菜单我写的是home，但是网站语言配置使用的是zh-Hans，此时就会到当前使用主题的语言包下找zh-Hans.yml文件，在该文件中，有一条数据 home:主页，则访问该网站时原先写的是home的地方则会显示出“主页”字样。

### customize(定制)

    可以修改你的个人logo，在当前使用的主题文件夹下的source/css/images文件夹中放入自己要的logo，再改一下url的链接名字就可以了。
    favicon是网站中出现的那个小图标的icon，找一张你喜欢的logo，然后转换成ico格式，放在images文件夹下，配置一下路径就行。
    social_links ，可以显示你的社交链接，而且是有logo的。

 

### 添加RSS
    1. 先安装RSS插件: npm i hexo-generator-feed
    2. 而后在你整个项目的_config.yml中找到Extensions，添加：
        # Extensions 
        ## Plugins: https://hexo.io/plugins/ 
        #RSS订阅 
        plugin: 
        - hexo-generator-feed 
        #Feed Atom 
        feed: 
            type: atom 
            path: atom.xml 
            limit: 20
    这个时候你的RSS链接就是 域名/atom.xml了
    3.在主题配置文件中设置：rss: ，开启RSS的页面功能，这样你网站上就有那个像wifi一样符号的RSS logo了，注意空格。

### widgets(侧边栏)

    侧边栏的小标签，如果你想自己增加一个，比如我增加了一个联系方式，那么我把communication写在上面，在zh-CN.yml中的sidebar，添加communication: '中文'。
    
    然后在hueman/layout/widget中添加一个communicaiton.ejs，填入模板：

### search(搜索框)

    默认搜索框是不能够用的，需要安装插件：hexo-generator-json-content

### comment(评论系统)

    valine好像不错，还能统计文章阅读量，可以自己试一试

### 设置头像和favicon

    头像/图标图片的存放位置是/themes/yilia(主题)/source/下任意位置，可以自己新建一个文件夹存放，比如img文件夹下。
    打开主题相应的配置文件：/themes/yilia/_config.yml。
    设置头像为配置文件中avatar一项，设置图标为配置文件中favicon一项。
    设置路径的根目录为/themes/yilia/source/。例如，我的头像存放的地址是/themes/yilia/source/img/me.png，设置则为avatar: /img/me.png。（图标同理）

### 打赏功能

    打开主题相应的配置文件：/themes/yilia/_config.yml。
    # 打赏
    # 打赏type设定：0-关闭打赏； 1-文章对应的md文件里有reward:true属性，才有打赏； 2-所有文章均有打赏
    reward_type: 2
    # 打赏wording
    reward_wording: '您的鼓励是我继续前进的动力~~~'
    # 支付宝二维码图片地址，跟你设置头像的方式一样。比如：/assets/img/alipay.jpg
    alipay: /img/alipay.jpg
    # 微信二维码图片地址
    weixin: /img/wechat.jpg

## git分支进行多终端工作

    利用git的分支系统进行多终端工作了，这样每次打开不一样的电脑，只需要进行简单的配置和在github上把文件同步下来，就可以无缝操作了。

### 机制

    由于hexo d上传部署到github的其实是hexo编译后的文件，是用来生成网页的，不包含源文件，也就是上传的是在本地目录里自动生成的.deploy_git里面。其他文件 ，包括我们写在source 里面的，和配置文件，主题文件，都没有上传到github。所以可以利用git的分支管理，将源文件上传到github的另一个分支即可。

### 创建分支

    找到之前建立的仓库，在其上新建一个hexo分支，如图：
![](https://i.imgur.com/kTLTmea.png)

    然后在这个仓库的settings中，选择默认分支为hexo分支（这样每次同步的时候就不用指定分支，比较方便）。
![](https://i.imgur.com/gmbQ4xH.png)

    然后在本地的任意目录下，打开git bash，输入如下命令：git clone git@github.com:xxx/xxx.github.io.git,xxx为用户名，也就是该仓库的git地址。
    
    将其克隆到本地，因为默认分支已经设成了hexo，所以clone时只clone了hexo。
    
    接下来在克隆到本地的xxx.github.io中，把除了.git 文件夹外的所有文件都删掉。把之前我们写的博客源文件全部复制过来，除了.deploy_git。
    这里应该说一句，复制过来的源文件应该有一个.gitignore，用来忽略一些不需要的文件，如果没有的话，自己新建一个，在里面写上如下，表示这些类型文件不需要git：
    Thumbs.db
    db.json
    *.log
    node_modules/
    public/
    .deploy*/
    
    注意，如果你之前克隆过theme中的主题文件，那么应该把主题文件中的.git文件夹删掉，因为git不能嵌套上传，最好是显示隐藏文件，检查一下有没有，有的话就删除。
    
    若没有.gitignore文件要如何创建?
    在当前xxx.github.io文件夹里，鼠标右键选择“Git Bash Here”，打开【git bash】的界面，在命令下输入【touch .gitignore】即可创建.gitignore文件
    
    而后添加文件到暂存区，把暂存区文件提交到仓库，同步：
    git add .
    git commit –m "add branch"
    git push 
    
    这样就上传完了，可以去你的github上看一看hexo分支有没有上传上去，其中node_modules、public、db.json已经被忽略掉了，没有关系，不需要上传的，因为在别的电脑上需要重新输入命令安装 。
    
    最终效果是，一个仓库里，主分支是博客静态文件，hexo分支是博客源码文件
![](https://i.imgur.com/EnVLEMO.png)
    
### 更换电脑操作

    - 安装Git
    - 设置git全局邮箱和用户名
        git config --global user.name "yourgithubname"
        git config --global user.email "yourgithubemail"
    - 设置ssh key
        ssh-keygen -t rsa -C "youremail"
        #生成后填到github和coding上（有coding平台的话）
        #验证是否成功
        ssh -T git@github.com
    - 安装nodejs
        yum install nodejs && yum install npm
    - 安装hexo
        npm install hexo-cli -g
    
    但是已经不需要初始化了,直接在任意文件夹下执行如下命令：git clone git@github.com:xxx/xxx.github.io.git，
    然后进入克隆到的文件夹：
        cd xxx.github.io
        npm install
        npm install hexo-deployer-git --save
    生成，部署：
        hexo g
        hexo d
    
    然后就可以开始写你的新博客了：hexo new newpage
    
    每次写完最好都把源文件上传一下：
        git add .
        git commit –m "xxxx"
        git push 
    
    如果是在已经编辑过的电脑上，已经有clone文件夹了，那么，每次只要和远端同步一下就行了：git pull

## coding page上部署实现国内外分流

    之前我们已经把hexo托管在github了，但是github是国外的，而且百度的爬虫是不能够爬取github的，所以如果你希望你做的博客能够在百度引擎上被收录，而且想要更快的访问，那么可以在国内的coding page做一个托管，这样在国内访问就是coding page，国外就走github page。

### 申请coding账户，新建项目

    先申请一个账户，然后创建新的项目，这一步项目名称应该是随意的。

### 添加ssh key

    这一步跟github一样。添加后，检查一下是不是添加成功
    ssh -T git@git.coding.net

### 修改_config.yml

    hexo官方文档是这样的：
    deploy:
      type: git
      message: [message]
      repo:
        github: <repository url>,[branch]
        coding: <repository url>,[branch] 
    
    那么，我们只需要：
    deploy:
      type: git 
      repo: 
        coding: git@git.coding.net:ZJUFangzh/ZJUFangzh.git,master 
        github: git@github.com:ZJUFangzh/ZJUFangzh.github.io.git,master

### 部署
    保存一下，直接
    hexo g
    hexo d
    这样就可以在coding的项目上看到你部署的文件了。

### 开启coding pages服务，绑定域名

![](https://i.imgur.com/Jl0IGRy.png)

### 阿里云添加解析

![](https://i.imgur.com/gRmkUCM.png)

    这个时候就可以把之前github的解析改成境外，把coding的解析设为默认了。

### 去除coding page的跳转广告

    coding page的一个比较恶心人的地方就是，你只是银牌会员的话，访问会先跳转到一个广告，再到你自己的域名。那么它也给出了消除的办法。右上角切换到coding的旧版界面，默认新版是不行的。然后再来到pages服务这里。
![](https://i.imgur.com/TYIc59t.jpg)

    只要你在页面上添加一行文字，写Hosted by Coding Pages，然后点下面的小勾勾，两个工作日内它就会审核通过了。
    <p>Hosted by <a href="https://pages.coding.me" style="font-weight: bold">Coding Pages</a></p>
    
    可以把这一行代码放在主题文件夹/layout/common/footer.ejs里面，也就是本来在页面中看到的页脚部分。当然，为了统一，又在后面加上了and Github。
    
    最终加上去的代码：
    <p><span>Hosted by <a href="https://pages.coding.me" style="font-weight: bold">Coding Pages</a></span> and <span><a href="https://github.com" style="font-weight: bold">Github</a></span></p>

