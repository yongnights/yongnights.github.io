---
title: 使用Python的flask框架对接微信公众号开发
date: 2019-06-26 18:54:22
tags: 
- Python
- flask
- 微信公众号 
categories: 
- Python
- flask
- 微信公众号 
---
# 使用说明
1. 找一台具有公网IP的服务器
2. 安装python3，搭建nginx+uwsgi+flask环境
3. pycharm上配置Deployment，本地代码直接上传到服务器
4. nginx配置文件中设置域名，配置好域名解析


我这边的实际配置：
域名：wechat_pro.lehuoha.com
路径：/home/wechat_pro/app.py

app.py文件代码(注意文件权限)：
```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-

from flask import Flask

app = Flask(__name__)

@app.route('/')
def index():
    return 'hello world！'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80, debug=True)
```

最终效果是访问<http://wechat_pro.lehuoha.com>这个域名，能够出现app.py文件中的“hello world！”

<escape><!-- more --></escape>

第三步操作步骤：
1. 在pycharm中新建一个项目，比如项目名是：wechat_pro。本地也搭建好环境，安装好依赖，方便使用frpc在本地调试使用
2. 在wechat_pro目录下新建app.py文件和uwsgi文件夹，uwsgi文件夹存放相关的uwsgi文件，具体参考<<nginx+uwsgi+flask环境>>
3. 在pycharm中，Tools->Deployment->Configuration，根据远程链接服务器的方式不同，选择相应的链接方式，比如FTP，Sftp等，我这边采用Sftp，输入连接名，比如：开发测试服务器，在右侧输入公网IP服务器的ip地址，账号，验证方式选择密码，点击“测试链接”。
4. 然后设置本地目录跟服务器目录路径的映射，确保本地代码上传到服务器里的指定目录。

# 微信公众号开发对接

登录微信公众平台官网后，在公众平台后台管理页面 - 开发者中心页，点击“修改配置”按钮，填写服务器地址（URL）、Token和EncodingAESKey，其中URL是开发者用来接收微信消息和事件的接口URL。Token可由开发者可以任意填写，用作生成签名（该Token会和接口URL中包含的Token进行比对，从而验证安全性）。EncodingAESKey由开发者手动填写或随机生成，将用作消息体加解密密钥。

同时，开发者可选择消息加解密方式：明文模式、兼容模式和安全模式。模式的选择与服务器配置在提交后都会立即生效，请开发者谨慎填写及选择。加解密方式的默认状态为明文模式，选择兼容模式和安全模式需要提前配置好相关加解密代码，详情请参考消息体签名及加解密部分的文档。

微信公众号接口只支持80接口。

由于没有微信公众号，所以使用测试平台。
测试平台登陆地址：< http://mp.weixin.qq.com/debug/cgi-bin/sandbox?t=sandbox/login>

微信开发者文档网址：<https://mp.weixin.qq.com/wiki/home/index.html>

通过查看开发者文档，可以知道：开发者提交信息后，微信服务器将发送GET请求到填写的服务器地址URL上，GET请求携带四个参数：

| 参数      | 描述                                                         |
| --------- | ------------------------------------------------------------ |
| signature | 微信加密签名，signature结合了开发者填写的token参数和请求中的timestamp参数、nonce参数。 |
| timestamp | 时间戳                                                       |
| nonce     | 随机数                                                       |
| echostr   | 随机字符串                                                   |


开发者通过检验signature对请求进行校验。若确认此次GET请求来自微信服务器，请原样返回echostr参数内容，则接入生效，成为开发者成功，否则接入失败。

通俗点来说，就是开发者在接口配置信息填写完URL和自定义的一个Token值之后，腾讯就会发送GET请求到这个服务器的URL地址上，这个GET请求包含如上的四个参数。开发者接收到这四个参数之后，根据一定的规则生成一个signature，跟腾讯发过来的signature进行对比，一致的话则接入生效。

这个一定的规则如下：

1. 将token、timestamp、nonce三个参数进行字典序排序
2. 将三个参数字符串拼接成一个字符串进行sha1加密
3. 开发者获得加密后的字符串可与signature对比，标识该请求来源于微信

Python代码实现（以Flask框架为例）：

```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-

from flask import Flask, request, make_response
import hashlib

app = Flask(__name__)

@app.route('/')
def index():
    # 设置token,开发者配置中心使用
    token = 'wechat_pro'

    # 获取微信服务器发送过来的参数
    data = request.args
    signature = data.get('signature')
    timestamp = data.get('timestamp')
    nonce = data.get('nonce')
    echostr = data.get('echostr')

    # 对参数进行字典排序，拼接字符串
    temp = [timestamp, nonce, token]
    temp.sort()
    temp = ''.join(temp)

    # 加密
    if (hashlib.sha1(temp.encode('utf8')).hexdigest() == signature):
        return echostr
    else:
        return 'error', 403

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=True)
```

注意：比较常见的错误是：TypeError: Unicode-objects must be encoded before hashing，则是因为需要指定加密字符串的编码，文中的`temp.encode('utf8')`就是解决这个错误的。

当接入生效后，测试平台网页上会显示“配置成功”

问题：
python 代码在后台运行，假设在代码中想查看获取到的某个变量的值，使用`print()`函数输出，但是如何查看这个输出呢？

我这边的解决办法是本地调试，然后上传代码到服务器。
具体来说如下：
1、本地也搭建好环境，目录结构跟服务器上面的一样，但是本地代码中运行的端口是80，服务器代码中是8000
2、使用frpc的方式，给本地环境也配置一个外网访问域名。
3、测试公众号这边配置的话，先配置本地的这个域名，进行调试测试，没问题的话把代码中的端口修改成8000，然后上传到服务器。然后再在测试公众号上修改这个URL地址为服务器上的域名。
4、本地代码再结合Git使用，效果更佳







