---
title: Node.js入门
date: 2019-07-03 17:10:03
tags: 
- Node.js 
categories:
- Node.js 
---
# 什么是Node.js？

## 概要

Node.js是一个Javascript运行环境(runtime)，发布于2009年5月，由Ryan Dahl开发，实质是对Chrome V8引擎进行了封装。
Node.js 的包管理器 npm，是全球最大的开源库生态系统。

## 官方网站
https://nodejs.org/

## 使用版本
+ 10.16.0 LTS

## 基础知识
+ Javascript/ES2015(ES6)
+ Unix/Linux(Ubuntu)

<escape><!-- more --></escape>

## 开发工具
* 记事本等文本编辑器
 1. Visual Studio Code(推荐)
 2. Brackets
 3. ATOM

* 浏览器
 1. Google Chrome(推荐)
 2. FireFox
 3. IE/edge

# 线程模型和事件循环

## 知识点
* 线程模型
* 事件循环

### 线程模型
Apache+Tomcat(6,7,8,9)运行
1. req来袭
2. thread应对
3. req处理完后，thread释放

线程处理模式就是重复以上三个步骤，来处理来自客户端的各种请求，当有大量客户端的请求来袭时，服务器消耗的资源也会随之增加。

### 事件循环
Node.js服务运行  
1. 开一个事件等待循环（event-loop）
2. req来袭
3. 放入事件处理队列中，然后继续等待新的req请求
4. req处理完成后，调用I/O，结束req(非阻塞调用)

事件循环处理模式中，线程不用等待req处理完后在进行下个req的处理，而是将所有的req请求放入到队列之中，然后采用非同步的方式，等待req处理完后再调用I/O资源，然后结束req。

# 从HelloWorld开始

## 知识点
* Node.js控制台
* javascript文件

## 实战演习

### Node.js控制台
~~~bash
C:\Users\sandu
λ npm --version # 查看npm版本
6.9.0

C:\Users\sandu
λ node --version # 查看node.js版本
v10.16.0

C:\Users\sandu 
λ node # Node.js控制台入口

> console.log('hello world!'); # 输出log
hello world!
undefined

> .help # 查看命令帮助
.break    Sometimes you get stuck, this gets you out
.clear    Alias for .break
.editor   Enter editor mode
.exit     Exit the repl
.help     Print this help message
.load     Load JS from a file into the REPL session
.save     Save all evaluated commands in this REPL session to a file

> .exit # 退出命令控制台
~~~

### javascript文件
创建一个heloworld.js文件，内容如下：
```text
console.log('hello world!');

var str = 'hello';
console.log(str);
```
使用node.js执行该js文件：
```bash
D:\node_test
λ node helloworld.js
hello world!
hello
```

# 非阻塞处理

## 知识点
* 阻塞处理(Java,Ruby,PHP,Asp.Net)
* 非阻塞处理(Node.js)

## 实战演习

```js
////////////////////
// 阻塞处理
////////////////////
function updb1() {
    var start = new Date().getTime();
    while (new Date().getTime() < start + 3000);
}
updb1();
//数据库更新完毕后才会执行下面这俩
console.log("updb1 success.");
console.log("I like javascript.");

////////////////////
// 非阻塞处理
////////////////////
function updb2(done) {
    setTimeout(() => {
        done();
    }, 3000);
}
updb2(function () {
    //数据库更新完毕后再执行这个回调函数
    console.log("updb2 success.");
});
console.log("I like Nodejs."); // 先执行这个
```

# 简单的Web服务器

## 知识点
* http内置模块

参照文档：
https://nodejs.org/en/about/

## 实战演习
```js
const http = require('http');
const hostname = '127.0.0.1';
const port = 3000;

const server = http.createServer((req,res) => {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');
    res.end('Hello world\n');
});

server.listen(port,hostname,() => {
    console.log(`Server running at http://${hostname}:${port}/`); 
});

// 使用浏览器访问http://127.0.0.1:3000,页面上就会出现Hello world
```

# 引用外部js文件

## 知识点
* require：引用外部js文件

## 实战演习

### config.js
```js
const config = {
    hostname:'127.0.0.1',
    port:3000,
};
exports.config = config;
```

### myserver.js
```js
const http = require('http');
const config = require('./config.js').config;

const server = http.createServer((req,res) => {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');
    res.end('Hello world\n');
});

server.listen(config.port,config.hostname,() => {
    console.log(`Server running at http://${config.hostname}:${config.port}/`); 
});
```

# URL为我指引方向

## 知识点
* req.url：返回客户端请求的url地址

## 实战演习
```js
const http = require('http');

const hostname = '127.0.0.1';
const port = 3000;

const server = http.createServer((req, res) => {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');

    switch (req.url) {
        case '/':
            res.end('helo world.');
            break;
        case '/about':
            res.end('This is about page.');
            break;
        case '/home':
            res.end('Welcome to my homepage!');
            break;
        default:
            res.end('NotFound!');
    }
});

server.listen(port, hostname, () => {
    console.log(`Server running at http://${hostname}:${port}/`);
});
```

# 你写我读HTML

## 知识点
* fs文件读写模块的引用

## 实战演习

### index.html
```html
<html>
    <body>
        <h1>Helo index.html!</h1>
    </body>
</html>
```

### myserver.js
```js
const http = require('http');
const hostname = '127.0.0.1';
const port = 3000;

const fs = require('fs');

const server = http.createServer((req,res) => {

    fs.readFile(__dirname + '/index.html','utf-8',function(err,data) {
        if (err) {
            res.setHeader('Content-Type', 'text/plain');
            res.statusCode = 400;
            res.end('Not Found!\n');
        } else {
            res.setHeader('Content-Type', 'text/html');
            res.statusCode = 200;
            res.end(data); // 浏览器界面会出现index.html文件中的内容，也就是Hello world!
        }
    });
});

server.listen(port,hostname,() => {
    console.log(`Server running at http://${hostname}:${port}/`); 
});
// 修改index.html文件中的内容后，刷新浏览器会自动更新显示出来
```

# npm包管理器

## 知识点
* npm的使用方法
* ejs的安装

npm是Node.js附带的第三方软件包管理器，可以为Node.js提供更多的功能支持。

## npm官网
https://npmjs.org/

## ejs(Effective JavaScript templating)
http://ejs.co/

## 实战演习
```bash
D:\node_test
// 需要package.json才能npm install。
// 可以npm init初始化生成一个package.json。
// 然后就可以愉快地npm install了。
λ npm init
λ npm install ejs
```

### hello.ejs
```html
<html>
    <title><%= title %></title>
    <body>
        <%- content %>
    </body>
</html>
```

# ejs能写网页？

## 知识点
* ejs的使用

## 实战演习

### hello.ejs
```js
<html>
<head>
    <meta charset="UTF-8">
    <title><%= title %></title>
</head>
<body>
    <%= content %>
</body>
</html>
```

### myserver.js
```js
const http = require('http');
const fs = require('fs');
const ejs = require('ejs');
var template = fs.readFileSync(__dirname + '\\hello.ejs','utf-8'); //注意引用的路径
const server = http.createServer((req, res) => {
    var data = ejs.render(template, {
        title: 'helo ejs',
        content: '<strong>big helo ejs.</strong>'
    });
    res.setHeader('Content-Type', 'text/html');
    res.statusCode = 200;
    res.end(data);
});

const hostname = '127.0.0.1';
const port = 3000;
server.listen(port, hostname, () => {
    console.log(`Server running at http://${hostname}:${port}/`);
});
// 不知因为啥原因，<strong></strong>标签没生效，而是在页面上直接显示出来了
```

# 做个小论坛

## 知识点
* 做一个含有表单的论坛网页

## 实战演习
### forum.ejs
```html
<!DOCTYPE html>
<html lang="zh-cmn-Hans">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>小论坛</title>
</head>
<body>
    <form action="" method="post">
        <input type="text" name="content" id="content">
        <input type="submit" value="提交">
        <ul>
            <% for(var i = 0; i < posts.length; i++) { %>
            <li><%= posts[i] %></li>
            <% } %>
        </ul>
    </form>
</body>
</html>
```

# 表单的处理

## 知识点
* 服务器表单的处理

## 实战演习

### myserver.js
```js
const http = require('http');
const fs = require('fs');
const ejs = require('ejs');
const qs = require('querystring'); //+

var template = fs.readFileSync(__dirname + '/forum.ejs', 'utf-8');
var posts = []; //+

const server = http.createServer((req, res) => {
    if (req.method === 'POST') {
        //表单提交
        req.data = "";
        req.on("readable", function () {
            //表单数据收集
            var chr = req.read();
            if (chr)
                req.data += chr;
        });
        req.on("end", function () {
            //表单处理
            var query = qs.parse(req.data);
            posts.push(query.content);
            showForm(posts, res);
        });
    } else {
        //表单显示
        showForm(posts, res);
    }
});

const hostname = '127.0.0.1';
const port = 3000;
server.listen(port, hostname, () => {
    console.log(`Server running at http://${hostname}:${port}/`);
});

function showForm(p_posts, res) {
    var data = ejs.render(template, {
        title: 'helo ejs',
        posts: p_posts
    });
    res.setHeader('Content-Type', 'text/html');
    res.statusCode = 200;
    res.end(data);
}
```

# 连接MongoDB

## 知识点
* mongodb驱动安装
* node.js连接MongoDB

## 实战演习

### mongodb驱动安装

官方网站：
http://mongodb.github.io/node-mongodb-native/

```bash
$ npm install mongodb --save 
```

PS：Mongoose也是一个非常不错的MongoDB存取API，也推荐给您。

### node.js操作MongoDB

#### mongofunc.js

```js
const MongoClient = require('mongodb').MongoClient;
const assert = require('assert');

// Connection URL
const url = 'mongodb://127.0.0.1:27017';  // 本机需要事先安装并启动MongoDB

// Database Name
const dbName = 'blog';

// Use connect method to connect to the server
MongoClient.connect(url, { useNewUrlParser: true }, function (err, client) {
    assert.equal(null, err);
    console.log("Connected successfully to server");
    const db = client.db(dbName);
    client.close();
});
```

# 插入MongoDB文档

## 知识点
* node.js操作MongoDB

## 实战演习

### mongofunc.js

```js
const MongoClient = require('mongodb').MongoClient;
const assert = require('assert');

// Connection URL
const url = 'mongodb://127.0.0.1:27017';

// Database Name
const dbName = 'blog';

// Use connect method to connect to the server
MongoClient.connect(url, { useNewUrlParser: true }, function (err, client) {
    assert.equal(null, err);
    console.log("Connected successfully to server");

    const db = client.db(dbName);

    db.collection("posts", function (err, collection) {
        var list = [
            {title:"我爱玩马里奥", tag:"game"},
            {title:"我喜欢Nodejs编程", tag:"it"},
            {title:"我会用MongoDB", tag:"it"}
        ];
        collection.insert(list, function (err, result) {
            assert.equal(null, err);
            client.close();
        });
    });
});
```

# 读出MongoDB文档

## 知识点
* node.js读取MongoDB

## 实战演习

### mongofunc.js

```js
const MongoClient = require('mongodb').MongoClient;
const assert = require('assert');

// Connection URL
const url = 'mongodb://127.0.0.1:27017';

// Database Name
const dbName = 'blog';

// Use connect method to connect to the server
MongoClient.connect(url, { useNewUrlParser: true }, function (err, client) {
    assert.equal(null, err);
    console.log("Connected successfully to server");

    const db = client.db(dbName);

    db.collection("posts", function (err, collection) {
        collection.find({tag:"game"}).toArray(function (err, docs) {
            assert.equal(null, err);
            console.log(docs);
            client.close();
        });
    });
});
```

# Node.js回调地狱

## 知识点
* Node.js回调地狱
* Promise承诺解决

## 回调地狱

Node.js是非阻塞编程，那么在编码过程中会遇到很多的回调函数（Callback），如果多个处理的回调函数嵌套在一起的话，就会形成回调地狱，虽然对于程序的结果没有任何影响，但对于程序代码的可读性来说就是个地狱。

```js
//回调地狱
function dbupd(sql, done) {
    setTimeout(() => done(sql + " upd ok."), 800);
}
dbupd("1.sql1", result => {
    console.log(result);
    dbupd("2.sql2", result => {
        console.log(result);
        dbupd("3.sql3", result => {
            console.log(result);
        });
    });
});
```

## Promise解决
```js
// Promise函数嵌套解决方法
function dbupAsync(sql) {
    const p = new Promise((resolve, reject) => {
        setTimeout(() => {
            console.log(sql + " upd ok.");
            resolve(sql + ".ok");
        }, 800)
    });
    return p;
}
dbupAsync("2.sql1")
    .then(() => dbupAsync("2.sql2"))
    .then(() => dbupAsync("3.sql3"));

// 代码更加简洁的async/await
async function upAllDB() {
    const result1 = await dbupAsync("3.sql1");
    const result2 = await dbupAsync("3.sql2");
    const result3 = await dbupAsync("3.sql3");
    console.log(result1, result2, result3);
}
upAllDB();
```

# Promise解决回掉地狱

## 知识点
* Promise承诺解决

## 实际演示一下回掉地狱，以及如何解决回掉地狱

```js
// updb1.js演示一下回掉地狱
function dbupd(sql, done) {
    setTimeout(() => done(sql + " upd ok."), 800);
}
dbupd("1.sql1", result => {
    console.log(result);
    dbupd("2.sql2", result => {
        console.log(result);
        dbupd("3.sql3", result => {
            console.log(result);
        });
    });
});
```

```js
// updb2.js解决回掉地狱
// Promise函数嵌套解决方法
function dbupAsync(sql) {
    const p = new Promise((resolve, reject) => {
        setTimeout(() => {
            console.log(sql + " upd ok.");
            resolve(sql + ".ok");
        }, 800)
    });
    return p;
}
// dbupAsync("2.sql1")
//     .then(() => dbupAsync("2.sql2"))
//     .then(() => dbupAsync("3.sql3"));

// 代码更加简洁的async/await
async function upAllDB() {
    const result1 = await dbupAsync("3.sql1");
    const result2 = await dbupAsync("3.sql2");
    const result3 = await dbupAsync("3.sql3");
    console.log(result1, result2, result3);
}
upAllDB();
```