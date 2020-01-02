---
title: Elasticsearch：用户安全设置
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
Elastic Stack的组件是不安全的，因为它没有内置的固有安全性。 这意味着任何人都可以访问它。 在生产环境中运行Elastic Stack时，这会带来安全风险。 为了防止生产中未经授权的访问，采用了不同的机制来施加安全性，例如在防火墙后运行Elastic Stack并通过反向代理（例如nginx，HAProxy等）进行保护。 Elastic提供商业产品来保护Elastic Stack。 此产品是X-Pack的一部分，模块称为安全性。

在今天的文章中，我们来讲述如何为我们的Elastics索引设置字段级的安全。这样有的字段对有些用户是可见的，而对另外一些用户是不可见的。我们也可以通过对用户安全的设置，使得不同的用户有不同的权限。

# User authentication

在X-Pack安全性中，安全资源是基于用户的安全性的基础。 安全资源是需要访问以执行Elasticsearch集群操作的资源，例如索引，文档或字段。 X-Pack安全性通过分配给用户的角色的权限来实现。 权限是针对受保护资源的一项或多项特权。 特权是一个命名的组，代表用户可以针对安全资源执行的一个或多个操作。 用户可以具有一个或多个角色，并且用户拥有的总权限集定义为其所有角色的权限的并集，如下图所示：

![](https://img-blog.csdnimg.cn/20191029201921729.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

从上面的图上可以看出来：一个用户可以用多个role，而每个role可以对应多个permission(权限）。在接下来的练习中，我们来展示如何创建用户，role（角色）以及把permission分配到每个role。通过这样的组合，我们可以实现对字段级的安全控制。
 
# 为Elastic设置安全及创建用户

当我们设置完我们的安全账户后，最开始我们使用最原始的elastic的账号进行登录。请注意这里的密码是我们设置elastic账号的密码：

![](https://img-blog.csdnimg.cn/20190904225704187.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70

等登录进去之后，现在我们去Manage/Sercurity/Users页面：

![](https://img-blog.csdnimg.cn/20191029203231824.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

我们来创建一个新的账号。针对我的情况，我想创建一个叫做liuxg的用户名。点击当前页面的Create User按钮：

![](https://img-blog.csdnimg.cn/20191029203444267.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

然后填入我们所需要的信息：

![](https://img-blog.csdnimg.cn/20191029203635379.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

点击Create User按钮，这样我们就创建了我们的用户。

![](https://img-blog.csdnimg.cn/20191029203851749.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

按照同样的步骤，我们来创建另外一个叫做user1的用户。

![](https://img-blog.csdnimg.cn/20191029210507840.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

<escape><!-- more --></escape>

# 准备实验数据

在我们还没退出elastic用户的情况下，我们使用bulk API来把如下的文档输入到Elasticsearch中。
```
    POST employee/_bulk
    {"index":{"_index":"employee"}}
    {"name":"user1","email":"user1@packt.com","salary":5000,"gender":"M","address1":"312 Main St","address2":"Walthill","state":"NE"}
    {"index":{"_index":"employee"}}
    {"name":"user2","email":"user2@packt.com","salary":10000,"gender":"F","address1":"5658 N Denver Ave","address2":"Portland","state":"OR"}
    {"index":{"_index":"employee"}}
    {"name":"user3","email":"user3@packt.com","salary":7000,"gender":"F","address1":"300 Quinterra Ln","address2":"Danville","state":"CA"}
```
这样我们把三个文档存入到employee的索引之中。

![](https://img-blog.csdnimg.cn/2019102920464746.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

# 创建新的role

请注意：如下的操作是在elastic用户登录的情况下进行操作的。要创建新用户，请导航到管理UI并在“Security”部分中选择“role”，或者如果您当前在“Users”屏幕上，请单击“Roles”选项。 角色屏幕显示所有已定义/可用的角色:

![](https://img-blog.csdnimg.cn/20191029205112878.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

当我们点击roles后：

![](https://img-blog.csdnimg.cn/20191029205247461.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

我们点击Create role按钮。

![](https://img-blog.csdnimg.cn/20191029205851167.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

在这里，我们定义了一个叫做monitor_role，它具有monitor的权限。

# 把role赋予给用户

我们打开我们的用户列表。针对我的情况，我们打开liuxg用户：

![](https://img-blog.csdnimg.cn/20191029210949632.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

我们修改liuxg账号的Roles。把刚才创建的monitor_role赋予给liuxg用户。点击Update User按钮。这样我们的设定就好了。设定好的账号是这样的：

![](https://img-blog.csdnimg.cn/20191029211355958.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

从上面，我们可以看出来liuxg账号是有monitor_role的，而user1账号是没有的。

下面我们来做一些基本的测试。我们在一个terminal中打入如下的命令：
```
curl -u liuxg:123456 "http://localhost:9200/_cluster/health?pretty"
```
注意这里的123456是liuxg的账号密码。执行上面的显示结果是：

![](https://img-blog.csdnimg.cn/20191029211635602.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

我们显然看到了结果。那么我们同样地对use1账号来进行实验：
```
curl -u user1:123456 "http://localhost:9200/_cluster/health?pretty"
```
显示的结果是：

![](https://img-blog.csdnimg.cn/2019102921182037.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

显然，user1账号没有得到任何结果。这个根本的原因是因为这个账号没有相应的权限。

# 文档级或字段级安全

现在，我们知道了如何创建新用户，创建新角色以及将角色分配给用户，让我们探讨如何针对给定的索引/文档对文档和字段施加安全性。接下来，我们使用我之前给大家输入进的employee索引来展示。

## 案例1

当用户搜索员工详细信息时，该用户不允许包含在属于员工索引的文档中的薪水/地址详细信息。这就是我们所说的字段级安全。首先，让我们来创建一个叫做employee_read的role。这个role只具有employ索引的read权限。为了限制字段，我们可以在设置里做相应的配置：

![](https://img-blog.csdnimg.cn/20191029214107211.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

我们只允许这个employee_read role访问gender，state及email字段，而且只有read权限。

运用我们刚才设置的employee_read role，我们赋予给我们的user1用户：

![](https://img-blog.csdnimg.cn/20191029213513584.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

设置好的用户界面为：

![] (https://img-blog.csdnimg.cn/20191029213613951.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

上面显示我们的user1具有employ_read的role。

在我们的一个terminal里打入如下的命令：
```
curl -u user1:123456 "http://localhost:9200/employee/_search?pretty"
```
请注意：这里的123456是user1用户的密码。上面命令显示的结果为：

![](https://img-blog.csdnimg.cn/20191029214204836.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

显然，user1只能访问在employee_read中的三个字段。

## 案例2

我们想定义一个role。这个role具有read的权限，并且只能访问state为OR的那些文档。我们做一下的设置：

![](https://img-blog.csdnimg.cn/20191029215306635.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

我们创建了一个叫做OR_state的role。它通过一个query:
```
{"match": {"state.keyword":"OR"}}
```
来匹配项对应的文档。我们接着把这个role赋予给liuxg用户：

![](https://img-blog.csdnimg.cn/20191029215538433.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

在我们设置完后，我们接着在一个terminal中打入如下的命令：
```
curl -u liuxg:123456 "http://localhost:9200/employee/_search?pretty"
```
显示的结果：

![](https://img-blog.csdnimg.cn/20191029215722709.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

我们可以看出来这次的显示的结果只有一个，而且这个文档的state是OR。
