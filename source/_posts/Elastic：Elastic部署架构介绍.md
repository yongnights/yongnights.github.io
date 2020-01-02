Elastic Stack是一套完整的从数据采集，解析，分析，丰富，到搜索，检索，数据程序等一套完整的软件栈。在具体的实践中，我们应该如何搭建我们的系统呢？

下图描述了常用的Elastic Stack的部署架构：

![](https://img-blog.csdnimg.cn/20191007140645639.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

该图描述了三种可能的体系结构：

- 将操作指标直接发送到Elasticsearch：如上图所示，您将在要从其发送操作指标/日志的边缘服务器上安装各种类型的Beats，例如Metricbeat，Filebeat，Packetbeat等。 如果不需要进一步处理，那么可以将生成的事件直接传送到Elasticsearch集群。 一旦数据出现在Elasticsearch中，就可以使用Kibana对其进行可视化/分析。 在这种体系结构中，事件流将是Beats→Elasticsearch→Kibana。当然如果您需要做进一步的处理，您也可以通过ingest node的pipleline帮助实现。
- 将操作指标发送到Logstash：Beats捕获并安装在边缘服务器上的操作指标/日志将发送到Logstash进行进一步处理，例如解析日志或丰富日志事件。 然后，已解析/丰富的事件被推送到Elasticsearch。 为了提高处理能力，您可以扩展Logstash实例，例如，通过配置一组Beats将数据发送到Logstash实例1，并配置另一组Beats将数据发送到Logstash实例2，依此类推。 在这种架构中，事件流将是Beats→Logstash→Elasticsearch→Kibana。
- 将操作指标发送到弹性队列：如果生成的事件发生率很高，并且Logstash停机时Logstash无法应付负载或防止数据/事件丢失，则可以使用诸如以下的弹性队列 Apache Kafka，以便将事件排队。 然后，Logstash可以以自己的速度处理它们，从而避免丢失Beats捕获的操作指标/日志。 在这种体系结构中，事件流将是Beats→Kafka→Logstash→Elasticsearch→Kibana。

提示：从Logstash 5.x开始，您可以使用Logstash的持久队列设置，也可以将其用作队列。 但是，它不像Kafka一样提供高度的弹性。

也有一些应用场景是这样部署的：

![](https://img-blog.csdnimg.cn/20191007141510790.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

同样的，在这里，我们可以通过radis或Kafaka来提供一个弹性队列来缓冲高发生率事件。

在实际的使用中，如果我们不把Elasticsearch当做唯一的数据库来存储的话，那么，我们可以采用如下的方案：

![](https://img-blog.csdnimg.cn/20191007141935354.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

在这种架构中，您有两个数据存储，必须找到一种使它们保持同步的方法。 根据您的主要数据存储区和数据布局方式，您可以部署Elasticsearch插件以使两个实体保持同步。

如下的是另外一中有外部数据，物联网等的一种架构：

![](https://img-blog.csdnimg.cn/20191127085346630.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

或者一个更加全面的架构图：

![](https://img-blog.csdnimg.cn/20191130110200909.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

在Elastic的官方文档中，有更多关于部署架构的描述。详细文档：https://www.elastic.co/assets/blt2614227bb99b9878/architecture-best-practices.pdf
