---
title: Elasticsearch中text与keyword的区别
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
ES更新到5版本后，取消了 string 数据类型，代替它的是 keyword 和 text 数据类型.那么 text 和keyword有什么区别呢？
# 添加数据
使用bulk往es数据库中批量添加一些document
```
POST /book/novel/_bulk
{"index": {"_id": 1}}
{"name": "Gone with the Wind", "author": "Margaret Mitchell", "date": "2018-01-01"}
{"index": {"_id": 2}}
{"name": "Robinson Crusoe", "author": "Daniel Defoe", "date": "2018-01-02"}
{"index": {"_id": 3}}
{"name": "Pride and Prejudice", "author": "Jane Austen", "date": "2018-01-01"}
{"index": {"_id": 4}}
{"name": "Jane Eyre", "author": "Charlotte Bronte", "date": "2018-01-02"}
```
# 查看mapping
发现name、author的type是text，
还有个field是keyword，keyword的type是keyword：
![](/Elasticsearch中text与keyword的区别/1.png)

<escape><!-- more --></escape>

# 查询
使用term查询某个小说：
```
GET book/novel/_search
{
  "query": {
    "constant_score": {
      "filter": {
        "term": {
          "name": "Gone with the Wind"
        }
      },
      "boost": 1.2
    }
  }
}
```
结果是什么也没有查到：
![](/Elasticsearch中text与keyword的区别/2.png)


然后使用name的keyword查询：
```
GET book/novel/_search
{
  "query": {
    "constant_score": {
      "filter": {
        "term": {
          "name.keyword": "Gone with the Wind"
        }
      },
      "boost": 1.2
    }
  }
}
```
可以查询到一条数据：
![](/Elasticsearch中text与keyword的区别/3.png)

# 实验
使用name不能查到，而使用name.keyword可以查到，我们可以通过下面的实验来判断：

使用name进行分词的时候，结果会有4个词出来：
![](/Elasticsearch中text与keyword的区别/4.png)


使用name.keyword进行分词的时候，结果只有一个词出来：
![](/Elasticsearch中text与keyword的区别/5.png)

# 结论
text类型：会分词，先把对象进行分词处理，然后再再存入到es中。
当使用多个单词进行查询的时候，当然查不到已经分词过的内容！

keyword：不分词，没有把es中的对象进行分词处理，而是存入了整个对象！
这时候当然可以进行完整地查询！默认是256个字符！

作者：香山上的麻雀
链接：https://www.jianshu.com/p/1189ff372c38
来源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。