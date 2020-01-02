---
title: Elasticsearch 使用URI Search
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
在Elasticsearch中，我们可以使用_search终端进行搜索。这个在我之前的文章 “开始使用Elasticsearch （2）” 中有很多的描述。针对这种搜索，我们可以使用强大的DSL进行搜索。在Elasticsearch中，还有一类是基于URI的搜索。对于这种它可以很方便地直接在浏览器中的地址栏或命令行中直接使用。 使用此模式执行搜索时，并非所有搜索选项都公开，但是对于快速的“curl tests”来说，它可能很方便。在今天的文章中，我们来做一个简单的描述。同时我需要指出来的是，这里的语法和Kibana中的Search Bar搜索语法是一样的。

安装Elastic Stack

# 准备好数据

为了说明问题的方便，我们首先在Kibana中使用如下的bulk指令来创建我们的twitter索引。
```
    POST _bulk
    { "index" : { "_index" : "twitter", "_id": 1} }
    {"user":"张三","message":"今儿天气不错啊，出去转转去","uid":2,"age":20,"city":"北京","province":"北京","country":"中国","address":"中国北京市海淀区","location":{"lat":"39.970718","lon":"116.325747"}, "DOB":"1980-12-01"}
    { "index" : { "_index" : "twitter", "_id": 2 }}
    {"user":"老刘","message":"出发，下一站云南！","uid":3,"age":30,"city":"北京","province":"北京","country":"中国","address":"中国北京市东城区台基厂三条3号","location":{"lat":"39.904313","lon":"116.412754"}, "DOB":"1981-12-01"}
    { "index" : { "_index" : "twitter", "_id": 3} }
    {"user":"李四","message":"happy birthday!","uid":4,"age":30,"city":"北京","province":"北京","country":"中国","address":"中国北京市东城区","location":{"lat":"39.893801","lon":"116.408986"}, "DOB":"1982-12-01"}
    { "index" : { "_index" : "twitter", "_id": 4} }
    {"user":"老贾","message":"123,gogogo","uid":5,"age":35,"city":"北京","province":"北京","country":"中国","address":"中国北京市朝阳区建国门","location":{"lat":"39.718256","lon":"116.367910"}, "DOB":"1983-12-01"}
    { "index" : { "_index" : "twitter", "_id": 5} }
    {"user":"老王","message":"Happy BirthDay My Friend!","uid":6,"age":50,"city":"北京","province":"北京","country":"中国","address":"中国北京市朝阳区国贸","location":{"lat":"39.918256","lon":"116.467910"}, "DOB":"1984-12-01"}
    { "index" : { "_index" : "twitter", "_id": 6} }
    {"user":"老吴","message":"好友来了都今天我生日，好友来了,什么 birthday happy 就成!","uid":7,"age":90,"city":"上海","province":"上海","country":"中国","address":"中国上海市闵行区","location":{"lat":"31.175927","lon":"121.383328"}, "DOB":"1985-12-01"}
```
这里总共有6条数据。

![](https://img-blog.csdnimg.cn/20191127142118762.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

<escape><!-- more --></escape>

下面，我们来进行一些查询的动作。

# 搜索数据

首先，我们做一个简单的搜索，我们可以在浏览器中打入如下的命令：
```
GET twitter/_search?q=user:张三
```

![](https://img-blog.csdnimg.cn/20191127135815101.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们通过 “q=user:张三” 查询到我们所需要的文档。在有的时候这是一种非常快的查询方式。我们也可以在浏览器中直接打入一个这样的URI:
```
http://localhost:9200/_search?q=user:%E5%BC%A0%E4%B8%89&pretty
```
![](https://img-blog.csdnimg.cn/20191127141955433.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

或者在命令行中：

![](https://img-blog.csdnimg.cn/20191127141256540.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

下面，我们将使用Kibana来展示使用URI搜索的一些最基本的特点。

URI查询使用语法根据运算符（例如OR，AND或NOT）解析和拆分提供的查询字符串

我们想使用sort来对数据进行排序：
```
GET twitter/_search?q=city:"北京"&sort=DOB:desc
```
![](https://img-blog.csdnimg.cn/20191127142458792.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

上面显示了所有来自北京的用户，并按照出生年月降序排列。

假如我们只想在_source里显示年龄，DOB及城市信息，我们可以这么做：
```
GET twitter/_search?q=city:"北京"&sort=DOB:desc&_source=city,age,DOB
```
![](https://img-blog.csdnimg.cn/20191127142805436.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

从上面的显示可以看出来，我们只看到有三个字段显示出来。加入我们想分页，每个页只有2个文档，那么我们可以这么做：
```
GET twitter/_search?q=city:"北京"&sort=DOB:desc&_source=city,age,DOB&size=2
```
![](https://img-blog.csdnimg.cn/20191127143052982.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

从上面的显示上我们可以看出来，只有两个文档被显示出来尽管总共有5个文档满足条件。

假如这个时候，我们想对city为“上海”和“北京”的所有用户都来统计一下，那么我们可以使用如下的语句：
```
GET twitter/_search?q=city:("北京" or "上海") &sort=DOB:desc&_source=city,age,DOB&size=2
```
![](https://img-blog.csdnimg.cn/20191127143524402.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

显然这个时候，我们得到了6条数据。上海和北京的所有用户都被搜索出来了。

假如我们想查询来自“北京”并且名字叫做“张三”的文档，那么我们可以这么查询：
```
GET twitter/_search?q=city:"北京" AND user:"张三
```
![](https://img-blog.csdnimg.cn/20191127143951188.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

从上面可以看出来就只有一条数据。

假如我们想得到来除了上海以外地区的所有的用户，那么我们可以使用如下的方法来得到：
```
GET twitter/_search?q=NOT city:"上海"
```
![](https://img-blog.csdnimg.cn/20191127144339230.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们看到了5个数据。

我们也可以对某些想进行加权，以使得它们能够排在更前面，比如：

![](https://img-blog.csdnimg.cn/20191127145331295.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

上面的查询是寻找年龄是20岁的，或者是来自上海的人。从搜索的结果来看，我们可以看到上海的老吴是排在前面。如果我们想对年龄为20岁的人需要有更多的关注，那么我们可以对它们的搜索结果进行加权，这样会使得它们的分数更高。我们可以采用如下的方法来做：
```
GET twitter/_search?q=(age:20^5 OR city:"上海")
```
在上面，我们显然对age为20的这个选项进行了加权。那么搜索后的结果为：

![](https://img-blog.csdnimg.cn/20191127145736782.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们可以看到现在age为20岁的张三排到了搜索结果的前面。

假如我们不指定任何的field的话，那么这个搜索将对所有的field都进行：
```
GET twitter/_search?q=张三
```
![](https://img-blog.csdnimg.cn/20191127145944685.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

当然我们也可以进行fuzzy搜索：
![](https://img-blog.csdnimg.cn/20191127150607291.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

上面标明有一个edit错误也可以被搜索出来。对于中文的检索，这个依赖于分词器。在我们的实验中没有使用具体的分词器。这个和实际的使用可能会有区别。

我们也可以对一下范围进行搜索：
```
GET twitter/_search?q=age:[20 TO 30]
```
![](https://img-blog.csdnimg.cn/20191127151021117.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

上面搜索的结果是从20岁到30岁的所有的结果，并且都包含在里面。我们如果不想包含30岁的话，那么可以写成这样的格式：

![](https://img-blog.csdnimg.cn/20191127151230592.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们使用`[20 TO 30}`， 如果我们想搜索在30岁一下的所有文档，那么我们可以使用如下的搜索方式：

![](https://img-blog.csdnimg.cn/20191127151413346.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

在这里，我们使用`[* TO 30}`，这里不包含30。

好了今天就讲到这里。这里的所有的语法也适用于在Kibana中的Search Bar。如果我们熟练地掌握了这些，也可以很方便地让我们熟练地操作Kibana中搜索。

参考：

【1】https://www.elastic.co/guide/en/elasticsearch/reference/current/query-filter-context.html
【2】https://www.elastic.co/guide/en/elasticsearch/reference/7.4/search-uri-request.html
