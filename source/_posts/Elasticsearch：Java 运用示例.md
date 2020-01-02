---
title: Elasticsearch：Java 运用示例
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
在今天的文章中，我们来介绍如何使用Java来访问Elasticsearch。

首先，我们必须在我们的系统中安装Elasticsearch。

# Maven 配置

针对Java的开发，我们必须在pom.xml中配置相应的Elasticsearch的信息。Mavev dependency定义如下：
```
        <dependency>
          <groupId>org.elasticsearch</groupId>
          <artifactId>elasticsearch</artifactId>
          <version>7.3.1</version>
        </dependency>
```
这也是目前截止最新的Elasticsearch的版本。您可以随时使用之前提供的链接查看Maven Central托管的最新版本。

<escape><!-- more --></escape>

# 完成数据库的查询

## 建立一个简单的model
```
    package com.javacodegeeks.example;
     
    public class Person {
     
        private String personId;
        private String name;
        private String number;
     
        public String getNumber() {
            return number;
        }
     
        public void setNumber(String number) {
            this.number = number;
        }
     
     
        public String getPersonId() {
            return personId;
        }
     
        public void setPersonId(String personId) {
            this.personId = personId;
        }
     
        public String getName() {
            return name;
        }
     
        public void setName(String name) {
            this.name = name;
        }
     
        @Override
        public String toString() {
            return String.format("Person{personId='%s', name='%s', number='%s}", personId, name, number);
        }
    }
```
在这里，我们定义了一个简单的Person Model。
 
## 定义连接参数

我们将使用默认连接参数与Elasticsearch建立连接。 默认情况下，ES使用两个端口：9200和9201
```
        private static final String HOST = "localhost";
        private static final int PORT_ONE = 9200;
        private static final int PORT_TWO = 9201;
        private static final String SCHEME = "http";
     
        private static RestHighLevelClient restHighLevelClient;
        private static ObjectMapper objectMapper = new ObjectMapper();
     
        private static final String INDEX = "persondata";
        private static final String TYPE = "_doc";
```
这里我们定义了一个叫做persondata的index，它的type是_doc。在最新的版本中，每个index只支持一个type。

如上面参数中所述，Elasticsearch使用两个端口9200和9201.第一个端口9200由Elasticsearch查询服务器使用，我们可以使用它通过RESTful API直接查询数据库。 第二个端口9201由REST服务器使用，外部客户端可以使用该端口连接并执行操作。
 
## 建立一个连接

我们将创建一个与Elasticsearch数据库建立连接的方法。 在建立与数据库的连接时，我们必须提供两个端口，因为只有这样，我们的应用程序才能连接到Elasticsearch服务器，我们将能够执行数据库操作。 以下是建立连接的代码。
```
        private static synchronized RestHighLevelClient makeConnection() {
     
            if(restHighLevelClient == null) {
                restHighLevelClient = new RestHighLevelClient(
                        RestClient.builder(
                                new HttpHost(HOST, PORT_ONE, SCHEME),
                                new HttpHost(HOST, PORT_TWO, SCHEME)));
            }
     
            return restHighLevelClient;
        }
```
在这里，我们建立一个RestHighLevelClient的实例。具体的参数，可以参官方文档  Java High Level REST Client (https://www.elastic.co/guide/en/elasticsearch/client/java-rest/7.3/java-rest-high.html)。

请注意，我们在此处实现了Singleton Design模式，因此不会为ES创建多个连接，从而节省大量内存。

由于存在RestHighLevelClient，与Elasticsearch的连接是线程安全的。 初始化此连接的最佳时间是应用程序请求或向客户端发出第一个请求时。 初始化此连接客户端后，可以使用它来执行任何支持的API。

## 关掉一个连接

就像在早期版本的Elasticsearch中一样，我们使用TransportClient，一旦完成查询就关闭它，一旦数据库交互完成RestHighLevelClient，也需要关闭连接。 以下是如何做到这一点：
```
        private static synchronized void closeConnection() throws IOException {
            restHighLevelClient.close();
            restHighLevelClient = null;
        }
```
我们还为RestHighLevelClient对象分配了null，以便Singleton模式可以保持一致。

 
## 插入一个文档

我们可以通过将键和值转换为HashMap将数据插入数据库。 ES数据库仅接受HashMap形式的值。 让我们看看如何实现这一目标的代码片段：
```
       private static Person insertPerson(Person person) {
     
            person.setPersonId(UUID.randomUUID().toString());
            Map<String, Object> dataMap = new HashMap<String, Object>();
            dataMap.put("name", person.getName());
            dataMap.put("number", person.getNumber());
            IndexRequest indexRequest = new IndexRequest(INDEX)
                    .id(person.getPersonId()).source(dataMap);
            try {
                IndexResponse response = restHighLevelClient.index(indexRequest, RequestOptions.DEFAULT);
            } catch(ElasticsearchException e) {
                e.getDetailedMessage();
            } catch (java.io.IOException ex){
                ex.getLocalizedMessage();
            }
     
            /*
            // The following is another way to do it
            // More information https://www.elastic.co/guide/en/elasticsearch/client/java-rest/7.3/java-rest-high-document-index.html
            String id = UUID.randomUUID().toString();
            person.setPersonId(id);
            IndexRequest request = new IndexRequest(INDEX);
            request.id(id);
            String jsonString = "{" +
                    "\"name\":" + "\"" + person.getName() + "\"" +
                    "}";
            System.out.println("jsonString: " + jsonString);
            request.source(jsonString, XContentType.JSON);
            try {
                IndexResponse response = restHighLevelClient.index(request, RequestOptions.DEFAULT);
            } catch(ElasticsearchException e) {
                e.getDetailedMessage();
            } catch (java.io.IOException ex){
                ex.getLocalizedMessage();
            }
             */
     
            return person;
        }
```
就像上面代码中注释的那样。注释的代码的那一部分是另外一种方法。大家可以参照链接(https://www.elastic.co/guide/en/elasticsearch/client/java-rest/7.3/java-rest-high-document-index.html)获得更多的信息。

上面，我们使用Java的UUID类来创建对象的唯一标识符。 这样，我们就可以控制对象标识符的制作方式。我们其实也可以固定一个id去写。如果是这样的话，运行多次，只会更新之前的数据，并且version会自动每次运行后增加1。

 
## 请求上面存入的文档

完成将数据插入数据库后，我们可以通过向Elasticsearch数据库服务器发出GET请求来确认操作。 让我们看看如何完成此操作的代码片段：
```
 

       private static Person getPersonById(String id){
     
            GetRequest getPersonRequest = new GetRequest(INDEX, id);
            GetResponse getResponse = null;
            try {
                getResponse = restHighLevelClient.get(getPersonRequest, RequestOptions.DEFAULT);
            } catch (java.io.IOException e){
                e.getLocalizedMessage();
            }
            return getResponse != null ?
                    objectMapper.convertValue(getResponse.getSourceAsMap(), Person.class) : null;
        }
```
在这里，我们根据上面返回来得id来进行query，并返回数据。

在这个查询中，我们只提供了可以识别它的对象的主要信息，即索引，和它的唯一标识符id。 此外，我们得到的实际上是一个值的映射。

 
## 更新文档

我们可以通过首先使用其索引，类型和唯一标识符来标识资源，从而轻松地向Elasticsearch发出更新请求。 然后我们可以使用新的HashMap对象来更新Object中的任意数量的值。 这是一个示例代码段：
```

       private static Person updatePersonById(String id, Person person){
            UpdateRequest updateRequest = new UpdateRequest(INDEX, id)
                    .fetchSource(true);    // Fetch Object after its update
            try {
                String personJson = objectMapper.writeValueAsString(person);
                updateRequest.doc(personJson, XContentType.JSON);
                UpdateResponse updateResponse = restHighLevelClient.update(updateRequest, RequestOptions.DEFAULT);
                return objectMapper.convertValue(updateResponse.getGetResult().sourceAsMap(), Person.class);
            }catch (JsonProcessingException e){
                e.getMessage();
            } catch (java.io.IOException e){
                e.getLocalizedMessage();
            }
            System.out.println("Unable to update person");
            return null;
        }
```
## 删除文档

最后，我们可以通过简单地使用其索引，类型和唯一标识符来标识资源来删除数据。 让我们看一下如何完成此操作的代码片段
```
        private static void deletePersonById(String id) {
            DeleteRequest deleteRequest = new DeleteRequest(INDEX, TYPE, id);
            try {
                DeleteResponse deleteResponse = restHighLevelClient.delete(deleteRequest, RequestOptions.DEFAULT);
            } catch (java.io.IOException e) {
                e.getLocalizedMessage();
            }
        }
```
我们根据传入的id来删除相应的文档。当然我们也可以做查询删除。

 
## 运行我们的应用

让我们通过执行上面提到的所有操作来尝试我们的应用程序。 由于这是一个普通的Java应用程序，我们将调用这些方法中的每一个并打印操作结果：
```
       public static void main(String[] args) throws IOException {
     
            makeConnection();
     
            Person person = new Person();
            person.setName("张三");
            System.out.println("Inserting a new Person with name " + person.getName());
            person.setNumber("111111");
            person = insertPerson(person);
            System.out.println("Person inserted --> " + person);
     
     
            person = new Person();
            person.setName("姚明");
            System.out.println("Inserting a new Person with name " + person.getName());
            person.setNumber("222222");
            person = insertPerson(person);
            System.out.println("Person inserted --> " + person);
     
     
            person.setName("李四");
            System.out.println("Changing name to " + person.getName());
            updatePersonById(person.getPersonId(), person);
            System.out.println("Person updated  --> " + person);
     
     
            System.out.println("Searching for all documents");
            SearchResponse response = searchAll();
            System.out.println(response);
     
            System.out.println("Searching for a term");
            response = searchTerm();
            System.out.println(response);
     
            System.out.println("Match a query");
            response = matchQuery();
            System.out.println(response);
     
            System.out.println("Getting 李四");
            Person personFromDB = getPersonById(person.getPersonId());
            System.out.println("Person from DB  --> " + personFromDB);
     
     
            
            System.out.println("Deleting " + person.getName());
            deletePersonById(personFromDB.getPersonId());
            System.out.println("Person " + person.getName() + " deleted!");
     
     
            closeConnection();
        }
```
运行的结果如下：
```
    Inserting a new Person with name 张三
    Person inserted --> Person{personId='33f4162e-0a68-4e66-8717-851516272185', name='张三', number='111111}
    Inserting a new Person with name 姚明
    Person inserted --> Person{personId='9b477529-6e79-42e8-a50a-21b2d8bc4c13', name='姚明', number='222222}
    Changing name to 李四
    Person updated  --> Person{personId='9b477529-6e79-42e8-a50a-21b2d8bc4c13', name='李四', number='222222}
    Searching for all documents
    {"took":0,"timed_out":false,"_shards":{"total":1,"successful":1,"skipped":0,"failed":0},"hits":{"total":{"value":4,"relation":"eq"},"max_score":1.0,"hits":[{"_index":"persondata","_type":"_doc","_id":"52425a44-dc06-49ca-b3df-26a8b341391c","_score":1.0,"_source":{"number":"111111","name":"张三"}},{"_index":"persondata","_type":"_doc","_id":"c76b8670-ed00-4212-b47b-46bc85d588b6","_score":1.0,"_source":{"number":"111111","name":"张三"}},{"_index":"persondata","_type":"_doc","_id":"b8bf0466-0ea5-43e0-8188-c0712812fb9a","_score":1.0,"_source":{"number":"111111","name":"张三"}},{"_index":"persondata","_type":"_doc","_id":"468dabe4-8f50-4667-a165-9ce6e015cb76","_score":1.0,"_source":{"number":"222222","name":"李四","personId":"468dabe4-8f50-4667-a165-9ce6e015cb76"}}]}}
    Searching for a term
    {"took":0,"timed_out":false,"_shards":{"total":1,"successful":1,"skipped":0,"failed":0},"hits":{"total":{"value":3,"relation":"eq"},"max_score":0.9444616,"hits":[{"_index":"persondata","_type":"_doc","_id":"52425a44-dc06-49ca-b3df-26a8b341391c","_score":0.9444616,"_source":{"number":"111111","name":"张三"}},{"_index":"persondata","_type":"_doc","_id":"c76b8670-ed00-4212-b47b-46bc85d588b6","_score":0.9444616,"_source":{"number":"111111","name":"张三"}},{"_index":"persondata","_type":"_doc","_id":"b8bf0466-0ea5-43e0-8188-c0712812fb9a","_score":0.9444616,"_source":{"number":"111111","name":"张三"}}]}}
    Match a query
    {"took":0,"timed_out":false,"_shards":{"total":1,"successful":1,"skipped":0,"failed":0},"hits":{"total":{"value":3,"relation":"eq"},"max_score":1.8889232,"hits":[{"_index":"persondata","_type":"_doc","_id":"52425a44-dc06-49ca-b3df-26a8b341391c","_score":1.8889232,"_source":{"number":"111111","name":"张三"}},{"_index":"persondata","_type":"_doc","_id":"c76b8670-ed00-4212-b47b-46bc85d588b6","_score":1.8889232,"_source":{"number":"111111","name":"张三"}},{"_index":"persondata","_type":"_doc","_id":"b8bf0466-0ea5-43e0-8188-c0712812fb9a","_score":1.8889232,"_source":{"number":"111111","name":"张三"}}]}}
    Getting 李四
    Person from DB  --> Person{personId='9b477529-6e79-42e8-a50a-21b2d8bc4c13', name='李四', number='222222}
```
整个项目的源码可以在地址找到：https://github.com/liu-xiao-guo/elastic-java

更多资料：

【1】使用RestHighLevelClient时单个索引速度很慢(https://discuss.elastic.co/t/resthighlevelclient/170293)
