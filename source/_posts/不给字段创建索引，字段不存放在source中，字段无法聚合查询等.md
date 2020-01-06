---
title: 不给字段创建索引，字段不存放在source中，字段无法聚合查询等
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
1. 某个字段不被搜索，也就是说不想为这个字段建立inverted index(反向索引)，可以这么做：
```
PUT twitter
{
  "mappings": {
      "uid": {
        "type": "long"
      },
      "user": {
        "type": "object",
        "enabled": false
      }
    }
  }
}
```
通过mapping对user字段进行了修改：
```
"user": {
    "type": "object",
    "enabled": false
  }
```

<escape><!-- more --></escape>

不想我们的整个文档被搜索:
```

PUT twitter 
{
  "mappings": {
    "enabled": false 
  }
}
```

2. 不想存储任何的字段,也就是说不在`source`中存储数据,它有完好的inverted index供查询，虽然它没有字的source。
```
PUT twitter
{
  "mappings": {
    "_source": {
      "enabled": false
    }
  }
}
```

想节省自己的存储空间，只存储那些需要的字段到source里去
使用include来包含我们想要的字段，同时我们通过exclude来去除那些不需要的字段
```
PUT twitter
{
  "mappings": {
    "_source": {
      "includes": [
        "*.lat",
        "address",
        "name.*"
      ],
      "excludes": [
        "name.surname"
      ]
    }    
  }
}
```

3. 默认情况下，所有支持doc值的字段均已启用它们。如果您确定不需要对字段进行排序或汇总，也不需要通过脚本访问字段值，则可以禁用doc值以节省磁盘空间：
```
PUT twitter
{
  "mappings": {
    "properties": {
      "city": {
        "type": "keyword",
        "doc_values": false,
        "ignore_above": 256
      },
      "address": {
        "type": "text",
        "fields": {
          "keyword": {
            "type": "keyword",
            "ignore_above": 256
          }
        }
      },
      "age": {
        "type": "long"
      }
    }
  }
}
```
把city字段的doc_values设置为false