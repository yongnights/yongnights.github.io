---
title: Hexo搭建教程(3)
date: 2019-03-06 14:28:14
tags: 
---
## 第二部分

## 1、hexo基本配置

    在文件根目录下的_config.yml，就是整个hexo框架的配置文件了。可以在里面修改大部分的配置。详细可参考官方的配置描述。

### 1.网站

![](https://i.imgur.com/uzNRp60.png)
    
    description主要用于SEO，告诉搜索引擎一个关于您站点的简单描述，通常建议在其中包含您网站的关键词。
    author参数用于主题显示文章的作者。
    language可以用来解决菜单中文乱码，设置language字段如下:
        language: zh-Hans 或者 anguage: zh-CN
        取决于你的主题theme目录下的language目录下有zh-Hans.yml还是zh-CN.yml
    timezone，东八区设置是 Asia/Shanghai

### 2.网址

![](https://i.imgur.com/DuDMHGc.png)

    在这里，你需要把url改成你的网站域名，也就是第一步仓库地址的那个，https://xxx.github.io/
    permalink，也就是你生成某个文章时的那个链接格式。
    比如我新建一个文章叫temp.md，那么这个时候他自动生成的地址就是http://yoursite.com/2018/09/05/temp。

    以下是官方给出的示例，关于链接的变量还有很多，需要的可以去官网上查找 永久链接 。
![](https://i.imgur.com/w9srSbP.png)  

    网站存放在子目录
    如果您的网站存放在子目录中，例如 http://yoursite.com/blog，则请将您的 url 设为 http://yoursite.com/blog 并把 root 设为 /blog/。

    再往下翻，中间这些都默认就好了。

    theme: landscape
    theme就是选择什么主题，也就是在theme这个文件夹下，在官网上有很多个主题，默认给你安装的是lanscape这个主题。当你需要更换主题时，在官网上下载，把主题的文件放在theme文件夹下，再修改这个参数就可以了。

    # Deployment
    ## Docs: https://hexo.io/docs/deployment.html
    deploy:
      type: git
      repo: <repository url>
      branch: [branch]
    deploy就是网站的部署的，repo就是仓库(Repository)的简写。branch选择仓库的哪个分支。而这个在后面进行双平台部署的时候会再次用到。

### 3.Front-matter

    Front-matter 是文件最上方以 --- 分隔的区域，用于指定个别文件的变量，举例来说：
    title: Hello World
    date: 2013/7/13 20:46:25
    ---

    下面这些是预先定义的参数，您可在模板中使用这些参数值并加以利用。
![](https://i.imgur.com/JO3DePn.png)

    其中，分类和标签需要区别一下，分类具有顺序性和层次性，也就是说 Foo, Bar 不等于 Bar, Foo；而标签没有顺序和层次。

### 4.layout(布局)

    当你每一次使用代码:hexo new paper,它其实默认使用的是post这个布局，也就是在source文件夹下的_post里面。

    Hexo 有三种默认布局：post、page 和 draft，它们分别对应不同的路径，而您自定义的其他布局和 post 相同，都将储存到 source/_posts 文件夹。
![](https://i.imgur.com/BJqguol.png)

    而new这个命令其实是：hexo new [layout] <title>,只不过这个layout默认是post罢了。

### 5.page

    如果你想另起一页，那么可以使用:hexo new page board
    系统会自动给你在source文件夹下创建一个board文件夹，以及board文件夹中的index.md，这样你访问的board对应的链接就是http://xxx.xxx/board

### 6.draft

    draft是草稿的意思，也就是你如果想写文章，又不希望被看到，那么可以:hexo new draft newpage
    
    这样会在source/_draft中新建一个newpage.md文件，如果你的草稿文件写的过程中，想要预览一下，那么可以使用:hexo server --draft,在本地端口中开启服务预览。

    如果你的草稿文件写完了，想要发表到post中，hexo publish draft newpage,就会自动把newpage.md发送到post中。

## 2、主题

### 1.更换主题

    如果觉得默认的landscape主题不好看，那么可以在官网的主题中，选择你喜欢的一个主题下载，然后进行修改就可以了。

    进入到博客目录执行如下命令，含义是克隆该主题并存入到博客文件夹下的thems文件下里
    git clone https://github.com/litten/hexo-theme-yilia.git themes/yilia

    执行后就会在博客目录文件夹的themes中可以找到有yilia的文件。
    找到博客根目录下的_config.yml文件，修改里面的配置
    将theme 修改为theme: yilia，需要注意的是冒号后有空格

    进入yilia这个文件夹，可以看到里面也有一个配置文件_config.yml，这个配置文件是修改你整个主题的配置文件。

### 2.menu(菜单栏)

    也即是如下图所示的这些东西：
![](https://i.imgur.com/LeIG3lQ.png)

    其中，About这个你是找不到网页的，因为你的文章中没有about这个东西。如果你想要的话，可以执行命令：hexo new page about
    它就会在根目录下source文件夹中新建了一个about文件夹，以及index.md，在index.md中写上你想要写的东西，就可以在网站上展示出来了。

    如果你想要自己再自定义一个菜单栏的选项，那么就：hexo new page yourdiy
    然后在主题配置文件的menu菜单栏添加一个 Yourdiy : /yourdiy，注意冒号后面要有空格，以及前面的空格要和menu中默认的保持整齐。然后在languages文件夹中，找到zh-CN.yml，在index中添加yourdiy: '中文意思'就可以显示中文了。

### 3.customize(定制)

    可以修改你的个人logo，默认是那个yilia，在source/css/images文件夹中放入自己要的logo，再改一下url的链接名字就可以了。
    favicon是网站中出现的那个小图标的icon，找一张你喜欢的logo，然后转换成ico格式，放在images文件夹下，配置一下路径就行。
    social_links ，可以显示你的社交链接，而且是有logo的。

 
### 4.添加RSS
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
    3.在主题配置文件中设置：rss: /atom.xml，开启RSS的页面功能，这样你网站上就有那个像wifi一样符号的RSS logo了，注意空格。
    
### 5.widgets(侧边栏)

    侧边栏的小标签，如果你想自己增加一个，比如我增加了一个联系方式，那么我把communication写在上面，在zh-CN.yml中的sidebar，添加communication: '中文'。

    然后在hueman/layout/widget中添加一个communicaiton.ejs，填入模板：

### 6.search(搜索框)

    默认搜索框是不能够用的，需要安装插件：hexo-generator-json-content

### 7.comment(评论系统)

    valine好像不错，还能统计文章阅读量，可以自己试一试

-总结：
    
    整个主题看起来好像很复杂的样子，但是仔细捋一捋其实也比较流畅，
    
        languages: 顾名思义
        layout：布局文件，其实后期想要修改自定义网站上的东西，添加各种各样的信息，主要是在这里修改，其中comment是评论系统，common是常规的布局，最常修改的在这里面，比如修改页面head和footer的内容。
        scripts：js脚本，暂时没什么用
        source：里面放了一些css的样式，以及图片

## 3、git分支进行多终端工作

    利用git的分支系统进行多终端工作了，这样每次打开不一样的电脑，只需要进行简单的配置和在github上把文件同步下来，就可以无缝操作了。

### 1.机制

    由于hexo d上传部署到github的其实是hexo编译后的文件，是用来生成网页的，不包含源文件，也就是上传的是在本地目录里自动生成的.deploy_git里面。其他文件 ，包括我们写在source 里面的，和配置文件，主题文件，都没有上传到github。所以可以利用git的分支管理，将源文件上传到github的另一个分支即可。

### 2.上传分支

    先在github上新建一个hexo分支，如图：
    然后在这个仓库的settings中，选择默认分支为hexo分支（这样每次同步的时候就不用指定分支，比较方便）。

