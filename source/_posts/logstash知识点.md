---
title: logstash知识点
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
0. Logstash是位于Data和Elasticsearch之间的一个中间件。Logstash是一个功能强大的工具，可与各种部署集成。 它提供了大量插件。 它从数据源实时地把数据进行采集，可帮助您解析，丰富，转换和缓冲来自各种来源的数据，并最终把数据传入到Elasticsearch之中。 如果您的数据需要Beats中没有的其他处理，则需要将Logstash添加到部署中。Logstash部署于ingest node之中。
0.1 默认情况下，Logstash在管道（pipeline）阶段之间使用内存中有界队列（输入到过滤器和过滤器到输出）来缓冲事件。 如果Logstash不安全地终止，则存储在内存中的所有事件都将丢失。 为防止数据丢失，您可以使Logstash通过使用持久队列将正在进行的事件持久化到磁盘上。可以通过在logstash.yml文件中设置queue.type：persisted属性来启用持久队列，该文件位于LOGSTASH_HOME/config文件夹下。 logstash.yml是一个配置文件，其中包含与Logstash相关的设置。 默认情况下，文件存储在LOGSTASH_HOME/data/queue中。 您可以通过在logstash.yml中设置path.queue属性来覆盖它。
1. 在使用logstash之前,必须要先安装JAVA
2. 下载地址:https://artifacts.elastic.co/downloads/logstash/logstash-7.3.0.tar.gz (里面的版本号可以根据实际情况进行修改)
3. 运行最基本的Logstash管道
```
cd logstash-7.3.0
bin/logstash -e 'input { stdin { } } output { stdout {} }'
```
4. 创建logstash.conf文件来运行管道
```
# logstash.conf文件内容
input { 
    stdin{ }
}
 
output {
    stdout {
       codec => rubydebug
}

# 运行
./bin/logstash -f logstash.conf (path_to_logstash_conf_file)
```
> 提示：在运行Logstash时使用`-r`标志可让您在更改和保存配置后自动重新加载配置。 在测试新配置时，这将很有用，因为您可以对其进行修改，这样就不必在每次更改配置时都手动启动Logstash。

<escape><!-- more --></escape>

5. 获得所有的plugins
```
bin/logstash-plugin list
```
6. input读取csv文件
```

input {
	file {
		path => "/Users/liuxg/data/cars.csv"
		start_position => "beginning"
		sincedb_path => "null"
	}

```
在input中，定义了一个文件，它的path指向csv文件的位置。start_position指向beginning。如果对于一个实时的数据源来说，它通常是ending，这样表示它每次都是从最后拿到那个数据。sincedb_path通常指向一个文件。这个文件保存上次操作的位置。设置为/dev/null，表明不存储这个数据
7. 在Logstash中，按照顺序执行的处理方式被叫做一个pipeline。一个pipeline含有一个按照顺序执行的逻辑数据流。pipeline从input里获取数据，并传送给一个队列，并接着传入到一些worker去处理

8. 官方提供的lostash关于apache,nginx应用的日志处理样本，网站: https://github.com/elastic/examples/tree/master/Common%20Data%20Formats
```
# apache_logstash.conf
input {  
  stdin { } 
}


filter {
  grok {
    match => {
      "message" => '%{IPORHOST:clientip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] "%{WORD:verb} %{DATA:request} HTTP/%{NUMBER:httpversion}" %{NUMBER:response:int} (?:-|%{NUMBER:bytes:int}) %{QS:referrer} %{QS:agent}'
    }
  }

  date {
    match => [ "timestamp", "dd/MMM/YYYY:HH:mm:ss Z" ]
    locale => en
  }

  geoip {
    source => "clientip"
  }

  useragent {
    source => "agent"
    target => "useragent"
  }
}

output {
  stdout {
    codec => dots {}
  }

  elasticsearch {
    index => "apache_elastic_example"
    template => "./apache_template.json"
    template_name => "apache_elastic_example"
    template_overwrite => true
  }
}
```

```
# apache_template.json
{

  "template": "apache_elastic_example",
  "settings": {
     "index.refresh_interval": "5s"
  },
  "mappings": {
     "_default_": {
        "dynamic_templates": [
           {
              "message_field": {
                 "mapping": {
                    "norms": false,
                    "type": "text"
                 },
                 "match_mapping_type": "string",
                 "match": "message"
              }
           },
           {
              "string_fields": {
                 "mapping": {
                    "norms": false,
                    "type": "text",
                    "fields": {
                       "keyword": {
                          "ignore_above": 256,
                          "type": "keyword"
                       }
                    }
                 },
                 "match_mapping_type": "string",
                 "match": "*"
              }
           }
        ],
        "properties": {
           "geoip": {
              "dynamic": true,
              "properties": {
                 "location": {
                    "type": "geo_point"
                 },
                 "ip": {
                   "type": "ip"
                 },
                 "continent_code": {
                  "type": "keyword"
                 },
                 "country_name": {
                   "type": "keyword"
                 }
              },
              "type": "object"
           },
           "@version": {
              "type": "keyword"
           }
        }
     }
  }
}
```

```
# nginx_logstash.conf
input {
  stdin { }
}

filter {
  grok {
    match => {
      "message" => '%{IPORHOST:remote_ip} - %{DATA:user_name} \[%{HTTPDATE:time}\] "%{WORD:request_action} %{DATA:request} HTTP/%{NUMBER:http_version}" %{NUMBER:response} %{NUMBER:bytes} "%{DATA:referrer}" "%{DATA:agent}"'
    }
  }

  date {
    match => [ "time", "dd/MMM/YYYY:HH:mm:ss Z" ]
    locale => en
  }

  geoip {
    source => "remote_ip"
    target => "geoip"
  }

  useragent {
    source => "agent"
    target => "user_agent"
  }
}

output {
stdout {
 codec => dots {}
 }
  elasticsearch {
    index => "nginx_elastic_stack_example"
    document_type => "logs"
    template => "./nginx_template.json"
    template_name => "nginx_elastic_stack_example"
    template_overwrite => true
  }
}
```

```
# nginx_template.json
{

  "template": "nginx_elastic_stack_example",
  "settings": {
     "index.refresh_interval": "5s"
  },
  "mappings": {
     "_default_": {
        "dynamic_templates": [
           {
              "message_field": {
                 "mapping": {
                    "index": "analyzed",
                    "norms": false,
                    "type": "string"
                 },
                 "match_mapping_type": "string",
                 "match": "message"
              }
           },
           {
              "string_fields": {
                 "mapping": {
                    "norms": false,
                    "type": "text",
                    "fields": {
                       "raw": {
                          "type": "keyword"
                       }
                    }
                 },
                 "match_mapping_type": "string",
                 "match": "*"
              }
           }
        ],
        "properties": {
           "geoip": {
              "dynamic": true,
              "properties": {
                 "location": {
                    "type": "geo_point"
                 }
              },
              "type": "object"
           },
           "bytes": {
              "type": "float"
           },
           "request": {
              "type": "keyword"
           }
        },
        "_all": {
           "enabled": true
        }
     }
  }
}
```

```
# nginx_json_logstash.conf
input {
  stdin {
    codec => json
    }
}

filter {

  date {
    match => ["time", "dd/MMM/YYYY:HH:mm:ss Z" ]
    locale => en
  }

  geoip {
    source => "remote_ip"
    target => "geoip"
  }

  useragent {
    source => "agent"
    target => "user_agent"
  }

  grok {
    match => [ "request" , "%{WORD:request_action} %{DATA:request1} HTTP/%{NUMBER:http_version}" ]
  }
}

output {
  stdout  {
    codec => dots {}
  }

  elasticsearch {
    index => "nginx_json_elastic_stack_example"
    document_type => "logs"
    template => "./nginx_json_template.json"
    template_name => "nginx_json_elastic_stack_example"
    template_overwrite => true
  }

}
```

```
# nginx_json_template.json
{
  "index_patterns": "nginx_json_elastic",
  "settings": {
    "index.refresh_interval": "5s"
  },
  "mappings": {
    "doc": {
      "dynamic_templates": [
        {
          "message_field": {
            "mapping": {
              "norms": false,
              "type": "text"
            },
            "match_mapping_type": "string",
            "match": "message"
          }
        },
        {
          "string_fields": {
            "mapping": {
              "type": "text",
              "norms": false,
              "fields": {
                "keyword": {
                  "type": "keyword",
                  "ignore_above": 256
                }
              }
            },
            "match_mapping_type": "string",
            "match": "*"
          }
        }
      ],
      "properties": {
        "geoip": {
          "dynamic": true,
          "properties": {
            "location": {
              "type": "geo_point"
            }
          },
          "type": "object"
        },
        "request": {
          "type": "keyword"
        }
      }
    }
  }
}
```

9. 处理多个input
```
# multi-input.conf
input {
  file {
    path => "/data/multi-input/apache.log"
  	start_position => "beginning"
    sincedb_path => "/dev/null"
    # ignore_older => 100000
    type => "apache"
  }
}
 
input {
  file {
    path => "/data/multi-input/apache-daily-access.log"
  	start_position => "beginning"
    sincedb_path => "/dev/null"
    type => "daily"
  }
}
 
filter {
  	grok {
    	match => {
      		"message" => '%{IPORHOST:clientip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] "%{WORD:verb} %{DATA:request} HTTP/%{NUMBER:httpversion}" %{NUMBER:response:int} (?:-|%{NUMBER:bytes:int}) %{QS:referrer} %{QS:agent}'
    	}
  	}
 
	if [type] == "apache" {
		mutate {
	  		add_tag => ["apache"]
	  	}
	}
 
	if [type] == "daily" {
		mutate {
			add_tag => ["daily"]
		}
	} 
}
 
 
output {
	stdout {
		codec => rubydebug
	}
 
	if "apache" in [tags] {
	  	elasticsearch {
	    	index => "apache_log"
	    	template => "/data/apache_template.json"
	    	template_name => "apache_elastic_example"
	    	template_overwrite => true
	  }	
	}
 
	if "daily" in [tags] {
	  	elasticsearch {
	    	index => "apache_daily"
	    	template => "/data/apache_template.json"
	    	template_name => "apache_elastic_example"
	    	template_overwrite => true
	  }	
	}	
}

# 运行
./bin/logstash -f multi-input.conf
```

使用了两个input。它们分别对应不同的log文件。对于这两个input，使用了不同的type来表示：apache和daily。尽管它们的格式是一样的，它们共同使用同样的一个grok filter，但是还是想分别对它们进行处理。为此，添加了一个tag。也可以添加一个field来进行区别。在output的部分，根据在filter部分设置的tag来对它们输出到不同的index里。
daily的事件最早被处理及输出,接着apache的数据才开始处理.

10. 处理多个配置文件(conf)
一个pipeline含有一个逻辑的数据流，它从input接收数据，并把它们传入到队列里，经过worker的处理，最后输出到output。这个output可以是Elasticsearch或其它

- 多个pipeline

两个不同的conf配置文件
```
# apache.conf
input {
    file {
        path => "/data/multi-input/apache.log"
        start_position => "beginning"
        sincedb_path => "/dev/null"
        # ignore_older => 100000
        type => "apache"
    }
}
 
filter {
  	grok {
    	match => {
      		"message" => '%{IPORHOST:clientip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] "%{WORD:verb} %{DATA:request} HTTP/%{NUMBER:httpversion}" %{NUMBER:response:int} (?:-|%{NUMBER:bytes:int}) %{QS:referrer} %{QS:agent}'
    	}
  	}
}
 
 
output {
	stdout {
		codec => rubydebug
	}
 
  	elasticsearch {
    	index => "apache_log"
    	template => "/data/apache_template.json"
    	template_name => "apache_elastic_example"
    	template_overwrite => true
  }	
}

# daily.conf
input {
    file {
        path => "/data/multi-pipeline/apache-daily-access.log"
        start_position => "beginning"
        sincedb_path => "/dev/null"
        type => "daily"
    }
}
 
filter {
  	grok {
    	match => {
      		"message" => '%{IPORHOST:clientip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] "%{WORD:verb} %{DATA:request} HTTP/%{NUMBER:httpversion}" %{NUMBER:response:int} (?:-|%{NUMBER:bytes:int}) %{QS:referrer} %{QS:agent}'
    	}
  	}
}
 
 
output {
	stdout {
		codec => rubydebug
	}
 
  	elasticsearch {
    	index => "apache_daily"
    	template => "/data/multi-pipeline/apache_template.json"
    	template_name => "apache_elastic_example"
    	template_overwrite => true
    }	
}
```

在logstash的安装目录下的config文件目录下,修改pipelines.yml文件.
```
# pipelines.yml
- pipeline.id: daily
  pipeline.workers: 1
  pipeline.batch.size: 1
  path.config: "/data/multi-pipeline/daily.conf"
  
- pipeline.id: apache
  queue.type: persisted
  path.config: "/data/multi-pipeline/apache.conf"
```

启动,注意：不使用`-f`参数指定配置文件
```
/bin/logstash
```

在终端中可以看到有两个piple在同时运行。

- 一个pipeline
修改位于Logstash安装目录下的config子目录里的pipleline.yml文件
```
# pipelines.yml
- pipeline.id: my_logs
  queue.type: persisted
  path.config: "/data/multi-pipeline/*.conf"
```

这里把所有位于/data/multi-pipeline/下的所有的conf文件都放于一个pipeline里。
启动,注意：不使用`-f`参数指定配置文件
```
/bin/logstash
```

在终端中会看到两个同样的输出，这是因为把两个.conf文件放于一个pipleline里运行，那么有两个stdout的输出分别位于两个.conf文件了。
apache_log里有20条数据，它包括两个log文件里所有的事件，这是因为它们都是一个pipleline。同样可以在apache_daily看到同样的20条数据。

采用这种方式意味着会把两个不同的配置文件获取的日志输出到同一个索引中。合并数据的话可以使用这种方式。

11. 把MySQL数据导入到Elasticsearch中

官方文档地址: https://www.elastic.co/guide/en/logstash/current/plugins-inputs-jdbc.html#plugins-inputs-jdbc-parameters

- MySQL安装,准备一些测试数据
- Logstash安装
根据mysql的版本信息下载相应的JDBC connector驱动,下载网站: https://dev.mysql.com/downloads/connector/j/
下载完这个Connector后，把这个connector存入到Logstash安装目录下的logstash-core/lib/jars/子目录中。
最终地址是这样的：logstash-7.3.0/logstash-core/lib/jars/mysql-connector-java-8.0.17.jar
- Logstash 配置
```
# sales.conf
input {
	jdbc {
       jdbc_connection_string => "jdbc:mysql://localhost:3306/data"
       jdbc_user => "root"
       jdbc_password => "YourMyQLPassword"
       jdbc_validate_connection => true
       jdbc_driver_library => ""
       jdbc_driver_class => "com.mysql.cj.jdbc.Driver"
       parameters => { "Product_id" => "Product1" }
       statement => "SELECT * FROM SalesJan2009 WHERE Product = :Product_id"
    }    
}
 

output {
	stdout {
	}
 
   	elasticsearch {
     	index => "sales"
     	hosts => "localhost:9200"
     	document_type => "_doc"
	} 
}
```

替换jdbc_user和jdbc_password为自己的MySQL账号的用户名及密码。特别值得指出的是jdbc_driver_library按elastic的文档是可以放入JDBC驱动的路径及驱动名称。实践证明如果这个驱动不在JAVA的classpath里，是不能被正确地加载。
正因为这样的原因，在上一步里把驱动mysql-connector-java-8.0.17.jar放入到Logstash的jar目录里，所以这里就直接填入空字符串。
- 运行Logstash加载数据
```
./bin/logstash --debug -f sales.conf 
```

注意：在MySQL中删除数据的话则不会自动同步删除es中的数据，需要另作处理

