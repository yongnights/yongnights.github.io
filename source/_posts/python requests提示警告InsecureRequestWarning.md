---
title: python requests提示警告InsecureRequestWarning
date: 2019-03-15 11:23:31
tags: 
- Python
- request
categories: 
- Python
---
#### 报错信息
    在Python3中使用以下代码报错：
    import requests
    response = requests.get(url='', verify=False)
    错误代码如下：
    InsecureRequestWarning: Unverified HTTPS request is being made. Adding certificate verification is strongly advised. 

<escape><!-- more --></escape>

#### 解决方法
    在语句前加上以下代码即可不会被报错：
    import requests
    requests.packages.urllib3.disable_warnings()
    response = requests.get(url, verify=False)
    其中： 
    response = requests.get(url, verify=False)
    参数： verify：Ture/False，默认是Ture，用于验证SSL证书开关