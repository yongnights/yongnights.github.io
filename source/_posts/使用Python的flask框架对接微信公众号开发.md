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

# 公众号接收与发送消息

## 1. 接收普通消息

**当普通微信用户向公众账号发消息时，微信服务器将POST消息的XML数据包到开发者填写的URL上。**

微信服务器在五秒内收不到响应会断掉连接，并且重新发起请求，总共重试三次。假如服务器无法保证在五秒内处理并回复，可以直接回复空串，微信服务器不会对此作任何处理，并且不会发起重试。

各消息类型的推送使用XML数据包结构，如：

```xml
<xml>
<ToUserName><![CDATA[gh_866835093fea]]></ToUserName>
<FromUserName><![CDATA[ogdotwSc_MmEEsJs9-ABZ1QL_4r4]]></FromUserName>
<CreateTime>1478317060</CreateTime>
<MsgType><![CDATA[text]]></MsgType>
<Content><![CDATA[你好]]></Content>
<MsgId>6349323426230210995</MsgId>
</xml>
```

**注意：<![CDATA 与 ]]> 括起来的数据不会被xml解析器解析。**

## 普通消息类别

1. 文本消息
2. 图片消息
3. 语音消息
4. 视频消息
5. 小视频消息
6. 地理位置消息
7. 链接消息

## 文本消息
微信post过来的文本xml数据格式如下：

```xml
<xml>
  <ToUserName><![CDATA[toUser]]></ToUserName>
  <FromUserName><![CDATA[fromUser]]></FromUserName>
  <CreateTime>1348831860</CreateTime>
  <MsgType><![CDATA[text]]></MsgType>
  <Content><![CDATA[this is a test]]></Content>
  <MsgId>1234567890123456</MsgId>
</xml>
```

| 参数         | 描述                     |
| ------------ | ------------------------ |
| ToUserName   | 开发者微信号             |
| FromUserName | 发送方帐号（一个OpenID） |
| CreateTime   | 消息创建时间 （整型）    |
| MsgType      | 消息类型，文本为text     |
| Content      | 文本消息内容             |
| MsgId        | 消息id，64位整型         |

## 2. 被动回复消息

当用户发送消息给公众号时（或某些特定的用户操作引发的事件推送时），会产生一个POST请求，开发者可以在响应包中返回特定XML结构，来对该消息进行响应（现支持回复文本、图片、图文、语音、视频、音乐）。严格来说，发送被动响应消息其实并不是一种接口，而是对微信服务器发过来消息的一次回复。

假如服务器无法保证在五秒内处理并回复，必须做出下述回复，这样微信服务器才不会对此作任何处理，并且不会发起重试（这种情况下，可以使用客服消息接口进行异步回复），否则，将出现严重的错误提示。详见下面说明：

1. （推荐方式）直接回复success
2. 直接回复空串（指字节长度为0的空字符串，而不是XML结构体中content字段的内容为空）

**一旦遇到以下情况，微信都会在公众号会话中，向用户下发系统提示“该公众号暂时无法提供服务，请稍后再试”：**

1. 开发者在5秒内未回复任何内容
2. 开发者回复了异常数据，比如JSON数据等

###  回复的消息类型

1. 文本消息
2. 图片消息
3. 语音消息
4. 视频消息
5. 音乐消息
6. 图文消息

###  回复文本消息

```XML
<xml>
<ToUserName><![CDATA[toUser]]></ToUserName>
<FromUserName><![CDATA[fromUser]]></FromUserName>
<CreateTime>12345678</CreateTime>
<MsgType><![CDATA[text]]></MsgType>
<Content><![CDATA[你好]]></Content>
</xml>
```

| 参数         | 是否必须 | 描述                                                         |
| ------------ | -------- | ------------------------------------------------------------ |
| ToUserName   | 是       | 接收方帐号（收到的OpenID）                                   |
| FromUserName | 是       | 开发者微信号                                                 |
| CreateTime   | 是       | 消息创建时间 （整型）                                        |
| MsgType      | 是       | 消息类型，文本为text                                         |
| Content      | 是       | 回复的消息内容（换行：在content中能够换行，微信客户端就支持换行显示） |

## 3. 代码实现

还在原来的路径下，若是get请求，则是进行服务器验证，参考上一步的处理。若是post请求，则进一步处理。

实现的业务逻辑类似与“鹦鹉学舌”，用户发什么内容，我们就传回什么内容。

详看代码：

```python
# 根据请求方式进行判断
if request.method == 'POST':
	获取微信服务器post过来的xml数据
    xml = request.data
    # 把xml格式的数据进行处理，转换成字典进行取值
    req = xmltodict.parse(xml)['xml']
    # 判断post过来的数据中数据类型是不是文本
    if 'text' == req.get('MsgType'):
    	# 获取用户的信息，开始构造返回数据，把用户发送的信息原封不动的返回过去，字典格式
        resp = {
            'ToUserName':req.get('FromUserName'),
            'FromUserName':req.get('ToUserName'),
            'CreateTime':int(time.time()),
            'MsgType':'text',
            'Content':req.get('Content')
        }
        # 把构造的字典转换成xml格式
        xml = xmltodict.unparse({'xml':resp})
        # print(req.get('Content'))
        # 返回数据
        return xml
    else:
        resp = {
            'ToUserName': req.get('FromUserName', ''),
            'FromUserName': req.get('ToUserName', ''),
            'CreateTime': int(time.time()),
            'MsgType': 'text',
            'Content': 'I LOVE ITCAST'
        }
        xml = xmltodict.unparse({'xml':resp})
        return xml
```
注意：
- QQ表情实际上是字符串转义，仍属于文本消息
- emoji表情本质是Unicode字符，也属于文本消息
- 自定义表情：既不是文本，也不是图片，而是一种不支持的格式，微信未提供处理该消息的接口

完整代码

```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-


from flask import Flask, request, make_response
import hashlib
import xmltodict
import time

app = Flask(__name__)


@app.route('/',methods=['GET','POST'])
def index():
    if request.method =='GET':
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

    # 根据请求方式进行判断
    if request.method == 'POST':
        获取微信服务器post过来的xml数据
        xml = request.data
        # 把xml格式的数据进行处理，转换成字典进行取值
        req = xmltodict.parse(xml)['xml']
        # 判断post过来的数据中数据类型是不是文本
        if 'text' == req.get('MsgType'):
            # 获取用户的信息，开始构造返回数据，把用户发送的信息原封不动的返回过去，字典格式
            resp = {
                'ToUserName':req.get('FromUserName'),
                'FromUserName':req.get('ToUserName'),
                'CreateTime':int(time.time()),
                'MsgType':'text',
                'Content':req.get('Content')
            }
            # 把构造的字典转换成xml格式
            xml = xmltodict.unparse({'xml':resp})
            # print(req.get('Content'))
            # 返回数据
            return xml
        else:
            resp = {
                'ToUserName': req.get('FromUserName', ''),
                'FromUserName': req.get('ToUserName', ''),
                'CreateTime': int(time.time()),
                'MsgType': 'text',
                'Content': 'I LOVE ITCAST'
            }
            xml = xmltodict.unparse({'xml':resp})
            return xml

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=True)

```

## 4. 接收其他普通消息

### 接收图片消息

```xml
<xml>
<ToUserName><![CDATA[toUser]]></ToUserName>
<FromUserName><![CDATA[fromUser]]></FromUserName>
<CreateTime>1348831860</CreateTime>
<MsgType><![CDATA[image]]></MsgType>
<PicUrl><![CDATA[this is a url]]></PicUrl>
<MediaId><![CDATA[media_id]]></MediaId>
<MsgId>1234567890123456</MsgId>
</xml>
```

| 参数         | 描述                                                 |
| ------------ | ---------------------------------------------------- |
| ToUserName   | 开发者微信号                                         |
| FromUserName | 发送方帐号（一个OpenID）                             |
| CreateTime   | 消息创建时间 （整型）                                |
| MsgType      | image                                                |
| PicUrl       | 图片链接                                             |
| MediaId      | 图片消息媒体id，可以调用多媒体文件下载接口拉取数据。 |
| MsgId        | 消息id，64位整型                                     |

### 接收视频消息

```xml
<xml>
<ToUserName><![CDATA[toUser]]></ToUserName>
<FromUserName><![CDATA[fromUser]]></FromUserName>
<CreateTime>1357290913</CreateTime>
<MsgType><![CDATA[video]]></MsgType>
<MediaId><![CDATA[media_id]]></MediaId>
<ThumbMediaId><![CDATA[thumb_media_id]]></ThumbMediaId>
<MsgId>1234567890123456</MsgId>
</xml>
```

| 参数         | 描述                                                         |
| ------------ | ------------------------------------------------------------ |
| ToUserName   | 开发者微信号                                                 |
| FromUserName | 发送方帐号（一个OpenID）                                     |
| CreateTime   | 消息创建时间 （整型）                                        |
| MsgType      | 视频为video                                                  |
| MediaId      | 视频消息媒体id，可以调用多媒体文件下载接口拉取数据。         |
| ThumbMediaId | 视频消息缩略图的媒体id，可以调用多媒体文件下载接口拉取数据。 |
| MsgId        | 消息id，64位整型                                             |

### 接收小视频消息

```xml
<xml>
<ToUserName><![CDATA[toUser]]></ToUserName>
<FromUserName><![CDATA[fromUser]]></FromUserName>
<CreateTime>1357290913</CreateTime>
<MsgType><![CDATA[shortvideo]]></MsgType>
<MediaId><![CDATA[media_id]]></MediaId>
<ThumbMediaId><![CDATA[thumb_media_id]]></ThumbMediaId>
<MsgId>1234567890123456</MsgId>
</xml>
```

| 参数         | 描述                                                         |
| ------------ | ------------------------------------------------------------ |
| ToUserName   | 开发者微信号                                                 |
| FromUserName | 发送方帐号（一个OpenID）                                     |
| CreateTime   | 消息创建时间 （整型）                                        |
| MsgType      | 小视频为shortvideo                                           |
| MediaId      | 视频消息媒体id，可以调用多媒体文件下载接口拉取数据。         |
| ThumbMediaId | 视频消息缩略图的媒体id，可以调用多媒体文件下载接口拉取数据。 |
| MsgId        | 消息id，64位整型                                             |

### 接收语音消息

```xml
<xml>
<ToUserName><![CDATA[toUser]]></ToUserName>
<FromUserName><![CDATA[fromUser]]></FromUserName>
<CreateTime>1357290913</CreateTime>
<MsgType><![CDATA[voice]]></MsgType>
<MediaId><![CDATA[media_id]]></MediaId>
<Format><![CDATA[Format]]></Format>
<MsgId>1234567890123456</MsgId>
</xml>
```

| 参数         | 描述                                                 |
| ------------ | ---------------------------------------------------- |
| ToUserName   | 开发者微信号                                         |
| FromUserName | 发送方帐号（一个OpenID）                             |
| CreateTime   | 消息创建时间 （整型）                                |
| MsgType      | 语音为voice                                          |
| MediaId      | 语音消息媒体id，可以调用多媒体文件下载接口拉取数据。 |
| Format       | 语音格式，如amr，speex等                             |
| MsgID        | 消息id，64位整型                                     |

**请注意，开通语音识别后，用户每次发送语音给公众号时，微信会在推送的语音消息XML数据包中，增加一个Recongnition字段（注：由于客户端缓存，开发者开启或者关闭语音识别功能，对新关注者立刻生效，对已关注用户需要24小时生效。开发者可以重新关注此帐号进行测试）。开启语音识别后的语音XML数据包如下：**

```xml
<xml>
<ToUserName><![CDATA[toUser]]></ToUserName>
<FromUserName><![CDATA[fromUser]]></FromUserName>
<CreateTime>1357290913</CreateTime>
<MsgType><![CDATA[voice]]></MsgType>
<MediaId><![CDATA[media_id]]></MediaId>
<Format><![CDATA[Format]]></Format>
<Recognition><![CDATA[腾讯微信团队]]></Recognition>
<MsgId>1234567890123456</MsgId>
</xml>
```

**多出的字段中，Format为语音格式，一般为amr，Recognition为语音识别结果，使用UTF8编码。**

## 5.回复其他普通消息

### 回复图片消息

```xml
<xml>
<ToUserName><![CDATA[toUser]]></ToUserName>
<FromUserName><![CDATA[fromUser]]></FromUserName>
<CreateTime>12345678</CreateTime>
<MsgType><![CDATA[image]]></MsgType>
<Image>
<MediaId><![CDATA[media_id]]></MediaId>
</Image>
</xml>
```

| 参数         | 是否必须 | 说明                                       |
| ------------ | -------- | ------------------------------------------ |
| ToUserName   | 是       | 接收方帐号（收到的OpenID）                 |
| FromUserName | 是       | 开发者微信号                               |
| CreateTime   | 是       | 消息创建时间 （整型）                      |
| MsgType      | 是       | image                                      |
| MediaId      | 是       | 通过素材管理接口上传多媒体文件，得到的id。 |

### 回复语音消息

```xml
<xml>
<ToUserName><![CDATA[toUser]]></ToUserName>
<FromUserName><![CDATA[fromUser]]></FromUserName>
<CreateTime>12345678</CreateTime>
<MsgType><![CDATA[voice]]></MsgType>
<Voice>
<MediaId><![CDATA[media_id]]></MediaId>
</Voice>
</xml>
```

| 参数         | 是否必须 | 说明                                     |
| ------------ | -------- | ---------------------------------------- |
| ToUserName   | 是       | 接收方帐号（收到的OpenID）               |
| FromUserName | 是       | 开发者微信号                             |
| CreateTime   | 是       | 消息创建时间戳 （整型）                  |
| MsgType      | 是       | 语音，voice                              |
| MediaId      | 是       | 通过素材管理接口上传多媒体文件，得到的id |

### 回复视频消息

```xml
<xml>
<ToUserName><![CDATA[toUser]]></ToUserName>
<FromUserName><![CDATA[fromUser]]></FromUserName>
<CreateTime>12345678</CreateTime>
<MsgType><![CDATA[video]]></MsgType>
<Video>
<MediaId><![CDATA[media_id]]></MediaId>
<Title><![CDATA[title]]></Title>
<Description><![CDATA[description]]></Description>
</Video> 
</xml>
```

| 参数         | 是否必须 | 说明                                     |
| ------------ | -------- | ---------------------------------------- |
| ToUserName   | 是       | 接收方帐号（收到的OpenID）               |
| FromUserName | 是       | 开发者微信号                             |
| CreateTime   | 是       | 消息创建时间 （整型）                    |
| MsgType      | 是       | video                                    |
| MediaId      | 是       | 通过素材管理接口上传多媒体文件，得到的id |
| Title        | 否       | 视频消息的标题                           |
| Description  | 否       | 视频消息的描述                           |

可以使用微信提供的网页调试工具进行测试：<https://mp.weixin.qq.com/debug/cgi-bin/apiinfo?t=index>


# 关注/取消关注事件

用户在关注与取消关注公众号时，微信会把这个事件推送到开发者填写的URL。

微信服务器在五秒内收不到响应会断掉连接，并且重新发起请求，总共重试三次。

假如服务器无法保证在五秒内处理并回复，可以直接回复空串，微信服务器不会对此作任何处理，并且不会发起重试。

```xml
<xml>
<ToUserName><![CDATA[toUser]]></ToUserName>
<FromUserName><![CDATA[FromUser]]></FromUserName>
<CreateTime>123456789</CreateTime>
<MsgType><![CDATA[event]]></MsgType>
<Event><![CDATA[subscribe]]></Event>
</xml>
```

| 参数         | 描述                                             |
| ------------ | ------------------------------------------------ |
| ToUserName   | 开发者微信号                                     |
| FromUserName | 发送方帐号（一个OpenID）                         |
| CreateTime   | 消息创建时间 （整型）                            |
| MsgType      | 消息类型，event                                  |
| Event        | 事件类型，subscribe(订阅)、unsubscribe(取消订阅) |

代码实现

```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-

from flask import Flask, request, make_response
import hashlib
import xmltodict
import time
import requests
import json

app = Flask(__name__)

@app.route('/',methods=['GET','POST'])
def index():
    if request.method =='GET':
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

    if request.method == 'POST':
        xml = request.data
        req = xmltodict.parse(xml)['xml']

        # print(req)

        MsgType = req.get('MsgType')
        if 'text' == MsgType:
            resp = {
                'ToUserName':req.get('FromUserName'),
                'FromUserName':req.get('ToUserName'),
                'CreateTime':int(time.time()),
                'MsgType':'text',
                'Content':'这是一个文本消息！'
            }
        elif 'event' == MsgType:
            if "subscribe" == req.get("Event"):
                resp = {
                     "ToUserName":req.get("FromUserName", ""),
                    "FromUserName":req.get("ToUserName", ""),
                    "CreateTime":int(time.time()),
                    "MsgType":"text",
                    "Content":u"感谢您的关注！"
                }
            else:
                resp = None
        else:
            resp = {
                'ToUserName': req.get('FromUserName', ''),
                'FromUserName': req.get('ToUserName', ''),
                'CreateTime': int(time.time()),
                'MsgType': 'text',
                'Content': '无法识别该消息!'
            }

        xml = xmltodict.unparse({'xml': resp})
        return xml

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80, debug=True)
```

# 微信网页授权

现在，我们要实现一个微信内网页，通过微信访问网页时，网页会展示微信用户的个人信息。因为涉及到用户的个人信息，所以需要有用户授权才可以。当用户授权后，我们的网页服务器（开发者服务器）会拿到用户的“授权书”（code）,我们用这个code向微信服务器领取访问令牌（accecc_token）和用户的身份号码（openid)，然后凭借access_token和openid向微信服务器提取用户的个人信息。

1. 第一步：用户同意授权，获取code
2. 第二步：通过code换取网页授权access_token
3. 第三步：拉取用户信息(需scope为 snsapi_userinfo)

那么，如何拿到用户的授权code呢？

授权是由微信发起让用户进行确认，在这个过程中是微信在与用户进行交互，所以用户应该先访问微信的内容，用户确认后再由微信将用户导向到我们的网页链接地址，并携带上code参数。我们把这个过程叫做网页回调，类似于我们在程序编写时用到的回调函数，都是回调的思想。

## 1. 设置网页授权回调域名

在微信公众号请求用户网页授权之前，开发者需要先到公众平台官网中的开发者中心页配置授权回调域名。请注意，这里填写的是域名（是一个字符串），而不是URL，因此请勿加 http:// 等协议头；

授权回调域名配置规范为全域名，比如需要网页授权的域名为：www.qq.com，配置以后此域名下面的页面<http://www.qq.com/music.html> 、 <http://www.qq.com/login.html> 都可以进行OAuth2.0鉴权。但<http://pay.qq.com> 、 <http://music.qq.com> 、 <http://qq.com无法进行OAuth2.0鉴权。>

![](/wechat/01.png)

## 2. 用户同意授权，获取code

让用户访问一下链接地址：

> <https://open.weixin.qq.com/connect/oauth2/authorize?appid=APPID&redirect_uri=REDIRECT_URI&response_type=code&scope=SCOPE&state=STATE#wechat_redirect>

![参数说明](/wechat/02.png)

下图为scope等于snsapi_userinfo时的授权页面：

![授权页面](/wechat/03.png)

**用户同意授权后**

如果用户同意授权，页面将跳转至 redirect_uri/?code=CODE&state=STATE。若用户禁止授权，则重定向后不会带上code参数，仅会带上state参数redirect_uri?state=STATE

## 3. 通过code换取网页授权access_token

**请求方法**

> <https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code>

**参数说明**

![参数说明](/wechat/04.png)

**返回值**

正确时返回的JSON数据包如下：

```JSON
{
   "access_token":"ACCESS_TOKEN",
   "expires_in":7200,
   "refresh_token":"REFRESH_TOKEN",
   "openid":"OPENID",
   "scope":"SCOPE"
}
```

![返回值](/wechat/05.png)

错误时微信会返回JSON数据包如下（示例为Code无效错误）:

```JSON
{
    "errcode":40029,
    "errmsg":"invalid code"
}
```

## 4. 拉取用户信息(需scope为 snsapi_userinfo)

**请求方法**

> <https://api.weixin.qq.com/sns/userinfo?access_token=ACCESS_TOKEN&openid=OPENID&lang=zh_CN>

**参数说明**

![参数说明](/wechat/06.png)

**返回值**

正确时返回的JSON数据包如下：

```JSON
{
   "openid":" OPENID",
   " nickname": NICKNAME,
   "sex":"1",
   "province":"PROVINCE"
   "city":"CITY",
   "country":"COUNTRY",
    "headimgurl":    "http://wx.qlogo.cn/mmopen/g3MonUZtNHkdmzicIlibx6iaFqAc56vxLSUfpb6n5WKSYVY0ChQKkiaJSgQ1dZuTOgvLLrhJbERQQ4eMsv84eavHiaiceqxibJxCfHe/46",
    "privilege":[
    "PRIVILEGE1"
    "PRIVILEGE2"
    ],
    "unionid": "o6_bmasdasdsad6_2sgVt7hMZOPfL"
}
```

![返回值](/wechat/07.png)

错误时微信会返回JSON数据包如下:

```JSON
{
    "errcode":40003,
    "errmsg":" invalid openid "
}
```



