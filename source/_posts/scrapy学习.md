---
title: scrapy学习
date: {{date}}
tags:
- Python
- Scrapy
categories:
- Python
password: 
---

### scrapy是什么 
	Scrapy 是用 Python 实现的一个为了爬取网站数据、提取结构性数据而编写的应用框架。常应用在包括数据挖掘，信息处理或存储历史数据等一系列的程序中。通常我们可以很简单的通过 Scrapy 框架实现一个爬虫，抓取指定网站的内容或图片。

### scrapy架构图
    绿线是数据流向
![](https://i.imgur.com/RpWDwoz.png)

    Scrapy Engine(引擎): 负责Spider、ItemPipeline、Downloader、Scheduler中间的通讯，信号、数据传递等。
    Scheduler(调度器): 它负责接受引擎发送过来的Request请求，并按照一定的方式进行整理排列，入队，当引擎需要时，交还给引擎。

<escape><!-- more --></escape>

    Downloader（下载器）：负责下载Scrapy Engine(引擎)发送的所有Requests请求，并将其获取到的Responses交还给Scrapy Engine(引擎)，由引擎交给Spider来处理，
    Spider（爬虫）：它负责处理所有Responses,从中分析提取数据，获取Item字段需要的数据，并将需要跟进的URL提交给引擎，再次进入Scheduler(调度器).
    Item Pipeline(管道)：它负责处理Spider中获取到的Item，并进行进行后期处理（详细分析、过滤、存储等）的地方。
    Downloader Middlewares（下载中间件）：你可以当作是一个可以自定义扩展下载功能的组件。
    Spider Middlewares（Spider中间件）：你可以理解为是一个可以自定扩展和操作引擎和Spider中间通信的功能组件（比如进入Spider的Responses;和从Spider出去的Requests）

    注意！只有当调度器中不存在任何request了，整个程序才会停止，（也就是说，对于下载失败的URL，Scrapy也会重新下载。）

    制作 Scrapy 爬虫 一共需要4步：

    新建项目 (scrapy startproject xxx)：新建一个新的爬虫项目
    明确目标 （编写items.py）：明确你想要抓取的目标
    制作爬虫 （spiders/xxspider.py）：制作爬虫开始爬取网页
    存储内容 （pipelines.py）：设计管道存储爬取内容


### scrapy安装
	1. 如果你用的是Anaconda或者Minconda，可以使用下面的命令：conda install -c conda-forge scrapy
	2. 如果你已经安装了python包管理工具PyPI，可以使用下面命令进行安装：pip install Scrapy。值得注意的是，如果你使用的是pip安装，你需要解决相应的包依赖。
	
	scrapy依赖的一些包：
	lxml：一种高效的XML和HTML解析器，
	PARSEL：一个HTML / XML数据提取库，基于上面的lxml，
	w3lib：一种处理URL和网页编码多功能辅助
	twisted,：一个异步网络框架
	cryptography and pyOpenSSL，处理各种网络级安全需求
	
	以上包需要的最低版本：
	Twisted 14.0
	lxml 3.4
	pyOpenSSL 0.14
	
	常见依赖问题:
	1.错误提示：ModuleNotFoundError: No module named 'win32api'
	解决方法：
	(1)到这个网站下载跟使用的Python版本相匹配的软件：https://github.com/mhammond/pywin32/releases
	(2)进入使用的Python解释器里的Scripts目录，里面有一个easy_install.exe文件
	(3)打开命令行，使用如下命令进行安装：easy_install.exe pywin32-224.win-amd64-py3.6.exe
	2.错误提示：building 'twisted.test.raiser' extension
	解决方法：
	(1)到这个网站下载跟使用的Python版本相匹配的软件：https://www.lfd.uci.edu/~gohlke/pythonlibs/#twisted
	(2)进入使用的Python解释器里的Scripts目录，里面有一个pip.exe文件
	(3)打开命令行，使用如下命令进行安装：pip.exe Twisted-18.9.0-cp36-cp36m-win_amd64.whl

#### win7安装scrapy
	推荐使用Anaconda进行安装

#### CentOS 7安装scrapy
	CentOS 7系统自带的python版本是2.7，若是python3.5+版本，则不用再安装pip了。
	(1)安装pip
	# yum -y install epel-release
	# yum install python-pip
	# pip install --upgrade pip
	(2)安装依赖包
	# yum install gcc libffi-devel python-devel openssl-devel -y
	(3)安装scrapy
	# pip install scrapy

### scrapy入门
#### 新建项目
	在开始爬取之前，首先要创建一个scrapy项目，在命令行输入一下命令即可创建:
	# scrapy startproject mySpider
	scrapy  startproject是固定写法，注意scrapy和startproject和mySpider中间是有空格的！ 
    mySpider 为项目名称，可以看到将会创建一个 mySpider 文件夹，目录结构大致如下：
    mySpider/
        scrapy.cfg
        mySpider/
            __init__.py
            items.py
            pipelines.py
            settings.py
            spiders/
                __init__.py
                ......

    这些文件分别是:
        scrapy.cfg: 项目的配置文件。
        mySpider/: 项目的Python模块，将会从这里引用代码。
        mySpider/items.py: 项目的目标文件。
        mySpider/pipelines.py: 项目的管道文件。
        mySpider/settings.py: 项目的设置文件。
        mySpider/spiders/: 存储爬虫代码目录。

#### 明确目标
    打开 mySpider 目录下的 items.py，
    Item 定义结构化数据字段，用来保存爬取到的数据，有点像 Python 中的 dict，但是提供了一些额外的保护减少错误。
    可以通过创建一个 scrapy.Item 类， 并且定义类型为 scrapy.Field 的类属性来定义一个 Item（可以理解成类似于 ORM 的映射关系）。
    创建一个 ItcastItem 类，和构建 item 模型（model）：
    import scrapy

    class ItcastItem(scrapy.Item):
       name = scrapy.Field()
       title = scrapy.Field()
       info = scrapy.Field()

#### 制作爬虫
	命令：scrapy genspider mingyan2 mingyan2.com
	mingyan2为蜘蛛名，mingyan2.com为要爬取的网站地址

#### 运行蜘蛛
	命令：scrapy crawl  mingyan2
	要重点提醒一下，我们一定要进入：mingyan 这个目录，也就是我们创建的蜘蛛项目目录，以上命令才有效！还有 crawl 后面跟的mingyan2是你类里面定义的蜘蛛名，也就是：name，并不是项目名、也不是类名。

#### scrapy start_url（初始链接）的两种不同写法
	第一种：
	start_urls = [  # 另外一种写法，无需定义start_requests方法
	    'http://lab.scrapyd.cn/page/1/',
	    'http://lab.scrapyd.cn/page/2/',
	]，
	必须定义一个方法为：def parse(self, response)，方法名一定是：parse
	第二种：
	自己定义一个start_requests()方法
	
	示例代码：
	"""
	scrapy初始Url的两种写法，
	一种是常量start_urls，并且需要定义一个方法parse（）
	另一种是直接定义一个方法：star_requests()
	"""
	import scrapy
	class simpleUrl(scrapy.Spider):
	    name = "simpleUrl"
	    start_urls = [  #另外一种写法，无需定义start_requests方法
	        'http://lab.scrapyd.cn/page/1/',
	        'http://lab.scrapyd.cn/page/2/',
	    ]
	
	    # 另外一种初始链接写法
	    # def start_requests(self):
	    #     urls = [ #爬取的链接由此方法通过下面链接爬取页面
	    #         'http://lab.scrapyd.cn/page/1/',
	    #         'http://lab.scrapyd.cn/page/2/',
	    #     ]
	    #     for url in urls:
	    #         yield scrapy.Request(url=url, callback=self.parse)
	    # 如果是简写初始url，此方法名必须为：parse
	
	    def parse(self, response):
	        page = response.url.split("/")[-2]
	        filename = 'mingyan-%s.html' % page
	        with open(filename, 'wb') as f:
	            f.write(response.body)
	        self.log('保存文件: %s' % filename)

#### scrapy调试工具：scrapy shell使用方法
	进入scrapy shell调试命令：scrapy shell http://lab.scrapyd.cn
	scrapy shell 是固定格式，后面跟的是你要调试的页面。这段代码就是一个下载的过程，一执行这么一段代码scrapy就立马把我们相应链接的相应页面给拿到了

#### scrapy css选择器使用
	进入scrapy shell调试命令：scrapy shell http://lab.scrapyd.cn
	在命令行输入如下命令：
	>>> response.css('title') 
	[<Selector xpath='descendant-or-self::title' data='<title>SCRAPY爬虫实验室 - SCRAPY中文网提供</title>'>]
	使用这个命令提取的一个Selector的列表，并不是我们想要的数据；那我们再使用scrapy给我们准备的一些函数来进一步提取，那我们改变一下上面的写法，
	>>> response.css('title').extract()
	['<title>SCRAPY爬虫实验室 - SCRAPY中文网提供</title>']
	我们只是在后面加入了：extract() 这么一个函数你就提取到了我们标签的一个列表，更近一步了，那如果我们不要列表，只要title这个标签，要怎么处理呢，看我们的输入：
	>>>  response.css('title').extract()[0]
	'<title>爬虫实验室 - SCRAPY中文网提供</title>'
	这里的话，我们只需要在后面添加：[0]，那代表提取这个列表中的第一个元素，那就得到了我们的title字符串；这里的话scrapy也给我提供了另外一个函数，可以这样来写，一样的效果：
	>>>  response.css('title').extract_first()
	'<title>爬虫实验室 - SCRAPY中文网提供</title>'
	extract_first()就代表提取第一个元素，和我们的：[0]，一样的效果，只是更简洁些，
	至此我们已经成功提取到了我们的title，但是你会发现，肿么多了一个title标签，这并不是你需要的，那要肿么办呢，
	我们可以继续改变一下以上的输入：
	>>> response.css('title::text').extract_first()
	'爬虫实验室 - SCRAPY中文网提供'
	在title后面加上了 ::text ,这代表提取标签里面的数据，至此，我们已经成功提取到了我们需要的数据：
	'爬虫实验室 - SCRAPY中文网提供'
	总结一下，其实就这么一段代码：
	response.css('title::text').extract_first()

#### scrapy提取一组数据
	class选择器使用的是".",比如.text ，如果是id选择器的话：使用"#",比如 #text
	示例代码：
	import scrapy
	
	class itemSpider(scrapy.Spider):
	    name = 'itemSpider'
	    start_urls = ['http://lab.scrapyd.cn']
	
	    def parse(self, response):
	        mingyan = response.css('div.quote')[0]
	
	        text = mingyan.css('.text::text').extract_first()  # 提取名言
	        autor = mingyan.css('.author::text').extract_first()  # 提取作者
	        tags = mingyan.css('.tags .tag::text').extract()  # 提取标签
	        tags = ','.join(tags)  # 数组转换为字符串
	
	        fileName = '%s-语录.txt' % autor  # 爬取的内容存入文件，文件名为：作者-语录.txt
	        f = open(fileName, "a+")  # 追加写入文件
	        f.write(text)  # 写入名言内容
	        f.write('\n')  # 换行
	        f.write('标签：'+tags)  # 写入标签
	        f.close()  # 关闭文件操作

#### scrapy 爬取多条数据
	这次比上次唯一多了个递归调用，我们来看一下关键变化，原先我们取出一条数据，用的是如下表达式：mingyan = response.css('div.quote')[0]
	我们在后面添加了游标 [0]  表示只取出第一条，那我们要取出全部，那我们就不用加了，直接：mingyan = response.css('div.quote')
	那现在的变量就是一个数据集，里面有多条数据了，那接下来我们要做的就是循环取出数据集里面的每一条数据，那我们看一下怎么做：
	mingyan = response.css('div.quote')  # 提取首页所有名言，保存至变量mingyan
	for v in mingyan:  # 循环获取每一条名言里面的：名言内容、作者、标签
	    text = v.css('.text::text').extract_first()  # 提取名言
	    autor = v.css('.author::text').extract_first()  # 提取作者
	    tags = v.css('.tags .tag::text').extract()  # 提取标签
	    tags = ','.join(tags)  # 数组转换为字符串
	    # 接下来，进行保存
	
	可以看到，关键是：for v in mingyan:
	表示把 mingyan 这个数据集里面的数据，循环赋值给：v ，第一次循环的话 v 就代表第一条数据，
	那text = v.css('.text::text').extract_first() 就代表第一条数据的名言内容，以此类推，把所有数据都取了出来，最终进行保存，我们看一下完整的代码：
	import scrapy
	
	class itemSpider(scrapy.Spider):
	
	    name = 'listSpider'
	
	    start_urls = ['http://lab.scrapyd.cn']
	
	    def parse(self, response):
	        mingyan = response.css('div.quote')  # 提取首页所有名言，保存至变量mingyan
	
	        for v in mingyan:  # 循环获取每一条名言里面的：名言内容、作者、标签
	
	            text = v.css('.text::text').extract_first()  # 提取名言
	            autor = v.css('.author::text').extract_first()  # 提取作者
	            tags = v.css('.tags .tag::text').extract()  # 提取标签
	            tags = ','.join(tags)  # 数组转换为字符串
	
	            """
	            接下来进行写文件操作，每个名人的名言储存在一个txt文档里面
	            """
	            fileName = '%s-语录.txt' % autor  # 定义文件名,如：木心-语录.txt
	
	            with open(fileName, "a+") as f:  # 不同人的名言保存在不同的txt文档，“a+”以追加的形式
	                f.write(text)
	                f.write('\n')  # ‘\n’ 表示换行
	                f.write('标签：' + tags)
	                f.write('\n-------\n')
	                f.close()

#### scrapy 爬取下一页
	要爬取下一页，那我们首先要分析链接格式，找到下一页的链接，那爬取就简单了。下一页的链接如下：
	<li class="next">
	    <a href="http://lab.scrapyd.cn/page/2/">下一页 »</a>
	</li>
	每爬一页就用css选择器来查询，是否存在下一页链接，存在：则爬取下一页链接：http://lab.scrapyd.cn/page/*/，
	然后把下一页链接提交给当前爬取的函数，继续爬取，继续查找下一页，知道找不到下一页，说明所有页面已经爬完，那结束爬虫。
![](https://i.imgur.com/y1pDfXA.png)

    爬取内容的代码和上一文档（listSpider）一模一样，唯一区别的是这么一个地方，我们在：listSpider 蜘蛛下面添加了这么几段代码：
    next_page = response.css('li.next a::attr(href)').extract_first()  
            if next_page is not None: 
                next_page = response.urljoin(next_page)
                yield scrapy.Request(next_page, callback=self.parse)
    首先：我们使用：response.css('li.next a::attr(href)').extract_first()查看有木有存在下一页链接，如果存在的话，我们使用：urljoin(next_page)把相对路径，如：page/1转换为绝对路径，其实也就是加上网站域名，如：http://lab.scrapyd.cn/page/1；
    接下来就是爬取下一页或是内容页的秘诀所在，scrapy给我们提供了这么一个方法：scrapy.Request()
    这个方法还有许多参数，后面我们慢慢说，这里我们只使用了两个参数，一个是：我们继续爬取的链接（next_page），
    这里是下一页链接，当然也可以是内容页；另一个是：我们要把链接提交给哪一个函数爬取，这里是parse函数，也就是本函数；
    当然，我们也可以在下面另写一个函数，比如：内容页，专门处理内容页的数据。
    经过这么一个函数，下一页链接又提交给了parse，那就可以不断的爬取了，直到不存在下一页；

#### scrapy arguments：指定蜘蛛参数爬取
	scrapy提供了可传参的爬虫，首先按scrapy 参数格式定义好参数，如下：
	def start_requests(self):
	    url = 'http://lab.scrapyd.cn/'
	    tag = getattr(self, 'tag', None)  # 获取tag值，也就是爬取时传过来的参数
	    if tag is not None:  # 判断是否存在tag，若存在，重新构造url
	        url = url + 'tag/' + tag  # 构造url若tag=爱情，url= "http://lab.scrapyd.cn/tag/爱情"
	    yield scrapy.Request(url, self.parse)  # 发送请求爬取参数内容
	可以看到   tag = getattr(self, 'tag', None)  就是获取传过来的参数，然后根据不同的参数，构造不同的url，然后进行不同的爬取，经过这么一个处理，我们的蜘蛛就灰常的灵活了，我们来看一下完整代码：
	# -*- coding: utf-8 -*-
	
	import scrapy
	
	class ArgsspiderSpider(scrapy.Spider):
	
	        name = "argsSpider"
	    
	        def start_requests(self):
	            url = 'http://lab.scrapyd.cn/'
	            tag = getattr(self, 'tag', None)  # 获取tag值，也就是爬取时传过来的参数
	            if tag is not None:  # 判断是否存在tag，若存在，重新构造url
	                url = url + 'tag/' + tag  # 构造url若tag=爱情，url= "http://lab.scrapyd.cn/tag/爱情"
	            yield scrapy.Request(url, self.parse)  # 发送请求爬取参数内容
	    
	        """
	        以下内容为上一讲知识，若不清楚具体细节，请查看上一讲！
	        """
	    
	        def parse(self, response):
	            mingyan = response.css('div.quote')
	            for v in mingyan:
	                text = v.css('.text::text').extract_first()
	                tags = v.css('.tags .tag::text').extract()
	                tags = ','.join(tags)
	                fileName = '%s-语录.txt' % tags
	                with open(fileName, "a+") as f:
	                    f.write(text)
	                    f.write('\n')
	                    f.write('标签：' + tags)
	                    f.write('\n-------\n')
	                    f.close()
	            next_page = response.css('li.next a::attr(href)').extract_first()
	            if next_page is not None:
	                next_page = response.urljoin(next_page)
	                yield scrapy.Request(next_page, callback=self.parse)
	
	要如何传参,可以这样：scrapy crawl argsSpider -a tag=爱情

### 详解scrapy
#### scrapy如何打开页面
	那蜘蛛要发送请求，那总得要有请求链接，如果木有，蜘蛛肯定得不到返回，那页面也就打不开了，因此引出了scrapy spiders的第一个必须的常量：start_urls
	URL有两种写法，一种作为类的常量、一种作为start_requests(self)方法的常量，无论哪一种写法，URL都是必须的！
	有了URL那就可以发送请求了，如果URL是定义在start_request(self)这个方法里面，那我们就要使用： yield scrapy.Request 方法发送请求：如下：
	
	import scrapy
	
	class simpleUrl(scrapy.Spider):
	
	    name = "simpleUrl"
	
	    # 另外一种初始链接写法
	    def start_requests(self):
	         urls = [ #爬取的链接由此方法通过下面链接爬取页面
	             'http://lab.scrapyd.cn/page/1/',
	             'http://lab.scrapyd.cn/page/2/',
	         ]
	         for url in urls:
	            #发送请求
	             yield scrapy.Request(url=url, callback=self.parse)
	
	这样写的一个麻烦之处就是我们需要处理我们的返回，也就是我们还需要写一个callback方法来处理response；
	因此大多数我们都是把URL作为类的常量，然后再加上另外一个方法： parse(response)
	
	使用这个方法来发送请求，可以看到里面有个参数已经是：response（返回），也就是说这个方法自动化的完成了：request（请求页面）-response（返回页面）的过程，我们就不必要再写函数接受返回
	
	import scrapy
	
	class simpleUrl(scrapy.Spider):
	
	    name = "simpleUrl"
	
	    start_urls = [  #另外一种写法，无需定义start_requests方法
	        'http://lab.scrapyd.cn/page/1/',
	        'http://lab.scrapyd.cn/page/2/',
	    ]
	
	    def parse(self, response):
	        page = response.url.split("/")[-2]
	        filename = 'mingyan-%s.html' % page
	        with open(filename, 'wb') as f:
	            f.write(response.body)
	        self.log('保存文件: %s' % filename)

#### scrapy css选择器
    和scrapy相关的函数就这么三个而已：response.css("css表达式")、extract()、extract_first()。
    有变化的就是：css表达式的写法,按照HTML标签的结构可以分为：标签属性值提取、标签内容提取
    1. 标签属性值的提取 
    提取属性是用：“标签名::attr(属性名)”，首先找到要提取的标签最近的class或id，缩小范围！
    比如我们要提取url表达式就是：a::attr(href)，要提取图片地址的表达式就是：img::attr(src)
    限定一下提取的范围，最好的方法就是找到要提取目标最近的class或是id，可以看到这段代码中有个class="page-navigator"，那我们就可以这样来写：response.css(".page-navigator a::attr(href)").extract()
    
    说明：.page-navigator，其中点代表class选择器，如果代码中是：id=“page-navigator”，那我们这里就要写成：“#page-navigator”
    
    2. 标签内容的提取
    提取标签内容是用：“::text”
    含有嵌套标签文字的提取：response.css(".post-content *::text").extract()
    可以看到，“::tex“t前面有个“*”号，表示当前class或id下所有标签
    
    3. CSS 高级用法
    CSS选择器用于选择你想要的元素的样式的模式。"CSS"列表示在CSS版本的属性定义（CSS1，CSS2，或对CSS3）
![](https://i.imgur.com/og423tA.png)

#### scrapy xpath选择器
    从几个方面说：一、属性提取；二、内容提取；三、标签内包含标签又包含标签的最外层标签里的所有内容提取；
    1. scrapy xpath 属性提取
    XPath 使用路径表达式在 XML 文档中选取节点。节点是通过沿着路径或者 step 来选取的。 下面列出了最有用的路径表达式：
![](https://i.imgur.com/lBSiyp1.png)

	调试的话我们还是在命令行使用下面命令：scrapy shell lab.scrapyd.cn
	函数：response.xpath("表达式")，提取属性的话既然使用：@，那我们要提取href就是：@href，试一下：response.xpath("//@href")
	限定我们的属性，使用的是：标签[@属性名='属性值']；
	表达式就是：//@属性名，缩小标签范围、限定属性的方式
	
	2. scrapy xpath 标签内容提取
	表达式为：//text() 
	
	3. 包含HTML标签的所有文字内容提取
	这种用法主要是提取一些内容页，标签里夹杂着文字，但我们只要文字！比如下面的这段代码：
	<div class="post-content" itemprop="articleBody">
       <p>如果你因失去了太阳而流泪，那么你也将失去群星了。 
       <br>If you shed tears when you miss the sun, you also miss the stars. 
       </p>
       <p><a href="http://www.scrapyd.cn">scrapy中文网（</a><a href="http://www.scrapyd.cn">http://www.scrapyd.cn</a>）整理</p>        
    </div>
    如果我们用表达式：//div[@class='post-content']//text()，你会发现虽然能提取但是一个列表，不是整段文字。
    那就用到一个xpath函数：string()，可以把表达式这样写：response.xpath("string(//div[@class='post-content'])").extract()，可看到我们没有使用：text()，而是用：string(要提取内容的标签)，这样的话就能把数据都提取出来了，而且都合成为一条，并非一个列表。
    这一种用法在我们提取商品详情、小说内容的时候经常用到

    4. xpath实例
![](https://i.imgur.com/x5llaYF.png)

### scrapy命令行工具
    1. scrapy全局命令
    scrapy startproject project_name
    scrapy genspider example example.com (cd project_name)
    scrapy crawl XX（运行XX蜘蛛）
    scrapy shell www.example.com
    (1)startproject
    创建项目的，如，创建一个名为：scrapyChina的项目：scrapy strartproject scrapychina
	(2)genspider
    根据蜘蛛模板创建蜘蛛的命令
    (3)settings
    scray设置参数,比如我们想得到蜘蛛的下载延迟，我们可以使用：scrapy settings --get DOWNLOAD_DELAY;比如我们想得到蜘蛛的名字：scrapy settings --get BOT_NAME
    (4)runspider
    运行蜘蛛除了使用：scrapy crawl XX之外，我们还能用：runspider，
    前者是基于项目运行，后者是基于文件运行，也就是说你按照scrapy的蜘蛛格式编写了一个py文件，那你不想创建项目，那你就可以使用runspider，比如你编写了一个：scrapyd_cn.py的蜘蛛，你要直接运行就是：scrapy runspider scrapy_cn.py
    (5)shell
    主要是调试用
    (6)fetch
    模拟蜘蛛下载页面，也就是说用这个命令下载的页面就是蜘蛛运行时下载的页面，好处是能准确诊断出，得到的html结构到底是不是我们所看到的，然后能及时调整我们编写爬虫的策略。演示window下如下如何把下载的页面保存：scrapy fetch http://www.scrapyd.cn >d:/3.html
    (7)view
    和fetch类似都是查看蜘蛛看到的是否和你看到的一致，便于排错，用法：scrapy view http://www.scrapyd.cn
    (8)version
    查看scrapy版本，用法：scrapy version

    2. scrapy项目命令
    需要在项目文件夹下面打开CMD命令，然后再执行下面的这些命令
    (1)crawl
    运行蜘蛛
    (2)check
    检查蜘蛛
    (3)list
    显示有多少个蜘蛛,这里的蜘蛛就是指spider文件夹下面xx.py文件中定义的name，你有10个py文件但是只有一个定义了蜘蛛的name，那只算一个蜘蛛