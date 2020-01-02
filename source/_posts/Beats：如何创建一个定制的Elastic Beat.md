Beats作为Elastic Stack家族中重要的部分。它可以和方便地让我们把我们的数据发送到Elasticsearch或Logstash之中。如果我们想要生成自己的Beat，请使用GitHub的beats仓库中提供的Beat生成器。在今天的文章中，我们将详细介绍如何一步一步地来创建一个我们自己想要的beat。

# 设置自己的开发环境

## 安装go环境

Beats实际上是go程序。我们可以参照链接“Go get started”(https://golang.org/doc/install)来安装自己的golang语言开发环境。等我们安装好我们的go后，我们可以在terminal中打入如下的命令：
```
    $ which go
    /usr/local/go/bin/go
```
那么我们需要在我们的环境中设置如下的变量：
```
    export GOROOT=/usr/local/go
    export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
    export GOPATH=$HOME/go/beats
```
在这里，我也设置了以GOPATH。你可以设置自己的路径。针对我的情况，我在我的home目录下创建了一个go目录，并在go目录下生产一个叫做beats的目录。在一下，我们会在这个目录里生成我们的定制的beat。
 
## 下载Elastic beats源码

在这一步我们下载Elastic beats的源码。在termnial中打入如下的命令：
```
    mkdir -p ${GOPATH}/src/github.com/elastic
    git clone https://github.com/elastic/beats ${GOPATH}/src/github.com/elastic/beats
```
## 安装Python

目前generator只对Python2适用，所以，我们需要安装Python2。我们可以参照页面https://www.python.org/downloads/进行安装我们的python2。
安装virtualenv

我们必须安装virtualenv才能使得generator正常工作。可以参照链接https://virtualenv.pypa.io/en/latest/installation/来进行安装。如果自己的电脑上同时已经安装了python3，那么我们需要同时设置如写变量：
```
    export PYTHON_EXE='python2.7'
    export VIRTUALENV_PARAMS='-p python2.7'
    export VIRTUALENV_PYTHON='/usr/bin/python2.7'
     
    export VIRTUALENV_PYTHON='/usr/local/bin/python' (for Mac)
```
请注意：这里的python是2.x版本的python，而不是python3。我们需要保证VIRTUALENV_PYTHON指向我们的Python2的执行文件。

## 安装mage

我们需要在地址https://github.com/magefile/mage下载这个源码，并编译：
```
    go get -u -d github.com/magefile/mage
    cd $GOPATH/src/github.com/magefile/mage
    go run bootstrap.go
```
等上面的命令执行完后，我们可以在如下的目录中找到编译好的执行文件mage:
```
    liuxg-2:bin liuxg$ ls $GOPATH/bin
    mage
```
 
# 创建定制beat

首先创建一个目录在$GOPATH下，并进入该目录。
```
    mkdir ${GOPATH}/src/github.com/{user}
    cd ${GOPATH}/src/github.com/{user}
```
注意这里的user指的是自己在github上的用户名。比如针对我的情况是liu-xiao-guo。我打入如下写的命令：
```
    mkdir ${GOPATH}/src/github.com/liu-xiao-guo
    cd  $GOPATH/src/github.com/elastic/beats/
```
接下来，我们运行如下的命令：
```
mage GenerateCustomBeat
```
执行结果：
```
    $ mage GenerateCustomBeat
    2019/11/13 15:24:01 Found Elastic Beats dir at /Users/liuxg/go/beats/src/github.com/elastic/beats
    Enter the beat name [examplebeat]: Countbeat
    Enter your github name [your-github-name]: liu-xiao-guo
    Enter the beat path [github.com/liu-xiao-guo/countbeat]: 
    Enter your full name [Firstname Lastname]: Xiaoguo Liu
    Enter the beat type [beat]: 
    DEPRECATION: Python 2.7 will reach the end of its life on January 1st, 2020. Please upgrade your Python as Python 2.7 won't be maintained after that date. A future version of pip will drop support for Python 2.7. More details about Python 2 support in pip, can be found at https://pip.pypa.io/en/latest/development/release-process/#python-2-support
    DEPRECATION: Python 2.7 will reach the end of its life on January 1st, 2020. Please upgrade your Python as Python 2.7 won't be maintained after that date. A future version of pip will drop support for Python 2.7. More details about Python 2 support in pip, can be found at https://pip.pypa.io/en/latest/development/release-process/#python-2-support
     
    WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'ReadTimeoutError("HTTPSConnectionPool(host='pypi.tuna.tsinghua.edu.cn', port=443): Read timed out. (read timeout=15)",)': /simple/semver/
    2019/11/13 15:25:50 Found Elastic Beats dir at /Users/liuxg/go/beats/src/github.com/liu-xiao-guo/countbeat/vendor/github.com/elastic/beats
    Generated fields.yml for countbeat to /Users/liuxg/go/beats/src/github.com/liu-xiao-guo/countbeat/fields.yml
    2019/11/13 15:25:52 Found Elastic Beats dir at /Users/liuxg/go/beats/src/github.com/liu-xiao-guo/countbeat/vendor/github.com/elastic/beats
    Auto packing the repository in background for optimum performance.
    See "git help gc" for manual housekeeping.
    =======================
    Your custom beat is now available as /Users/liuxg/go/beats/src/github.com/liu-xiao-guo/countbeat
    =======================
```

![](https://img-blog.csdnimg.cn/20191113152718697.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

这样，我们基本上就生产了一个最基本的beat的框架。

接下来，我们进入到我们的beat目录里，并进行编译：
```
cd ${GOPATH}/src/github.com/{user}/countbeat
```
针对我的情况：
```
cd ${GOPATH}/src/github.com/liu-xiao-guo/countbeat
```
我们可以看一下里面最基本的文件：
```
    $ pwd
    /Users/liuxg/go/beats/src/github.com/liu-xiao-guo/countbeat
    liuxg-2:countbeat liuxg$ ls
    CONTRIBUTING.md		cmd			magefile.go
    LICENSE.txt		config			main.go
    Makefile		countbeat.docker.yml	main_test.go
    NOTICE.txt		countbeat.reference.yml	make.bat
    README.md		countbeat.yml		tests
    _meta			docs			vendor
    beater			fields.yml
    build			include
```
这里有最基本的框架文件。里面含有一个叫做countbeat.yml的配置文件及一些标准的模板文件。我们在命令行中直接打入如下的指令：
```
make

    $ make
    go build -i -ldflags "-X github.com/liu-xiao-guo/countbeat/vendor/github.com/elastic/beats/libbeat/version.buildTime=2019-11-13T07:33:25Z -X github.com/liu-xiao-guo/countbeat/vendor/github.com/elastic/beats/libbeat/version.commit=501bd87da668346f78398676c78b4a39394a3640"
```
经过上面的编译，我们可以发现在当前的目录下，有一个已经编译好的countbeat可执行文件：

![](https://img-blog.csdnimg.cn/20191113153829331.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们在当前的目录下直接运行这个可执行的文件：
```
./countbeat -e -d "*"
```
我们可以在terminal中看到：

![](https://img-blog.csdnimg.cn/20191113154519992.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

那么在我们的Kibana中也可以看到如下信息：

![](https://img-blog.csdnimg.cn/20191113154632456.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

![](https://img-blog.csdnimg.cn/2019111315472356.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

显然数据已经被成功上传到Elasticsearch中了。

每一个文档的内容如下：
```
    {
      "@timestamp": "2019-11-13T07:38:57.095Z",
      "agent": {
        "version": "8.0.0",
        "type": "countbeat",
        "ephemeral_id": "d3f0638e-ee58-45ff-92cc-74f188fd66a4",
        "hostname": "liuxg-2.local",
        "id": "1d35220e-7f75-442a-88eb-43ec1e97f0d0"
      },
      "counter": 5,
      "ecs": {
        "version": "1.2.0"
      },
      "host": {
        "hostname": "liuxg-2.local",
        "architecture": "x86_64",
        "os": {
          "build": "19B88",
          "platform": "darwin",
          "version": "10.15.1",
          "family": "darwin",
          "name": "Mac OS X",
          "kernel": "19.0.0"
        },
        "id": "E51545F1-4BDC-5890-B194-83D23620325A",
        "name": "liuxg-2.local"
      },
      "type": "liuxg-2.local"
    }
```
它里面含有一个counter的整数值。

所有关于beat的设计上的代码可以在目录${GOPATH}/src/github.com/liu-xiao-guo/countbeat下的/beater/CountBeat.go文件里实现的。设计比较直接。大家可以看一下代码应该可以明白。

![](https://img-blog.csdnimg.cn/20191113220431711.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

# 读取JSON文件beat

在上面我们已经熟悉了如何去创建一个template的beat。它是一个最基本的beat，并没有什么特别的功能。在这节里，我们接着如法炮制来创建一个稍微有一点用途的beat。我们的这个beat叫做readjson beat。它的源码可以按照如下的方法得到：
```
git clone https://github.com/liu-xiao-guo/beats-readjson
```
首先，我们可以准备一个我们想要的json文件，比如：
```
users.json

    {
      "users": [
        {
          "name": "Elliot",
          "type": "Reader",
          "age": 23,
          "social": {
            "facebook": "https://facebook.com",
            "twitter": "https://twitter.com"
          }
        },
        {
          "name": "Fraser",
          "type": "Author",
          "age": 17,
          "social": {
            "facebook": "https://facebook.com",
            "twitter": "https://twitter.com"
          }
        }
      ]
    }
```
我们可以把这个文件放入到我们如何喜欢的位置。针对我的情况，我把它置于我的电脑的如下位置：
```
/Users/liuxg/data/beats/users.json
```
我们可以在readjson.yml文件中进行配置：
```
readjson.yml
```
![](https://img-blog.csdnimg.cn/20191113222545196.png)

我们的readjson.go设计也相当简单：
```
readjson.go

    package beater
     
    import (
    	"fmt"
    	"os"
    	"io/ioutil"
    	"encoding/json"
    	"strconv"
    	"time"
    	"os/signal"
        "syscall"
     
    	"github.com/elastic/beats/libbeat/beat"
    	"github.com/elastic/beats/libbeat/common"
    	"github.com/elastic/beats/libbeat/logp"
     
    	"github.com/liu-xiao-guo/readjson/config"
    )
     
    type Users struct {
        Users []User `json:"users"`
    }
     
    // User struct which contains a name
    // a type and a list of social links
    type User struct {
        Name   string `json:"name"`
        Type   string `json:"type"`
        Age    int    `json:"Age"`
        Social Social `json:"social"`
    }
     
    // Social struct which contains a
    // list of links
    type Social struct {
        Facebook string `json:"facebook"`
        Twitter  string `json:"twitter"`
    }
     
    // readjson configuration.
    type readjson struct {
    	done   chan struct{}
    	config config.Config
    	client beat.Client
    }
     
    // New creates an instance of readjson.
    func New(b *beat.Beat, cfg *common.Config) (beat.Beater, error) {
    	c := config.DefaultConfig
    	if err := cfg.Unpack(&c); err != nil {
    		return nil, fmt.Errorf("Error reading config file: %v", err)
    	}
     
    	bt := &readjson{
    		done:   make(chan struct{}),
    		config: c,
    	}
    	return bt, nil
    }
     
    // Run starts readjson.
    func (bt *readjson) Run(b *beat.Beat) error {
    	logp.Info("readjson is running! Hit CTRL-C to stop it.")
    	var err error
    	bt.client, err = b.Publisher.Connect()
    	if err != nil {
    		return err
    	}
     
    	fmt.Println("Path: ", bt.config.Path)
    	fmt.Println("Period: ", bt.config.Period)
     
    	
    	// Open our jsonFile
    	jsonFile, err := os.Open(bt.config.Path)
    	// if we os.Open returns an error then handle it
    	if err != nil {
        	fmt.Println(err)
    	}
     
    	fmt.Println("Successfully Opened users.json")
    	// defer the closing of our jsonFile so that we can parse it later on
    	defer jsonFile.Close()
    	
     
    	byteValue, _ := ioutil.ReadAll(jsonFile)
     
    	// we initialize our Users array
        var users Users
     
        json.Unmarshal(byteValue, &users)
     
        // we iterate through every user within our users array and
        // print out the user Type, their name, and their facebook url
        // as just an example
        for i := 0; i < len(users.Users); i++ {
            fmt.Println("User Type: " + users.Users[i].Type)
            fmt.Println("User Age: " + strconv.Itoa(users.Users[i].Age))
            fmt.Println("User Name: " + users.Users[i].Name)
            fmt.Println("Facebook Url: " + users.Users[i].Social.Facebook)
     
            event := beat.Event{
    			Timestamp: time.Now(),
    			Fields: common.MapStr {
    				"ostype":    	b.Info.Name,
    				"name":		users.Users[i].Name,
    				"type":		users.Users[i].Type,
    				"age":		users.Users[i].Age,
    				"social":	users.Users[i].Social,
    			},
    		}
     
    		bt.client.Publish(event)
        }
     
        c := make(chan os.Signal)
        signal.Notify(c, os.Interrupt, syscall.SIGTERM)
        go func() {
            <-c
            os.Exit(1)
        }()
     
        for {
            fmt.Println("sleeping...")
            time.Sleep(10 * time.Second)
        }	
    }
     
    // Stop stops readjson.
    func (bt *readjson) Stop() {
    	bt.client.Close()
    	close(bt.done)
    }
```
它在run method里把json文件读入，并把它们分别发送出去到我们的Elasticsearch中。

我们按照上面的步骤进行编译，并最终运行我们的readjson beat。
```
./readjson -e
```

![](https://img-blog.csdnimg.cn/20191113223124531.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们可以在Kibana中看到我们已经发送上来的beat信息：

参考：
【1】https://www.elastic.co/guide/en/beats/devguide/7.5/newbeat-generate.html
