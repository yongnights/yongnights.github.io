---
title: xml与Python字典格式相互转换的两种方式
date: 2019-06-26 12:52:39
tags: 
- Python
categories: 
- Python
---
# 第一种方式

## 1. dict转xml
```python
def dict_to_xml(dict_data):
    xml = ["<xml>"]
    for k, v in dict_data.items():
        xml.append("<{0}>{1}</{0}>".format(k, v))
    xml.append("</xml>")
    return "".join(xml)

dict_data = {
    "ToUserName" : "gh_866835093fea",
    "FromUserName" : "ogdotwSc_MmEEsJs9-ABZ1QL_4r4",
    "CreateTime" : "1478317060",
    "MsgType" : "text",
    "Content" : "你好",
    "MsgId" : "6349323426230210995",
}

print(dict_to_xml(dict_data))
"""
<xml><ToUserName>gh_866835093fea</ToUserName><FromUserName>ogdotwSc_MmEEsJs9-ABZ1QL_4r4</FromUserName><CreateTime>1478317060</CreateTime><MsgType>text</MsgType><Content>你好</Content><MsgId>6349323426230210995</MsgId></xml>
"""

"""
<?xml version="1.0" encoding="utf-8"?>
<xml>
  <ToUserName>gh_866835093fea</ToUserName>
  <FromUserName>ogdotwSc_MmEEsJs9-ABZ1QL_4r4</FromUserName>
  <CreateTime>1478317060</CreateTime>
  <MsgType>text</MsgType>
  <Content>你好</Content>
  <MsgId>6349323426230210995</MsgId>
</xml>
"""
```

<escape><!-- more --></escape>

## 2. xml转dict
```python
def xml_to_dict(xml_data):
    xml_dict = {}
    root = ET.fromstring(xml_data)
    for child in root:
        xml_dict[child.tag] = child.text
    return xml_dict

xml_data = """
<xml>
  <ToUserName>gh_866835093fea</ToUserName>
  <FromUserName>ogdotwSc_MmEEsJs9-ABZ1QL_4r4</FromUserName>
  <CreateTime>1478317060</CreateTime>
  <MsgType>text</MsgType>
  <Content>你好</Content>
  <MsgId>6349323426230210995</MsgId>
</xml>
"""

print(xml_to_dict(xml_data))
"""
{'ToUserName': 'gh_866835093fea', 'FromUserName': 'ogdotwSc_MmEEsJs9-ABZ1QL_4r4', 'CreateTime': '1478317060', 'MsgType': 'text', 'Content': '你好', 'MsgId': '6349323426230210995'}
"""
```

# 第二种方式

xmltodict 是一个用来处理xml数据的很方便的模块。包含两个常用方法parse和unparse
> pip install xmltodict

## 1. parse()方法-xml转dict
xmltodict.parse()方法可以将xml数据转为python中的dict字典数据：
```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-

import xmltodict

xml_str = """
<xml>
<ToUserName><![CDATA[gh_866835093fea]]></ToUserName>
<FromUserName><![CDATA[ogdotwSc_MmEEsJs9-ABZ1QL_4r4]]></FromUserName>
<CreateTime>1478317060</CreateTime>
<MsgType><![CDATA[text]]></MsgType>
<Content><![CDATA[你好]]></Content>
<MsgId>6349323426230210995</MsgId>
</xml>
 """

xml_dict = xmltodict.parse(xml_str)

# print(xml_dict)
# OrderedDict([('xml', OrderedDict([('ToUserName', 'gh_866835093fea'), ('FromUserName', 'ogdotwSc_MmEEsJs9-ABZ1QL_4r4'), ('CreateTime', '1478317060'), ('MsgType', 'text'), ('Content', '你好'), ('MsgId', '6349323426230210995')]))])

# print(xml_dict['xml'])
# OrderedDict([('ToUserName', 'gh_866835093fea'), ('FromUserName', 'ogdotwSc_MmEEsJs9-ABZ1QL_4r4'), ('CreateTime', '1478317060'), ('MsgType', 'text'), ('Content', '你好'), ('MsgId', '6349323426230210995')])

for key, val in xml_dict['xml'].items():
    print(key, "=", val)

"""
ToUserName = gh_866835093fea
FromUserName = ogdotwSc_MmEEsJs9-ABZ1QL_4r4
CreateTime = 1478317060
MsgType = text
Content = 你好
MsgId = 6349323426230210995
"""
```

## 2. unparse()方法-dict转xml
xmltodict.unparse()方法可以将字典转换为xml字符串：
```python
import xmltodict

xml_dict = {
    "xml": {
        "ToUserName" : "gh_866835093fea",
        "FromUserName" : "ogdotwSc_MmEEsJs9-ABZ1QL_4r4",
        "CreateTime" : "1478317060",
        "MsgType" : "text",
        "Content" : u"你好",
        "MsgId" : "6349323426230210995",
    }
}

# xml_str = xmltodict.unparse(xml_dict)
# print(xml_str)
"""
<?xml version="1.0" encoding="utf-8"?>
<xml><ToUserName>gh_866835093fea</ToUserName><FromUserName>ogdotwSc_MmEEsJs9-ABZ1QL_4r4</FromUserName><CreateTime>1478317060</CreateTime><MsgType>text</MsgType><Content>你好</Content><MsgId>6349323426230210995</MsgId></xml>
"""


xml_str = xmltodict.unparse(xml_dict, pretty=True) # pretty表示友好输出
print(xml_str)
"""
<?xml version="1.0" encoding="utf-8"?>
<xml>
	<ToUserName>gh_866835093fea</ToUserName>
	<FromUserName>ogdotwSc_MmEEsJs9-ABZ1QL_4r4</FromUserName>
	<CreateTime>1478317060</CreateTime>
	<MsgType>text</MsgType>
	<Content>你好</Content>
	<MsgId>6349323426230210995</MsgId>
</xml>
"""
```

