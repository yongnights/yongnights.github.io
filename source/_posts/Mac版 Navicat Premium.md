---
title: Mac版 Navicat Premium
date: 2019-07-22 18:25:56
tags:
 - Mac
 - Navicat Premium
categories: 
 - Mac
 - Navicat Premium
---

Mac版 Navicat Premium 下载地址(请使用分享链接下载)：
[英文版](https://pan.baidu.com/s/1nrphXH6vr7a9TTKBHbonhA)

[在线生成非对称加密公钥私钥对](http://web.chacuo.net/netrsakeypair) -- 密钥是2048位的，PKCS#8格式


# 1.下载软件
Mac版 Navicat Premium 下载地址(请使用分享链接下载，其他方式下载的软件不知道能不能用)：
[英文版](https://pan.baidu.com/s/1nrphXH6vr7a9TTKBHbonhA)

# 2.生成密钥
打开如下链接的网站，[在线生成非对称加密公钥私钥对](http://web.chacuo.net/netrsakeypair)
生成密钥位数：2048位的，密钥格式：PKCS#8，证书密码为空，然后点击生成密钥对。
把生成的非对称加密公钥和非对称加密私钥保存起来。

<escape><!-- more --></escape>

# 3.安装软件，修改公钥文件内容

安装软件，然后在finder中找到应用程序，右键Navicat Premium.app ,打开目录 /Contents/Resources，先复制保存一份，然后再编辑rpk文件，用**自己生成的或者本人提供的公钥替换并保存(重点)**。

# 4.激活，生成激活码

接下来断网，然后打开navicat, 根据navicat输入以下序列号：英文版64位密钥序列号： NAVG-UJ8Z-EVAP-JAUW
如果右边出现 ✔️，继续。如果右边是黑色的❌,重来。
由于断了网，则会出现手动激活的按钮（左边第一个），点击手动激活会出现请求码。

登录[在线生成非对称加密公钥私钥对](http://tool.chacuo.net/cryptrsaprikey)， 填充方式为PKCS1_PADDING，私钥密码为空，字符集为gb2312编码。

1.  在第一个输入框 **输入加密私钥（以“-----BEGIN PRIVATE KEY-----”开头 “-----END PRIVATE KEY-----” 结尾）**中 填上第一步生成的非对称加密私钥
2.  在第三个输入框 **RSA私钥加密、解密转换结果(base64了)** 填上请求码（navicat中出现的）
3.  点击**RSA私钥解密**
4.  此时会在第二个输入框**待加密、解密的文本**会生成请求码明文。

大致是如下格式：

```text
{
  "K" : "NAVGUJ8ZEVAPJAUW",
  "P" : "Mac 10.14",
  "DI" : "NDljYjY4ZWMzZTQ4MjRm"
}
```

接下来需要给这个请求码明文增加内容：

-   获取当前时间戳 [时间戳转换](https://unixtime.51240.com/)，用T表示
-   输入所在公司和组织，用N和O表示

最终样式如下：

```text
{
  "K" : "NAVGUJ8ZEVAPJAUW",
  "P" : "Mac 10.14",
  "DI" : "NDljYjY4ZWMzZTQ4MjRm",
  "N":"52pojie", 
  "O":"52pojie.cn", 
  "T":1563413356
}
```

然后在第二个输入框**待加密、解密的文本**中输入该请求码明文，点击**RSA私钥加密**，最后会在第三个输入框 **RSA私钥加密、解密转换结果(base64了)** 上显示出激活码，复制该激活码，粘贴到navicat中，激活即可。





