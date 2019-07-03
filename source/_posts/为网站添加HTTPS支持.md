---
title: 为网站添加HTTPS支持
date: 2019-07-03 18:12:18
tags: 
- python 
- flask 
categories:
- python 
- flask 
---
注：此片帖子参考如下其他帖子，结合自身实际整理而成。

参考帖子地址：
（1）为网站添加https支持  <https://fanzheng.org/archives/21>
（2）Let's Encrypt，免费好用的 HTTPS 证书 <https://imququ.com/post/letsencrypt-certificate.html>
（3）本博客 Nginx 配置之完整篇 <https://imququ.com/post/my-nginx-conf.html>

### 创建帐号

首先创建一个目录，例如：/home/microblog/ssl/，用来存放各种临时文件和最后的证书文件。
进入这个目录，创建一个 RSA 私钥用于 Let's Encrypt 识别你的身份：

```bash
openssl genrsa 4096 > account.key
```

<escape><!-- more --></escape>

### 创建 CSR 文件

接着就可以生成 CSR（Certificate Signing Request，证书签名请求）文件了。在这之前，还需要创建域名私钥（一定不要使用上面的账户私钥），根据证书不同类型，域名私钥也可以选择 RSA 和 ECC 两种不同类型。

我这采用的是RSA类型
创建 RSA 私钥（兼容性好）：
```bash
openssl genrsa 4096 > domain.key
```

有了私钥文件，就可以生成 CSR 文件了。在 CSR 中推荐至少把域名带 www 和不带 www 的两种情况都加进去，其它子域可以根据需要添加（目前一张证书最多可以包含 100 个域名）：

示例：openssl req -new -sha256 -key domain.key -subj "/" -reqexts SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:yoursite.com,DNS:www.yoursite.com")) > domain.csr


执行这一步时，如果提示找不到 `/etc/ssl/openssl.cnf` 文件，请看看 `/usr/local/openssl/ssl/openssl.cnf` 是否存在。如果还是不行，也可以使用交互方式创建 CSR（需要注意 Common Name 必须为你的域名）：
```bash
openssl req -new -sha256 -key domain.key -out domain.csr
```

实际操作：openssl req -new -sha256 -key domain.key -subj "/" -reqexts SAN -config <(cat /usr/local/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:blog.lehuoha.com")) > domain.csr

注意我的openssl.cnf路径为：/usr/local/ssl/openssl.cnf，域名是：blog.lehuoha.com

### 配置验证服务

我们知道，CA 在签发 DV（Domain Validation）证书时，需要验证域名所有权。传统 CA 的验证方式一般是往 `admin@yoursite.com` 发验证邮件，而 Let's Encrypt 是在你的服务器上生成一个随机验证文件，再通过创建 CSR 时指定的域名访问，如果可以访问则表明你对这个域名有控制权。具体来说，他会访问网站的`/.well-known/acme-challenge/`目录来查看有没有他要求的文件。

在这里，我们只需在网站根目录下创建该文件夹即可。

首先创建用于存放验证文件的目录，例如：
```bash
mkdir -p /home/microblog/.well-known/acme-challenge
```

然后配置一个 HTTP 服务，以 Nginx 为例：

(示例)：实际情况需要修改域名，alias别名路径，以及location /{ } 信息等，若有location /{ }的配置参数的话则只需要添加 rewrite ^/(.*)$ https://yoursite.com/$1 permanent;即可
```conf
    server {
    server_name www.yoursite.com yoursite.com;

    location ^~ /.well-known/acme-challenge/ {
        alias /home/xxx/www/challenges/;
        try_files $uri =404;
    }

    location / {
        rewrite ^/(.*)$ https://yoursite.com/$1 permanent;
    }
}
```

以上配置优先查找 `~/www/challenges/` 目录下的文件，如果找不到就重定向到 HTTPS 地址。这个验证服务以后更新证书还要用到，建议一直保留。


实际配置：
```conf
server {
    listen 80;
    server_name blog.lehuoha.com;

    location ^~ /.well-known/acme-challenge/ {
        alias /home/microblog/challenges/;
        try_files $uri =404;
    }


    location / {
        proxy_pass http://127.0.0.1:4010;
        proxy_redirect off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        rewrite ^/(.*)$ https://blog.lehuoha.com/$1 permanent;
    }
}
```


### 获取网站证书

先把 acme-tiny 脚本保存到之前的 `ssl` 目录：

```bash
wget https://raw.githubusercontent.com/diafygi/acme-tiny/master/acme_tiny.py
```

指定账户私钥、CSR 以及验证目录，执行脚本：
```bash
python acme_tiny.py --account-key ./account.key --csr ./domain.csr --acme-dir /home/microblog/challenges > ./signed.crt
```
如果一切正常，当前目录下就会生成一个 `signed.crt`，这就是申请好的证书文件。

搞定网站证书后，还要下载 Let's Encrypt 的中间证书。我在之前的文章中讲过，配置 HTTPS 证书时既不要漏掉中间证书，也不要包含根证书。在 Nginx 配置中，需要把中间证书和网站证书合在一起：

```bash
wget -O - https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem > intermediate.pem
cat signed.crt intermediate.pem > chained.pem
```

为了后续能顺利启用 [OCSP Stapling](https://imququ.com/post/why-can-not-turn-on-ocsp-stapling.html#toc-2)，我们再把根证书和中间证书合在一起：

```bash
wget -O - https://letsencrypt.org/certs/isrgrootx1.pem > root.pem
cat intermediate.pem root.pem > full_chained.pem
```

最终，修改 Nginx 中有关证书的配置并 reload 服务即可：

(示例)：若之前配置过ssl则只需要更改证书就行，若未配置过，则需要添加相关配置参数
```conf
ssl_certificate     ~/www/ssl/chained.pem;
ssl_certificate_key ~/www/ssl/domain.key;
```

实际操作后的配置信息：
```conf
server {
    listen         443 ssl ;
    server_name    blog.lehuoha.com;
    server_tokens  off;
    
    ssl on;
    ssl_certificate      /home/microblog/ssl/chained.pem;
    ssl_certificate_key  /home/microblog/ssl/domain.key;
    ssl_session_timeout  1d;
    ssl_protocols        TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers          EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
    ssl_prefer_server_ciphers  on;

    ssl_session_cache          shared:SSL:50m;


    ssl_trusted_certificate    /home/microblog/ssl/full_chained.pem;
    resolver                   114.114.114.114 valid=300s;
    resolver_timeout           10s;
    
    if ($request_method !~ ^(GET|HEAD|POST|OPTIONS)$ ) {
        return   444;
    }
    
    location / {
        proxy_pass http://127.0.0.1:4010;
        proxy_redirect off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

}

server {
    server_name blog.lehuoha.com;
    server_tokens     off;
    
    access_log        /dev/null;

    location ^~ /.well-known/acme-challenge/ {
        alias /home/microblog/challenges/;
        try_files $uri =404;
    }
    
    location / {
        rewrite   ^/(.*)$ https://blog.lehuoha.com/$1 permanent;
    }    
    
}
```
重启nginx服务即可。

然后访问网站进行测试.

### 配置自动更新

Let's Encrypt 签发的证书只有 90 天有效期，推荐使用脚本定期更新。例如我就创建了一个 `renew_cert.sh` 并通过 `chmod a+x renew_cert.sh` 赋予执行权限。文件内容如下：

```bash
#!/bin/bash

cd /home/microblog/ssl/
python acme_tiny.py --account-key ./account.key --csr ./domain.csr --acme-dir /home/microblog/challenges > ./signed.crt || exit
wget -O - https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem > intermediate.pem
cat signed.crt intermediate.pem > chained.pem
service nginx reload
```

crontab 中使用绝对路径比较保险，`crontab -e` 加入以下内容：
```bash
0 0 1 * * /home/microblog/ssl/renew_cert.sh >/dev/null 2>&1
```

这样以后证书每个月都会自动更新，一劳永逸。实际上，Let's Encrypt 官方将证书有效期定为 90 天一方面是为了更安全，更重要的是鼓励用户采用自动化部署方案。