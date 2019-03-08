---
title: Hexo搭建教程(4)
date: {{ date }}
tags: 
  - hexo
categories:
- hexo 
top: 70
---

## 第三部分

    我这个博客采用的是next主题，接下来把我博客关于主题的配置汇总一下，给使用该主题的其他用户做个参考。

- 安装主题
- 启用主题
- 选择Scheme 
- 设置语言
- 设置菜单
- 分类/标签
- 添加fork me on github
- 动态背景
- 添加点击爱心效果
- 设置RSS
- 修改文章底部的那个带#号的标签
- 在每篇文章末尾统一添加“本文结束”标记
- 侧边栏社交小图标设置
- 主页文章加阴影
- 设置网站图标
- 设置旋转头像
- 开启打赏功能
- 设置首页不显示全文(只显示预览)
- 文章字数统计和阅读时长
- 文章底部增加版权信息
- 网站底部字数统计
- 隐藏网页底部 由Hexo强力驱动
- 修改网页底部的桃心
- 修改文章内链接文本样式
- 添加顶部加载条
- 修改字体大小
- 文章加密访问
- 添加jiathis分享
- 博文置顶
- 自定义鼠标样式
- 为博客加上萌萌的宠物
- 搜索功能
- 双击鼠标显示爆炸效果
- 自定义文章的默认头部信息
- 文章标签显示设置
- 在底部增加运行时间
- 利用 Gulp 来压缩你的 Hexo 博客的静态文件
- 添加网站和文章分享按钮
- 压缩页面静态资源
- 删除博文目录自动生成的序数
- 不蒜子统计
- 添加友情链接
- 腾讯公益404页面
- 设置动画效果
- 添加近期文章版块

<escape><!-- more --></escape>

### 安装主题
    在博客根目录下打开命令行输入以下命令：
    git clone https://github.com/theme-next/hexo-theme-next themes/next
    就会将将next主题下载到当前目录下的themes里面的next文件夹中

### 启用主题
    在博客根目录下修改站点配置文件_config.yml
    # Extensions
    ## Plugins: https://hexo.io/plugins/
    ## Themes: https://hexo.io/themes/
    theme: next
    注意冒号后面有个空格

### 选择 Scheme 
    Scheme是NexT提供的一种特性，借助于Scheme，NexT为你提供多种不同的外观。
    同时，几乎所有的配置都可以在Scheme之间共用。目前 NexT 支持四种 Scheme，他们是：
    Muse - 默认 Scheme，这是 NexT 最初的版本，黑白主调，大量留白
    Mist - Muse 的紧凑版本，整洁有序的单栏外观
    Pisces - 双栏 Scheme，小家碧玉似的清新
    Gemini - 左侧网站信息及目录，块+片段结构布局
    
    scheme 的切换通过更改主题配置文件，搜索Schemes关键字。我选择的是scheme: Gemini
    你会看到有四行scheme的配置，将你需用启用的scheme前面注释 # 去除即可。
    然后使用命令：hexo s --debug，打开浏览器输入地址：127.0.0.1:4000即可查看效果

### 设置语言
    编辑站点配置文件，将language设置成你所需要的语言，建议明确设置你所需要的语言，例如选用简体中文。
    配置如下：language: zh-Hans。注意这个要看主题文件夹中的语言包中文语言包的名称，我设置的是language: zh-Hans
    注意：使用hexo s预览的时候，会发现是设置了语言之后界面还是英文，此时使用hexo clean清理下database文件夹以及public文件夹就行了，然后再使用hexo s 预览。

### 设置菜单
    菜单配置包括三个部分，第一是菜单项（名称和链接），第二是菜单项的显示文本，第三是菜单项对应的图标。 
    NexT使用的是Font Awesome提供的图标， Font Awesome提供了600+的图标，可以满足绝大的多数的场景，同时无须担心在Retina屏幕下图标模糊的问题。

    编辑主题配置文件，修改以下内容：
    设定菜单内容，对应的字段是 menu。 菜单内容的设置格式是：item name: link || 图标。其中 item name 是一个名称，这个名称并不直接显示在页面上，它将用于匹配图标以及翻译。
    
    我的设置如下：
    menu:
      home: / || home
      tags: /tags/ || tags
      categories: /categories/ || th
      archives: /archives/ || archive
      about: /about/ || user
    显示效果如下：
![](https://i.imgur.com/Mw8BUEY.png)

    关于设置的是英语，网站显示的是中文，这个要如何理解？
    1. 主题配置文件中菜单设置的是英文，但是站点配置文件配置的网站语言是zh-Hans，也就是简体中文。
    2. 此时，访问网站的话菜单会从主题文件的语言包中找到zh-Hans.yml这个中文语言包，查找其中是否有关于menu的翻译，若有，则网站上显示出来。如下图所示：
![](https://i.imgur.com/ZmDSwtR.png)

### 分类/标签
    比如设置的有分类，但是点击进去却报错：Cannot GET /tags/，不能获取tags，默认这些需要我们自己创建。
    介绍一下创建page的语法：hexo new page 'name'
    在控制台输入以下命令：
    hexo new page 'tags'       #创建tags子目录
    hexo new page 'categories' #创建categories子目录
    hexo new page 'about'      #创建about子目录
    在你的网站根目录下面的source文件夹会分别生成tags、categories以及about文件夹。

    修改tags文件夹中的index.md文件，新增type属性，如下：
    ---
    title: tags
    date: 2018-01-04 11:45:41
    type: "tags"
    ---
    其他的修改类似。这样一来当你新建一篇博文的时候，增加上tags和categories属性值，就能在tags和categories界面检索到你的文章了。 
    
    汇总一下步骤：

    tags:添加「标签」页面
    新建「标签」页面，并在菜单中显示「标签」链接。「标签」页面将展示站点的所有标签，若你的所有文章都未包含标签，此页面将是空的。 底下代码是一篇包含标签的文章的例子： 
    ---
    title: 标签测试文章
    tags:
      - Testing
      - Another Tag
    ---
    或者使用这种方式：tags: [Testing, Another Tag],中间是先逗号，后空格

    1. 修改菜单
    在菜单中添加链接。编辑 主题配置文件 ， 添加 tags 到 menu 中，如下: 
    menu:
      home: / || home
      archives: /archives || archives
      tags: /tags || tags
    2. 新建页面
    在终端窗口下，定位到 Hexo 站点目录下。使用 hexo new page 新建一个页面，命名为 tags ：
    $ cd your-hexo-site
    $ hexo new page tags
    3. 设置页面类型
    编辑刚新建的页面，将页面的类型设置为 tags ，主题将自动为这个页面显示标签云。页面内容如下：
    ---
    title: tags
    date: 2014-12-22 12:39:04
    type: "tags"
    ---
    注意：如果有集成评论服务，页面也会带有评论。 若需要关闭的话，请添加字段 comments 并将值设置为 false，如： 
    ---
    title: tags
    date: 2014-12-22 12:39:04
    type: "tags"
    comments: false
    ---

    categories:添加「分类」页面
    新建「分类」页面，并在菜单中显示「分类」链接。「分类」页面将展示站点的所有分类，若你的所有文章都未包含分类，此页面将是空的。 底下代码是一篇包含分类的文章的例子：
    ---
    title: 分类测试文章
    categories: 
    - Testing
    ---

    1. 修改菜单
    在菜单中添加链接。编辑 主题配置文件 ， 添加 categories 到 menu 中，如下: 
    menu:
      home: / || home
      archives: /archives || archives
      categories: /categories || categories
    2. 新建页面
    在终端窗口下，定位到 Hexo 站点目录下。使用 hexo new page 新建一个页面，命名为 categories ：
    $ cd your-hexo-site
    $ hexo new page categories
    3. 设置页面类型
    编辑刚新建的页面，将页面的 type 设置为 categories ，主题将自动为这个页面显示分类。页面内容如下：
    ---
    title: categories
    date: 2014-12-22 12:39:04
    type: "categories"
    ---
    注意：如果有集成评论服务，页面也会带有评论。 若需要关闭的话，请添加字段 comments 并将值设置为 false，如： 
    ---
    title: categories
    date: 2014-12-22 12:39:04
    type: "categories"
    comments: false
    ---

    分类和标签的差别：
    在 Hexo 中：分类具有顺序性和层次性，也就是说 Foo, Bar 不等于 Bar, Foo；而标签没有顺序和层次。

### 添加fork me on github
    在http://tholman.com/github-corners/或者https://github.com/blog/273-github-ribbons
    选择合适的样式复制代码到themes/next/layout/_layout.swig，在<div class="headband"></div>下面： 
![](https://i.imgur.com/vXQJwuF.png)

    我选用的效果：
![](https://i.imgur.com/2eQivHp.png)

### 动态背景
    目前NexT主题有4种动态背景，设置方法也很简单，直接设置里需要的动态背景为true：
    - Canvas-nest
    - three_waves
    - canvas_lines
    - canvas_sphere
    我设置的是：canvas_nest: true

### 添加点击爱心效果
    在/themes/next/source/js/src下新建文件love.js，接着把该代码拷贝粘贴到love.js文件中。
    代码如下：
    !
    function(e, t, a) {
        function n() {
            c(".heart{width: 10px;height: 10px;position: fixed;background: #f00;transform: rotate(45deg);-webkit-transform: rotate(45deg);-moz-transform: rotate(45deg);}.heart:after,.heart:before{content: '';width: inherit;height: inherit;background: inherit;border-radius: 50%;-webkit-border-radius: 50%;-moz-border-radius: 50%;position: fixed;}.heart:after{top: -5px;}.heart:before{left: -5px;}"),
            o(),
            r()
        }
        function r() {
            for (var e = 0; e < d.length; e++) d[e].alpha <= 0 ? (t.body.removeChild(d[e].el), d.splice(e, 1)) : (d[e].y--, d[e].scale += .004, d[e].alpha -= .013, d[e].el.style.cssText = "left:" + d[e].x + "px;top:" + d[e].y + "px;opacity:" + d[e].alpha + ";transform:scale(" + d[e].scale + "," + d[e].scale + ") rotate(45deg);background:" + d[e].color + ";z-index:99999");
            requestAnimationFrame(r)
        }
        function o() {
            var t = "function" == typeof e.onclick && e.onclick;
            e.onclick = function(e) {
                t && t(),
                i(e)
            }
        }
        function i(e) {
            var a = t.createElement("div");
            a.className = "heart",
            d.push({
                el: a,
                x: e.clientX - 5,
                y: e.clientY - 5,
                scale: 1,
                alpha: 1,
                color: s()
            }),
            t.body.appendChild(a)
        }
        function c(e) {
            var a = t.createElement("style");
            a.type = "text/css";
            try {
                a.appendChild(t.createTextNode(e))
            } catch(t) {
                a.styleSheet.cssText = e
            }
            t.getElementsByTagName("head")[0].appendChild(a)
        }
        function s() {
            return "rgb(" + ~~ (255 * Math.random()) + "," + ~~ (255 * Math.random()) + "," + ~~ (255 * Math.random()) + ")"
        }
        var d = [];
        e.requestAnimationFrame = function() {
            return e.requestAnimationFrame || e.webkitRequestAnimationFrame || e.mozRequestAnimationFrame || e.oRequestAnimationFrame || e.msRequestAnimationFrame ||
            function(e) {
                setTimeout(e, 1e3 / 60)
            }
        } (),
        n()
    } (window, document);
    然后修改_layout.swig，在\themes\next\layout\_layout.swig文件末尾添加：  
    <!-- 页面点击小红心 -->
    <script type="text/javascript" src="/js/src/love.js"></script>
    效果如下：
![](https://i.imgur.com/sANksxb.png)

### 设置RSS
    在博客个目录下运行命令行，安装插件：npm install --save hexo-generator-feed，
    然后打开站点配置文件，在末尾添加如下内容： (请注意在冒号后面要加一个空格，不然会发生错误！)
    # Extensions
    ## Plugins: https://hexo.io/plugins/
    #RSS订阅
    plugin:
    - hexo-generator-feed
    最后在next主题配置文件中找到rss,设置成：rss: /atom.xml。
    配置完之后运行：hexo g,重新生成一次，你会在./public 文件夹中看到 atom.xml 文件。
    效果展示：
![](https://i.imgur.com/l3Aj2n6.png)

### 修改文章底部的那个带#号的标签
    默认文章底部会出现# test的标签，现在修改该标签显示，把#换成其他样式：
    修改模板/themes/next/layout/_macro/post.swig，搜索 rel="tag">#，将#换成<i class="fa fa-tag"></i>
![](https://i.imgur.com/mynZnVs.png)

### 在每篇文章末尾统一添加“本文结束”标记
    在路径 \themes\next\layout\_macro 中新建 passage-end-tag.swig 文件,并添加以下内容： 
    <div> 
    {% if not is_index %} 
        <div style="text-align:center;color: #ccc;font-size:14px;">-------------本文结束 <i class="fa fa-paw"></i> 感谢您的阅读-------------</div> 
    {% endif %} 
    </div>
    接着打开\themes\next\layout\_macro\post.swig文件，在post-body 之后， 添加以下代码： 
    <div>
        {% if not is_index %}
            {% include 'passage-end-tag.swig' %}
        {% endif %}
    </div>
    添加位置如图：
![](https://i.imgur.com/yJBLDX0.png)

    然后打开主题配置文件（_config.yml),在末尾添加：
    # 文章末尾添加“本文结束”标记
    passage_end_tag:
    enabled: true
    完成以上设置之后，在每篇文章之后都会显示如下图的效果。
![](https://i.imgur.com/gGJjy8Q.png) 

### 侧边栏社交小图标设置
    打开主题配置文件_config.yml，搜索social:, ||之后是在图标库中对应的图标。注意空格就行。
    图标库链接：http://fontawesome.io/icons/
    我的配置如下图：
![](https://i.imgur.com/EehAb9Y.png)

    social_icons:
      enable: true
      icons_only: false
      transition: true

    效果如下图：
![](https://i.imgur.com/k3N5Chu.png)

### 主页文章加阴影
    打开\themes\next\source\css\_custom\custom.styl,向里面加入：
    // 主页文章添加阴影效果 
    .post { 
        margin-top: 60px; 
        margin-bottom: 60px; 
        padding: 25px; 
        -webkit-box-shadow: 0 0 5px rgba(202, 203, 203, .5); 
        -moz-box-shadow: 0 0 5px rgba(202, 203, 204, .5); 
    }

### 设置网站图标
    默认的网站图标是一个N，当然是需要制定一个图了，在网上找到图后，将其放在/themes/next/source/img里面，然后在主题配置文件中修改下图所示图片位置：
![](https://i.imgur.com/6YUPqCl.png)

### 设置旋转头像
    Hexo Next主题将头像显示成圆形，鼠标放上去有旋转效果。
    先设置头像，在网上找到图后，将其放在/themes/next/source/img里面，然后在主题配置文件中修改下图所示图片位置：
![](https://i.imgur.com/mJBylc2.png)
    
    然后找到/themes/next/source/css/_common/components/sidebar/sidebar-author.styl，把里面的内容替换如下：
    .site-author-image {
      display: block;
      margin: 0 auto;
      padding: $site-author-image-padding;
      max-width: $site-author-image-width;
      height: $site-author-image-height;
      border: $site-author-image-border-width solid $site-author-image-border-color;
    }
    
    .site-author-name {
      margin: $site-author-name-margin;
      text-align: $site-author-name-align;
      color: $site-author-name-color;
      font-weight: $site-author-name-weight;
    }
    
    .site-description {
      margin-top: $site-description-margin-top;
      text-align: $site-description-align;
      font-size: $site-description-font-size;
      color: $site-description-color;
    }
    
    .site-author-image {
    	display: block;
    	margin: 0 auto;
    	padding: $site-author-image-padding;
    	max-width: $site-author-image-width;
    	height: $site-author-image-height;
    	border: $site-author-image-border-width solid $site-author-image-border-color;
    	/* 头像圆形*/
    	border-radius: 80px;
    	-webkit-border-radius: 80px;
    	-moz-border-radius: 80px;
    	box-shadow: inset 0 -1px 0 #333sf;
    	/* 设置循环动画 [animation: (play)动画名称 (2s)动画播放时长单位秒或微秒 (ase-out)动画播放的速度曲线为以低速结束 (1s)等待1秒然后开始动画 (1)动画播放次数(infinite为循环播放) ]*/
    	/* 鼠标经过头像旋转360度*/
    	-webkit-transition: -webkit-transform 1.0s ease-out;
    	-moz-transition: -moz-transform 1.0s ease-out;
    	transition: transform 1.0s ease-out;
    }
    img:hover {
    	/* 鼠标经过停止头像旋转 -webkit-animation-play-state:paused;
    	animation-play-state:paused;*/
    	/* 鼠标经过头像旋转360度*/
    	-webkit-transform: rotateZ(360deg);
    	-moz-transform: rotateZ(360deg);
    	transform: rotateZ(360deg);
    }
    /* Z 轴旋转动画*/
    	@-webkit-keyframes play {
    	0% {
    	-webkit-transform: rotateZ(0deg);
    }
    100% {
    	-webkit-transform: rotateZ(-360deg);
    }
    } @-moz-keyframes play {
    	0% {
    	-moz-transform: rotateZ(0deg);
    }
    100% {
    	-moz-transform: rotateZ(-360deg);
    }
    } @keyframes play {
    	0% {
    	transform: rotateZ(0deg);
    }
    100% {
    	transform: rotateZ(-360deg);
    }
    }

### 开启打赏功能
    主题配置文件，修改信息如下，同时把微信和支付宝收款码保存到指定路径：
![](https://i.imgur.com/4wCIBvM.png)

    打赏功能文件路径：\themes\next\layout\_macro\reward.swig

### 设置首页不显示全文(只显示预览)
    打开主题配置文件_config.yml，ctrl + F搜索找到"auto_excerpt"，可以看见
    # Automatically Excerpt. Not recommand.
    # Please use <!-- more --> in the post to control excerpt accurately.
    auto_excerpt:
        enable: false
        length: 150
    length就是预览显示的文字长度
    第一种方法：修改如上的配置，把enable对应的false改为true，然后hexo d -g即可
    第二种方法：在_post目录下的文章中适当位置添加上<escape><!-- more --></escape>，顶行写，即可。
    若两种方法同时存在，则优先使用第二种

### 文章字数统计和阅读时长
    NexT主题默认已经集成了文章【字数统计】、【阅读时长】统计功能。
    如果我们需要使用，只需要在主题配置文件(\themes\next\_config.yml)中打开wordcount 统计功能即可。
    post_wordcount:
      item_text: true
      wordcount: true
      min2read: true
      totalcount: true
      separated_meta: false
    最后一个separated_meta是换行显示的，不用开启
    仅仅只是打开开关，部署之后会发现文章的【字数统计】和【阅读时长】后面没有对应的xxx字，xx分钟等字样，只有光秃秃的数字在那里。
    找到themes\next\layout\_macro\post.swig 文件
    - 字数统计
    添加 “字”到{{ wordcount(post.content) }} 后面，修改后为：
    <span title="{{ __('post.wordcount') }}">
        {{ wordcount(post.content) }} 字
    </span>
    - 阅读时长
    添加 “分钟”到{{ min2read(post.content) }} 后面，修改后为：
    <span title="{{ __('post.min2read') }}">
       {{ min2read(post.content) }} 分钟
    </span>
    再次运行，就能得到正常的如“字数统计 1888字”“阅读时长 6分钟”这样的样式了，如下图所示：
![](https://i.imgur.com/H4SfbYL.png)

### 文章底部增加版权信息
    在主题配置文件中找到post_copyright，把enable的值修改成true,然后找到themes\next\layout\_macro\post-copyright.swig文件修改如下：
    <div class="post-copyright">
      <li class="post-copyright-title">
        <strong>{{ __('本文标题') + __('symbol.colon') }}</strong>
        {{ page.title }}
      </li>
      <li class="post-copyright-author">
        <strong>{{ __('文章作者') + __('symbol.colon') }}</strong>
        {{ post.author | default(config.author) }}
      </li>
        <li class="post-copyright-author">
        <strong>{{ __('发布时间') + __('symbol.colon') }}</strong>
        {{ page.date.format("YYYY年MM月DD日 - HH:MM:SS") }}
      </li>
        <li class="post-copyright-author">
        <strong>{{ __('更新时间') + __('symbol.colon') }}</strong>
        {{ page.updated.format("YYYY年MM月DD日 - HH:MM:SS") }}
      </li>
      <li class="post-copyright-link">
        <strong>{{ __('本文链接') + __('symbol.colon') }}</strong>
        <a href="{{ url_for(page.path) }}" title="{{ page.title }}">{{ page.permalink }}</a>
        <span class="copy-path"  title="点击复制文章链接"><i class="fa fa-clipboard" data-clipboard-text="{{ page.permalink }}"  aria-label="复制成功！"></i></span>
      </li>
      <li class="post-copyright-license">
        <strong>{{ __('post.copyright.license_title') + __('symbol.colon') }} </strong>
        <i class="fa fa-creative-commons"></i> <a rel="license" href="https://creativecommons.org/licenses/by-nc-nd/4.0/" target="_blank" title="Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)">署名-非商业性使用-禁止演绎 4.0 国际</a> 转载请保留原文链接及作者。
      </li>
    </div>
    
    <script> 
        var clipboard = new Clipboard('.fa-clipboard');
    	  $(".fa-clipboard").click(function(){
          clipboard.on('success', function(){
            swal({   
              title: "",   
              text: '复制成功',
              icon: "success", 
              showConfirmButton: true
              });
    	    });
        });  
    </script>
    实现效果：
![](https://i.imgur.com/plEvfdi.png)
    
### 网站底部字数统计
    安装插件：npm install hexo-wordcount --save
    因为在[文章字数统计和阅读时长]中有一个totalcount: true，默认已经开启该功能了，找到如下文件：themes\next\layout\_partials\footer.swig，修改如下，显示‘字’：
![](https://i.imgur.com/emTnWEj.png)

    效果如下：
![](https://i.imgur.com/BlepAIz.png)

### 隐藏网页底部 由Hexo强力驱动
    在主题配置文件中找到powered，设置成false即可。

### 修改网页底部的桃心
    打开themes/next/layout/_partials/footer.swig，找到：
![](https://i.imgur.com/Zil0rL9.png)

    然后还是在[图标库](http://fontawesome.io/icons/ "图标库")中找到你自己喜欢的图标，然后修改画红线的部分就可以了。
![](https://i.imgur.com/ZyUxJkp.png)

### 修改文章内链接文本样式
    修改文件 themes\next\source\css\_common\components\post\post.styl ，在末尾添加如下css样式：
    // 文章内链接文本样式
    .post-body p a{
      color: #0593d3;
      border-bottom: none;
      border-bottom: 1px solid #0593d3;
      &:hover {
        color: #fc6423;
        border-bottom: none;
        border-bottom: 1px solid #fc6423;
      }
    }
    其中选择 .post-body 是为了不影响标题，选择 p 是为了不影响首页“阅读全文”的显示样式,颜色可以自己定义。

### 添加顶部加载条
    进入博客文件夹的/themes/next文件夹下,
    下载安装Progress module:git clone https://github.com/theme-next/theme-next-pace source/lib/pace
    修改主题配置文件(_config.yml),修改如下：
    # Progress bar in the top during page loading.
    # Dependencies: https://github.com/theme-next/theme-next-pace
    pace: true #是否开启进度条
    # Themes list:
    # pace-theme-big-counter | pace-theme-bounce | pace-theme-barber-shop | pace-theme-center-atom
    # pace-theme-center-circle | pace-theme-center-radar | pace-theme-center-simple | pace-theme-corner-indicator
    # pace-theme-fill-left | pace-theme-flash | pace-theme-loading-bar | pace-theme-mac-osx | pace-theme-minimal
    # For example
    pace_theme: pace-theme-center-atom #选择进度条样式

### 修改字体大小
    在主题目录配置文件下，查找font：
    font:
      enable: true
    
      # Uri of fonts host. E.g. //fonts.googleapis.com (Default).
      host:
    
      # body元素的字体设置
      global:
        external: true
        family: Lato
        size: 18
    
      # 标题的基础字体设置
      headings:
        external: true
        family:
        size: 30
    
      # 文章字体设置
      posts:
        external: true
        family: 18
    
      # logo字体设置
      logo:
        external: true
        family:
        size: 30
    
      # 代码块字体设置
      codes:
        external: true
        family:
        size: 13
    把false改为true，并修改了size的数值，单位是像素。如有需要可自行改变字体。

    另外提供一种方法，供会前端的小伙伴参考：Next主题控制字体大小的文件是在主题文件夹中的 source\css_variables 目录下的 base.styl 文件，
    找到该文件：themes\next\source\css_variables\base.styl 文件.
    // Font size
    $font-size-base           = 16px    //修改以前是14，我改成了16
    $font-size-small          = $font-size-base - 2px
    $font-size-smaller        = $font-size-base - 4px
    $font-size-large          = $font-size-base + 2px
    $font-size-larger         = $font-size-base + 4px
    
    // Headings font size
    $font-size-headings-step    = 2px
    $font-size-headings-base    = 24px  //这个是标题大小，如果你觉得不满意，可以改的更大一点
    修改完之后，保存文件。重新部署 hexo ，就可以看到博客字体已经变成你想要的大小了。

### 文章加密访问
    先安装插件：npm install hexo-blog-encrypt --save
    在根目录中package.json中添加依赖："hexo-blog-encrypt": "2.0.*"
    在站点配置文件中开启，没有则添加：
    # Security
    encrypt:
        enable: true
    打开主题目录下layout/_partials/head.swig文件,在meta标签后面插入这样一段代码：
    <script>
        (function(){
            if('{{ page.password }}'){
                if (prompt('请输入文章密码') !== '{{ page.password }}'){
                    alert('密码错误！');
                    history.back();
                }
            }
        })();
    </script>
![](https://i.imgur.com/q7h8pMY.png)

    然后文章头部信息中添加password：
    password: 你设置的密码
![](https://i.imgur.com/toIlveV.png)

    如果password后面为空，则表示不用密码。

### 添加jiathis分享
    主题配置文件，设置如下：
    # JiaThis 分享服务
    jiathis: true

### 博文置顶
    修改 hero-generator-index 插件，把文件：node_modules/hexo-generator-index/lib/generator.js 内的代码替换为：
    'use strict';
    var pagination = require('hexo-pagination');
    module.exports = function(locals){
      var config = this.config;
      var posts = locals.posts;
        posts.data = posts.data.sort(function(a, b) {
            if(a.top && b.top) { // 两篇文章top都有定义
                if(a.top == b.top) return b.date - a.date; // 若top值一样则按照文章日期降序排
                else return b.top - a.top; // 否则按照top值降序排
            }
            else if(a.top && !b.top) { // 以下是只有一篇文章top有定义，那么将有top的排在前面（这里用异或操作居然不行233）
                return -1;
            }
            else if(!a.top && b.top) {
                return 1;
            }
            else return b.date - a.date; // 都没定义按照文章日期降序排
        });
      var paginationDir = config.pagination_dir || 'page';
      return pagination('', posts, {
        perPage: config.index_generator.per_page,
        layout: ['index', 'archive'],
        format: paginationDir + '/%d/',
        data: {
          __index: true
        }
      });
    };
    在文章中添加 top 值，数值越大文章越靠前，如：
    ---
    title: Hexo搭建教程(1)
    date: {{ date }}
    tags: 
    - hexo
    categories:
    - hexo
    top: 100
    ---
https://www.easyicon.net/download/ico/1230452/96/

    添加置顶标志：到next\layout_macro下的post.swig，找到<div class="post-meta"> ，在下面添加对应代码
    {% if post.top == 100 %} 
        <i class="fa fa-thumb-tack"></i> 
        <font color=808080>置顶</font> 
        <span class="post-meta-divider">|</span> 
    {% endif %}

### 自定义鼠标样式
    打开themes/next/source/css/_custom/custom.styl,在里面写下如下代码：
    // 鼠标样式
    * {
        cursor: url("http://om8u46rmb.bkt.clouddn.com/sword2.ico"),auto!important
    }
    :active {
        cursor: url("http://om8u46rmb.bkt.clouddn.com/sword1.ico"),auto!important
    }

    其中 url 里面必须是 ico 图片，ico 图片可以上传到网上，然后获取外链，复制到 url 里就行了

### 为博客加上萌萌的宠物
    安装插件：npm install -save hexo-helper-live2d
    然后在博客站点的_config.yml 文件或主题的 _config.yml 文件中添加配置：
    live2d:
      enable: true
      scriptFrom: local
      pluginRootPath: live2dw/
      pluginJsPath: lib/
      pluginModelPath: assets/
      tagMode: false
      debug: false
      model:
        use: live2d-widget-model-wanko
      display:
        position: right
        width: 150
        height: 300
      mobile:
        show: true
    然后hexo clean ，hexo g ，hexo d 就可以看到了。
    可以自定义使用的宠物模型，地址：https://github.com/EYHN/hexo-helper-live2d/blob/master/README.zh-CN.md

### 搜索功能
    安装插件：npm install hexo-generator-search --save
    在主题配置文件下，查找local_search:
    local_search:
      enable: false
      trigger: auto
      top_n_per_article: 1
    enable的值修改为true
    在根目录配置文件中，添加以下代码：
    # 本地搜索功能
    search:
      path: search.xml
      field: post
      format: html
      limit: 10000

### 点击爆炸效果
    首先在themes/next/source/js/src里面建一个叫fireworks.js的文件，代码如下：
    "use strict";
    function updateCoords(e) {
        pointerX = (e.clientX || e.touches[0].clientX) - canvasEl.getBoundingClientRect().left,
        pointerY = e.clientY || e.touches[0].clientY - canvasEl.getBoundingClientRect().top
    }
    function setParticuleDirection(e) {
        var t = anime.random(0, 360) * Math.PI / 180,
        a = anime.random(50, 180),
        n = [ - 1, 1][anime.random(0, 1)] * a;
        return {
            x: e.x + n * Math.cos(t),
            y: e.y + n * Math.sin(t)
        }
    }
    function createParticule(e, t) {
        var a = {};
        return a.x = e,
        a.y = t,
        a.color = colors[anime.random(0, colors.length - 1)],
        a.radius = anime.random(16, 32),
        a.endPos = setParticuleDirection(a),
        a.draw = function() {
            ctx.beginPath(),
            ctx.arc(a.x, a.y, a.radius, 0, 2 * Math.PI, !0),
            ctx.fillStyle = a.color,
            ctx.fill()
        },
        a
    }
    function createCircle(e, t) {
        var a = {};
        return a.x = e,
        a.y = t,
        a.color = "#F00",
        a.radius = 0.1,
        a.alpha = 0.5,
        a.lineWidth = 6,
        a.draw = function() {
            ctx.globalAlpha = a.alpha,
            ctx.beginPath(),
            ctx.arc(a.x, a.y, a.radius, 0, 2 * Math.PI, !0),
            ctx.lineWidth = a.lineWidth,
            ctx.strokeStyle = a.color,
            ctx.stroke(),
            ctx.globalAlpha = 1
        },
        a
    }
    function renderParticule(e) {
        for (var t = 0; t < e.animatables.length; t++) {
            e.animatables[t].target.draw()
        }
    }
    function animateParticules(e, t) {
        for (var a = createCircle(e, t), n = [], i = 0; i < numberOfParticules; i++) {
            n.push(createParticule(e, t))
        }
        anime.timeline().add({
            targets: n,
            x: function(e) {
                return e.endPos.x
            },
            y: function(e) {
                return e.endPos.y
            },
            radius: 0.1,
            duration: anime.random(1200, 1800),
            easing: "easeOutExpo",
            update: renderParticule
        }).add({
            targets: a,
            radius: anime.random(80, 160),
            lineWidth: 0,
            alpha: {
                value: 0,
                easing: "linear",
                duration: anime.random(600, 800)
            },
            duration: anime.random(1200, 1800),
            easing: "easeOutExpo",
            update: renderParticule,
            offset: 0
        })
    }
    function debounce(e, t) {
        var a;
        return function() {
            var n = this,
            i = arguments;
            clearTimeout(a),
            a = setTimeout(function() {
                e.apply(n, i)
            },
            t)
        }
    }
    var canvasEl = document.querySelector(".fireworks");
    if (canvasEl) {
        var ctx = canvasEl.getContext("2d"),
        numberOfParticules = 30,
        pointerX = 0,
        pointerY = 0,
        tap = "mousedown",
        colors = ["#FF1461", "#18FF92", "#5A87FF", "#FBF38C"],
        setCanvasSize = debounce(function() {
            canvasEl.width = 2 * window.innerWidth,
            canvasEl.height = 2 * window.innerHeight,
            canvasEl.style.width = window.innerWidth + "px",
            canvasEl.style.height = window.innerHeight + "px",
            canvasEl.getContext("2d").scale(2, 2)
        },
        500),
        render = anime({
            duration: 1 / 0,
            update: function() {
                ctx.clearRect(0, 0, canvasEl.width, canvasEl.height)
            }
        });
        document.addEventListener(tap,
        function(e) {
            "sidebar" !== e.target.id && "toggle-sidebar" !== e.target.id && "A" !== e.target.nodeName && "IMG" !== e.target.nodeName && (render.play(), updateCoords(e), animateParticules(pointerX, pointerY))
        },
        !1),
        setCanvasSize(),
        window.addEventListener("resize", setCanvasSize, !1)
    }
    "use strict";
    function updateCoords(e) {
        pointerX = (e.clientX || e.touches[0].clientX) - canvasEl.getBoundingClientRect().left,
        pointerY = e.clientY || e.touches[0].clientY - canvasEl.getBoundingClientRect().top
    }
    function setParticuleDirection(e) {
        var t = anime.random(0, 360) * Math.PI / 180,
        a = anime.random(50, 180),
        n = [ - 1, 1][anime.random(0, 1)] * a;
        return {
            x: e.x + n * Math.cos(t),
            y: e.y + n * Math.sin(t)
        }
    }
    function createParticule(e, t) {
        var a = {};
        return a.x = e,
        a.y = t,
        a.color = colors[anime.random(0, colors.length - 1)],
        a.radius = anime.random(16, 32),
        a.endPos = setParticuleDirection(a),
        a.draw = function() {
            ctx.beginPath(),
            ctx.arc(a.x, a.y, a.radius, 0, 2 * Math.PI, !0),
            ctx.fillStyle = a.color,
            ctx.fill()
        },
        a
    }
    function createCircle(e, t) {
        var a = {};
        return a.x = e,
        a.y = t,
        a.color = "#F00",
        a.radius = 0.1,
        a.alpha = 0.5,
        a.lineWidth = 6,
        a.draw = function() {
            ctx.globalAlpha = a.alpha,
            ctx.beginPath(),
            ctx.arc(a.x, a.y, a.radius, 0, 2 * Math.PI, !0),
            ctx.lineWidth = a.lineWidth,
            ctx.strokeStyle = a.color,
            ctx.stroke(),
            ctx.globalAlpha = 1
        },
        a
    }
    function renderParticule(e) {
        for (var t = 0; t < e.animatables.length; t++) {
            e.animatables[t].target.draw()
        }
    }
    function animateParticules(e, t) {
        for (var a = createCircle(e, t), n = [], i = 0; i < numberOfParticules; i++) {
            n.push(createParticule(e, t))
        }
        anime.timeline().add({
            targets: n,
            x: function(e) {
                return e.endPos.x
            },
            y: function(e) {
                return e.endPos.y
            },
            radius: 0.1,
            duration: anime.random(1200, 1800),
            easing: "easeOutExpo",
            update: renderParticule
        }).add({
            targets: a,
            radius: anime.random(80, 160),
            lineWidth: 0,
            alpha: {
                value: 0,
                easing: "linear",
                duration: anime.random(600, 800)
            },
            duration: anime.random(1200, 1800),
            easing: "easeOutExpo",
            update: renderParticule,
            offset: 0
        })
    }
    function debounce(e, t) {
        var a;
        return function() {
            var n = this,
            i = arguments;
            clearTimeout(a),
            a = setTimeout(function() {
                e.apply(n, i)
            },
            t)
        }
    }
    var canvasEl = document.querySelector(".fireworks");
    if (canvasEl) {
        var ctx = canvasEl.getContext("2d"),
        numberOfParticules = 30,
        pointerX = 0,
        pointerY = 0,
        tap = "mousedown",
        colors = ["#FF1461", "#18FF92", "#5A87FF", "#FBF38C"],
        setCanvasSize = debounce(function() {
            canvasEl.width = 2 * window.innerWidth,
            canvasEl.height = 2 * window.innerHeight,
            canvasEl.style.width = window.innerWidth + "px",
            canvasEl.style.height = window.innerHeight + "px",
            canvasEl.getContext("2d").scale(2, 2)
        },
        500),
        render = anime({
            duration: 1 / 0,
            update: function() {
                ctx.clearRect(0, 0, canvasEl.width, canvasEl.height)
            }
        });
        document.addEventListener(tap,
        function(e) {
            "sidebar" !== e.target.id && "toggle-sidebar" !== e.target.id && "A" !== e.target.nodeName && "IMG" !== e.target.nodeName && (render.play(), updateCoords(e), animateParticules(pointerX, pointerY))
        },
        !1),
        setCanvasSize(),
        window.addEventListener("resize", setCanvasSize, !1)
    };
    打开themes/next/layout/_layout.swig,在</body>上面写下如下代码：
      <!-- 爆炸效果 -->
      {% if theme.fireworks %}
         <canvas class="fireworks" style="position: fixed;left: 0;top: 0;z-index: 1; pointer-events: none;" ></canvas> 
         <script type="text/javascript" src="//cdn.bootcss.com/animejs/2.2.0/anime.min.js"></script> 
         <script type="text/javascript" src="/js/src/fireworks.js"></script>
      {% endif %}
    打开主题配置文件，在里面最后写下：
    # Fireworks
    fireworks: true

### 自定义文章的默认头部信息
    在根目录的/scaffolds/post.md文件中添加：
    ---
    title: {{ title }}
    date: {{ date }}
    tags:                #标签
    categories:      #分类
    copyright: true #版权声明
    permalink: 01  #文章链接，有默认值
    top: 0              #置顶优先级
    password:      #密码保护
    ---

### 文章标签显示设置
    在主题配置文件中，查找post_meta：
    # 文章标签显示设置
    post_meta:
      item_text: true
      created_at: true  # 发表时间
      updated_at: false  # 更新时间
      categories: true  # 分类
    
    # 文章字数显示设置（需要wordcount，前面已经下载）
    post_wordcount:
      item_text: true
      wordcount: true  # 显示字数
      min2read: false   # 所需时间
      totalcount: false  # 总字数
      separated_meta: true # 分割符

### 在底部增加运行时间
    打开文件：\themes\next\layout\_partials\footer.swig，在最后添加如下代码：
    <!-- 在网页底部添加网站运行时间 --> 
    <span id="timeDate">载入天数...</span><span id="times">载入时分秒...</span> 
    <script> 
        var now = new Date(); 
        function createtime() { 
        var grt= new Date("03/01/2019 00:00:00");//此处修改你的建站时间或者网站上线时间,2019-03-01 
        now.setTime(now.getTime()+250); 
        days = (now - grt ) / 1000 / 60 / 60 / 24; 
        dnum = Math.floor(days); 
        hours = (now - grt ) / 1000 / 60 / 60 - (24 * dnum); 
        hnum = Math.floor(hours); 
        if(String(hnum).length ==1 ){hnum = "0" + hnum;} minutes = (now - grt ) / 1000 /60 - (24 * 60 * dnum) - (60 * hnum); 
        mnum = Math.floor(minutes); if(String(mnum).length ==1 ){mnum = "0" + mnum;} 
        seconds = (now - grt ) / 1000 - (24 * 60 * 60 * dnum) - (60 * 60 * hnum) - (60 * mnum); 
        snum = Math.round(seconds); 
        if(String(snum).length ==1 ){snum = "0" + snum;} 
        document.getElementById("timeDate").innerHTML = "博客已运行"+dnum+" 天 "; 
        document.getElementById("times").innerHTML = hnum + " 小时 " + mnum + " 分钟 " + snum + " 秒"; } setInterval("createtime()",250); 
    </script>

### 利用 Gulp 来压缩你的 Hexo 博客的静态文件
    首先安装gulp：npm install gulp
    继续安装依赖包：
    npm install --save-dev babel-cli
    npm install --save-dev babel-preset-es2015
    npm install gulp-minify-css gulp-babel gulp-uglify gulp-htmlmin gulp-htmlclean --save-dev
    在博客的根目录创建文件 gulpfile.js，代码如下：
    var gulp = require('gulp');
    var minifycss = require('gulp-minify-css');
    var babel = require('gulp-babel');
    var uglify = require('gulp-uglify');
    var htmlmin = require('gulp-htmlmin');
    var htmlclean = require('gulp-htmlclean');
    gulp.task('minify-css',
    function() {
        return gulp.src('./public/**/*.css').pipe(minifycss()).pipe(gulp.dest('./public'));
    });
    gulp.task('minify-html',
    function() {
        return gulp.src('./public/**/*.html').pipe(htmlclean()).pipe(htmlmin({
            removeComments: true,
            minifyJS: true,
            minifyCSS: true,
            minifyURLs: true,
        })).pipe(gulp.dest('./public'))
    });
    gulp.task('minify-js',
    function() {
        return gulp.src(['./public/**/*.js', '!./public/**/*.min.js']).pipe(babel({
            presets: ['es2015']
        })).pipe(uglify()).pipe(gulp.dest('./public'));
    });
    gulp.task('default', ['minify-html', 'minify-css', 'minify-js']);
    压缩方法：执行完hexo g 产生编译文件后，执行gulp，看到以下信息代表压缩成功，接下来使用hexo d 发布到服务器即可，可发现访问速度有了改善。
    执行gulp时报错：
    $ gulp
    internal/modules/cjs/loader.js:583
        throw err;
        ^
    Error: Cannot find module '@babel/core'
        at Function.Module._resolveFilename (internal/modules/cjs/loader.js:581:15)
        at Function.Module._load (internal/modules/cjs/loader.js:507:25)
        at Module.require (internal/modules/cjs/loader.js:637:17)
        at require (internal/modules/cjs/helpers.js:22:18)
        at Object.<anonymous> (D:\yongnights.github.io\node_modules\gulp-babel\index.js:7:15)
        at Module._compile (internal/modules/cjs/loader.js:689:30)
        at Object.Module._extensions..js (internal/modules/cjs/loader.js:700:10)
        at Module.load (internal/modules/cjs/loader.js:599:32)
        at tryModuleLoad (internal/modules/cjs/loader.js:538:12)
        at Function.Module._load (internal/modules/cjs/loader.js:530:3)
    该错误暂无法解决，故该方法先不执行。

### 添加网站和文章分享按钮
    安装插件：git clone https://github.com/theme-next/theme-next-needmoreshare2 themes/next/source/lib/needsharebutton
    themes/next/_config.yml，搜索needmoreshare2，修改如下：
    needmoreshare2:
      enable: true
      postbottom:
        enable: true #是否开启博客分享按钮
        options:
          iconStyle: box
          boxForm: horizontal
          position: bottomCenter
          networks: Weibo,Wechat,Douban,QQZone
      float:
        enable: true #网站分享按钮
        options:
          iconStyle: box
          boxForm: horizontal
          position: middleRight
          networks: Weibo,Wechat,Douban,QQZone

### 压缩页面静态资源
    安装插件：npm install hexo-neat --save
    打开博客站点配置文件，在最后添加如下信息：
    # hexo-neat
    # 博文压缩
    neat_enable: true
    # 压缩html
    neat_html:
      enable: true
      exclude:
    # 压缩css  
    neat_css:
      enable: true
      exclude:
        - '**/*.min.css'
    # 压缩js
    neat_js:
      enable: true
      mangle: true
      output:
      compress:
      exclude:
        - '**/*.min.js'
        - '**/jquery.fancybox.pack.js'
        - '**/index.js' 
        - '**/clicklove.js'
        - '**/fireworks.js'

### 删除博文目录自动生成的序数
    themes/next/_config.yml，搜索toc，修改如下：
    toc:
      enable: true
      # Automatically add list number to toc.
      number: false
      # If true, all words will placed on next lines if header width longer then sidebar width.
      wrap: false

### 不蒜子统计
    全局配置：
    编辑 主题配置文件 中的busuanzi_count的配置项。当enable: true时，代表开启全局开关。若site_uv、site_pv、page_pv的值均为false时，不蒜子仅作记录而不会在页面上显示。

    站点UV配置：
    当site_uv: true时，代表在页面底部显示站点的UV值。
    site_uv_header和site_uv_footer为自定义样式配置，相关的值留空时将不显示，可以使用（带特效的）font-awesome。显示效果为[site_uv_header]UV值[site_uv_footer]。
    # 效果：本站访客数12345人次
    site_uv: true
    site_uv_header: 本站访客数
    site_uv_footer: 人次

    站点PV配置：
    当site_pv: true时，代表在页面底部显示站点的PV值。
    site_pv_header和site_pv_footer为自定义样式配置，相关的值留空时将不显示，可以使用（带特效的）font-awesome。显示效果为[site_pv_header]PV值[site_pv_footer]。
    # 效果：本站总访问量12345次
    site_pv: true
    site_pv_header: 本站总访问量
    site_pv_footer: 次

    单页面PV配置：
    当page_pv: true时，代表在文章页面的标题下显示该页面的PV值（阅读数）。
    page_pv_header和page_pv_footer为自定义样式配置，相关的值留空时将不显示，可以使用（带特效的）font-awesome。显示效果为[page_pv_header]PV值[page_pv_footer]。
    # 效果：本文总阅读量12345次
    page_pv: true
    page_pv_header: 本文总阅读量
    page_pv_footer: 次

### 添加友情链接
    编辑 主题配置文件 添加：
    # Blog rolls
    links_icon: link
    links_title: 友情链接
    # links_layout: block
    links_layout: inline
    links:
      博客园: http://www.cnblogs.com/sanduzxcvbnm/
      百度: https://www.baidu.com/

### 腾讯公益404页面
    新建 404.html 页面，放到主题的 source 目录下，内容如下：
    <!DOCTYPE HTML>
    <html>
    <head>
      <meta http-equiv="content-type" content="text/html;charset=utf-8;"/>
      <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
      <meta name="robots" content="all" />
      <meta name="robots" content="index,follow"/>
      <link rel="stylesheet" type="text/css" href="https://qzone.qq.com/gy/404/style/404style.css">
    </head>
    <body>
      <script type="text/plain" src="http://www.qq.com/404/search_children.js"
              charset="utf-8" homePageUrl="/"
              homePageName="回到我的主页">
      </script>
      <script src="https://qzone.qq.com/gy/404/data.js" charset="utf-8"></script>
      <script src="https://qzone.qq.com/gy/404/page.js" charset="utf-8"></script>
    </body>
    </html>

### 设置动画效果
    NexT 默认开启动画效果，效果使用 JavaScript 编写，因此需要等待 JavaScript 脚本完全加载完毕后才会显示内容。 如果您比较在乎速度，可以将设置此字段的值为 false 来关闭动画。
    编辑 主题配置文件， 搜索 use_motion，根据您的需求设置值为 true 或者 false 即可： 
    use_motion: true  # 开启动画效果
    use_motion: false # 关闭动画效果

### 添加近期文章版块
    在next/layout/_macro/sidebar.swig中的if theme.links对应的endif后面添加如下代码：
`
{% if theme.recent_posts %}
    <div class="links-of-blogroll motion-element {{ "links-of-blogroll-" + theme.recent_posts_layout  }}">
      <div class="links-of-blogroll-title">
        <!-- modify icon to fire by szw -->
        <i class="fa fa-history fa-{{ theme.recent_posts_icon | lower }}" aria-hidden="true"></i>
        {{ theme.recent_posts_title }}
      </div>
      <ul class="links-of-blogroll-list">
        {% set posts = site.posts.sort('-date') %}
        {% for post in posts.slice('0', '5') %}
          <li>
            <a href="{{ url_for(post.path) }}" title="{{ post.title }}" target="_blank">{{ post.title }}</a>
          </li>
        {% endfor %}
      </ul>
    </div>
{% endif %}
`
    在主题的_config.yml中添加了几个变量，如下：
    recent_posts_title: 近期文章
    recent_posts_layout: block
    recent_posts: true
