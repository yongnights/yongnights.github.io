我们可以通过在命令行中对我们的Beats进行管理，比如我们可以启动metric几个模块，我们可以通过如下的命令来执行：
```
./metricbeat modules enable apache mysql
```

上面的命令启动apache mysql模块。我们也许觉得这个这样做很方便。但是如果我相对许多的机器（比如几千部机器）来做这样的管理，可能也很麻烦，这是因为我们需要到每一台机器上重复做同样的动作。如果我们需要有改动的话，那么需要对每一台机器再次执行同样的操作。那么有什么办法可以帮助我们减少这个工作量呢？

Elastic在Kibana中做进去一个新的功能：集中管理。Beats中央管理使用一种称为配置标签的机制来对相关配置进行分组。 注册第一个Beat后，您可以在Kibana的中央管理UI中定义配置标签。

Beats集中管理是6.5版带来的功能。 出于安全考虑，此功能在Elastic Gold许可证或使用我们的Elastic Cloud服务的Standard许可证下可用，以确保正确保护部署。 它包含Kibana中新的Beats中央管理UI，并利用Elasticsearch作为集中式配置存储。 在不久的将来，我们还计划公开一个API，以便更轻松地与外部工具和系统集成。

![](https://img-blog.csdnimg.cn/20191130115026583.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

下面我来展示如何使用Beats的集中管理。

# 准备工作

就像我上面提到的，我们必须购买Elastic Gold才可以拥有这样的功能。为了测试这个功能，我们可以接受30天尝试，这样我们就可以开始我们的测试了。

![](https://img-blog.csdnimg.cn/20191130115853698.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们首先点击Kibana中的Management，让后选择30天尝试。当我们接受完条件后，我们可以看到：

![](https://img-blog.csdnimg.cn/20191130120041777.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

大家一定可以看到左边的列表会多了一个叫做Beats的种类，并在其下面有一个叫做Central Management的项。我们点击Central Management：

![](https://img-blog.csdnimg.cn/2019113012025348.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

它显示我们的安全没有打开，也就是说，这个功能必须配合安全功能才能启用。我们参照我之前的文章“Elasticsearch：设置Elastic账户安全”来启动安全功能。我们使用elastic账号进行登录：

![](https://img-blog.csdnimg.cn/20191130120719739.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们可以看到一个对话框，提示我们Enroll Beat。点击这个按钮。
![](https://img-blog.csdnimg.cn/20191130120839756.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

目前我们看到有两个Beats：Filebeat及Metricbeat可以供我们来选择。我们来选择Metricbeat来做一些实验。同时在Platform中选择自己喜欢的平台：

![](https://img-blog.csdnimg.cn/20191130121032721.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

针对我们的情况，我选择MacOS。

由于需要使用到Metricbeat，需要安装我们的Metribeat。同时在我们的Terminal中打入从Copy Command处拷贝来的命令：

![](https://img-blog.csdnimg.cn/20191130121415650.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

这个时候在我们的Kibana中会显示：

![](https://img-blog.csdnimg.cn/20191130121522312.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

在上面显示了我的hostname以及metricbeat的版本信息。我们接下来选择Continue按钮：

![](https://img-blog.csdnimg.cn/20191130122305263.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们可以选一个我们喜欢的Tag Name和自己喜欢的颜色。在上面我选择了Local表明我的这个Metricbeat是在本地运行的。这样以后我们能很容易地找到我们的这个机器的配置。我们点击Add configuration block按钮：

![](https://img-blog.csdnimg.cn/20191130122650420.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们可以选择我们的模块，并选择喜欢额module。最后选择Save按钮。再接着选择Save & Continue按钮：
![](https://img-blog.csdnimg.cn/20191130122856493.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

最终我们完成了：

![](https://img-blog.csdnimg.cn/20191130122927238.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

在上面的画面中选择Done：

![](https://img-blog.csdnimg.cn/20191130123001323.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们可以看出来我们已经成功地配置好我们的Metricbeat模块了。上面显示Config Status是Offline状态。我们可以在我们的Terminal中打入如下的命令（在Metricbeat的安装目录中）：
```
./metricbeat run
```
![](https://img-blog.csdnimg.cn/20191130123226560.png)


我们再重新刷新我们的Kibana界面：

![](https://img-blog.csdnimg.cn/20191130123349914.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

从上面我们可以看出来我们的metricbeat已经在成功运行了。当然我们也可以找到相应的index。按照同样的方法，我们可以对其它的模块来进行配置。

我们接下来需要点击我们的Tags来添加或配置我们的Beats:

![](https://img-blog.csdnimg.cn/20191130123349914.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们可以点击Add configuration block来添加同一个Beat模块里的其它模块，或者增加一个输出到Elasticsearch：

![](https://img-blog.csdnimg.cn/20191206135601592.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

针对你的设置你需要修个这个hosts的地址。这样，我们的filebeat的输出就会发送到我们的Elasticsearch中了。我们也可以按照同样的方法来添加另外一个module。

参考：
【1】https://www.elastic.co/guide/en/beats/filebeat/current/how-central-managment-works.html
【2】https://www.elastic.co/blog/introducing-beats-central-management-in-the-elastic-stack