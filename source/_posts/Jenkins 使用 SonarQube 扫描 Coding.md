---
title: Jenkins 使用 SonarQube 扫描 Coding 
top: 
date: 
tags: 
- Jenkins
- SonarQube 
categories: 
- Jenkins
- SonarQube 
password: 
---
系统环境：
- Jenkins 版本：2.176
- SonarQube 版本：7.4.0

# 一、SonarQube 介绍
## 1、SonarQube 简介

SonarQube 是一个用于代码质量管理的开源平台，用于管理源代码的质量。同时 SonarQube 还对大量的持续集成工具提供了接口支持，可以很方便地在持续集成中使用 SonarQube。此外， SonarQube 的插件还可以对 Java 以外的其他编程语言提供支持，对国际化以及报告文档化也有良好的支持。
## 2、SonarQube工作原理

SonarQube 并不是简单地将各种质量检测工具的结果直接展现给客户，而是通过不同的插件算法来对这些结果进行再加工，最终以量化的方式来衡量代码质量，从而方便地对不同规模和种类的工程进行相应的代码质量管理。
## 3、SonarQube 特性

    多语言的平台： 支持超过20种编程语言，包括Java、Python、C#、C/C++、JavaScript等常用语言。
    自定义规则： 用户可根据不同项目自定义Quality Profile以及Quality Gates。
    丰富的插件： SonarQube 拥有丰富的插件，从而拥有强大的可扩展性。
    持续集成： 通过对某项目的持续扫描，可以对该项目的代码质量做长期的把控，并且预防新增代码中的不严谨和冗余。
    质量门： 在扫描代码后可以通过对“质量门”的比对判定此次“构建”的结果是否通过，质量门可以由用户定义，由多维度判定是否通过。

## 4、需要注意的代码质量问题

    (1)、不遵循代码标准： SonarQube可以通过PMD,CheckStyle,Findbugs等等代码规则检测工具规 范代码编写。
    (2)、糟糕的复杂度分布： 文件、类、方法等，如果复杂度过高将难以改变，这会使得开发人员难以理解它们且如果没有自动化的单元测试，对于程序中的任何组件的改变都将可能导致需要全面的回归测试。
    (3)、注释不足或者过多： 没有注释将使代码可读性变差，特别是当不可避免地出现人员变动 时，程序的可读性将大幅下降而过多的注释又会使得开发人员将精力过多地花费在阅读注释上，亦违背初衷。
    (4)、缺乏单元测试： SonarQube 可以很方便地统计并展示单元测试覆盖率。
    (5)、潜在的缺陷： –SonarQube 可以通过PMD,CheckStyle,Findbugs等等代码规则检测工具检 测出潜在的缺陷。
    (6)、重复： 显然程序中包含大量复制粘贴的代码是质量低下的，SonarQube 源码中重复严重的地方。
    (7)、糟糕的设计

<escape><!-- more --></escape>

# 二、一般执行流程

在项目中一般流程为：

    (1)、项目人员开发代码。
    (2)、将代码推送到持久化仓库，如 Git。
    (3)、Jenkins 进行代码拉取，然后利用 SonarQube 扫描器进行扫描分析代码信息。
    (4)、将分析结果等信息上传至 SonarQube Server 服务器进行分类处理。
    (5)、SonarQube 将分析结果等信息持久化到数据库，如 Mysql。
    (6)、开发人员访问 SonarQube UI 界面访问，查看扫描出的结果信息进行项目优化。

这里只描述 Jenkins 如何与 SonarQube 集成

    执行过程流程图
![](/Jenkins_SonarQube/jenkins-sona-1002.jpg)

# 三、SonarQuke 配置
## 1、禁用SCM传感器

    点击 配置—SCM—Disable the SCM Sensor 将其关闭。
![](/Jenkins_SonarQube/jenkins-sona-1003.jpg)
## 2、安装 JAVA 分析插件

由于这里要分析的项目是 JAVA 项目，所以需要确保安装 Java 语言分析插件，如果是别的类型的项目，可以类似安装相关分析插件即可。

- 点击 配置—应用市场—插件 搜索 SonarJava 插件安装

> 如果忘记安装，可能会导致 Jenkins 编译过程中提示没有语言插件的异常错误信息,确保一定要安装。
![](/Jenkins_SonarQube/jenkins-sona-1004.jpg)
## 3、生成 Token

这里生成验证用的 Token 字符串，用于 Jenkins 在执行流水线时候将待检测信息发送到 SonarQube 时候用于的安全验证。

- 点击 头像—我的账号—安全—生成令牌 生成验证的 Token。

> 因为此 Token 不会显示第二次，所以这里记住此 Token。
![](/Jenkins_SonarQube/jenkins-sona-1005.jpg)
# 四、Jenkins 安装插件
## 1、需要安装的插件介绍

Jenkins 先提前安装好可能需要用到的插件，这里需要用到一下插件：

- Maven Integration

Maven 插件，用于编译 Maven 项目和安装 Maven 工具到任务中。

- Pipeline Utility Steps

> 参考：https://jenkins.io/doc/pipeline/steps/pipeline-utility-steps/

用于在 Pipeline 执行过程中操作文件“读/写”的插件，这里用其创建 Sonar properties 配置文件。

- SonarQube Scanner

> 参考：https://docs.sonarqube.org/display/SCAN/Analyzing+with+SonarQube+Scanner+for+Jenkins

SonarQube 是一种用于连续检查代码质量的开源平台，该插件可轻松与 SonarQube 集成。
## 2、安装 SonarQube Scanner 插件

打开 系统管理—插件管理—可选插件 输入 sonarqube 进行插件筛选，如下如方式进行安装。
![](/Jenkins_SonarQube/jenkins-sona-1006.jpg)
关于安装 Pipeline Utility Steps 与 Maven Integration 插件和上面类似，请自行安装即可，这里不过多描述。
# 五、Jenkins 配置插件
## 1、连接 SonarQube 配置

打开 系统管理—系统设置—SonarQube servers 配置下面属性
![](/Jenkins_SonarQube/jenkins-sona-1007.jpg)
参数说明：

- Name： 用于 Jenklins Pipeline 中构建环境指定的名称，在 Pipeline 脚本中会用到，自定义即可。
- Server URL： SonarQube 地址。
- Server authentication token： 用于连接 SonarQube 的 Token，将上面 SonarQube 中生成的 Token 输入即可。

## 2、配置 SonarQube Scanner 插件

打开 系统管理—全局工具配置—SonarQube Scanner 输入 Name，选择最新版本点击自动安装即可
![](/Jenkins_SonarQube/jenkins-sona-1008.jpg)
## 3、配置 Maven 插件

打开 系统管理—全局工具配置—Maven 输入 Name，选择最新版本点击自动安装即可
![](/Jenkins_SonarQube/jenkins-sona-1009.jpg)
# 六、创建流水线项目写 Pipeline 脚本
## 1、创建流水线任务
![](/Jenkins_SonarQube/jenkins-sona-1010.jpg)
## 2、设置 SonarQube 配置文件
(1)、Sonar 配置文件说明

在使用 SonarQube 来进行代码扫描时候需要一个名称为 sonar-project.properties 的配置文件。该文件设置了项目的一些属性用于 SonarQube 扫描的属性。

例如，设置项目在 Sonar 面板中的唯一标识 Key，项目名称及其版本，要扫描项目的语言类型等等。

> sonar-project.properties
```
sonar.projectKey=key:value
sonar.projectName=ProjectName
sonar.projectVersion=1.0.0
sonar.sources=src
sonar.language=java
sonar.sourceEncoding=UTF-8
sonar.java.binaries=target/classes
sonar.java.source=1.8
sonar.java.target=1.8
```
配置参数：

- sonar.projectKey： 项目在 SonarQube 的唯一标识，不能重复
- sonar.projectName=ProjectName： 项目名称
- sonar.projectVersion： 项目版本
- sonar.language： 项目语言，例如 Java、C#、PHP 等
- sonar.sourceEncoding： 编码方式
- sonar.sources： 项目源代码目录
- sonar.java.binaries： 编译后 class 文件目录

(2)、Sonar 配置文件存放位置

这个文件可以放在源代码根目录中，也可是设置到 Jenkins 变量。

① ————————方式一：放置到源代码———————————————–

直接在源代码中放置文件 sonar-project.properties，然后在此配置文件中设置这些配置参数。
![](/Jenkins_SonarQube/jenkins-sona-1011.jpg)
② ————————方式二：设置到变量并在 Jenkins 编译时候创建————————

可以设置文本到环境变量中，在变量文本中设置哪些配置参数，之后在执行 Pipeline 脚本时候利用 “Pipeline Utility Steps” 插件的创建文件方法创建 sonar-project.properties 文件。

在 Jenkins sonar-qube-coding 任务—>配置—>参数化构建过程—>添加参数—>文本参数 输入 Sonar 配置。

- 变量名称：sonar_project_properties
- 变量内容：
```
sonar.sources=src
sonar.language=java
sonar.sourceEncoding=UTF-8
sonar.java.binaries=target/classes
sonar.java.source=1.8
sonar.java.target=1.8
```
> 注意:这里不设置 sonar.projectKey、sonar.projectName、sonar.projectVersion 这三个参数，将三个参数在执行 Pipeline 脚本的时候设置。
![](/Jenkins_SonarQube/jenkins-sona-1012.jpg)
这里为了配置更灵活方便，所以采用将 SonarQube 配置设置到环境变量
## 3、创建 Pipeline 脚本

配置 Jenkins 任务，创建脚本并加入到 “流水线” 配置项中
```
// 设置超时时间为10分钟，如果未成功则结束任务
timeout(time: 600, unit: 'SECONDS') {
    node () {
        stage('Git 拉取阶段'){
            // Git 拉取代码
            git branch: "master" ,changelog: true , url: "https://github.com/a324670547/springboot-helloworld"
        }
        stage('Maven 编译阶段') {
            // 设置 Maven 工具,引用先前全局工具配置中设置工具的名称
            def m3 = tool name: 'maven'
            // 执行 Maven 命令
            sh "${m3}/bin/mvn -B -e clean install -Dmaven.test.skip=true"
        }
        stage('SonarQube 扫描阶段'){
            // 读取maven变量
            pom = readMavenPom file: "./pom.xml"
            // 创建SonarQube配置文件
            writeFile file: 'sonar-project.properties', 
                      text: """sonar.projectKey=${pom.artifactId}:${pom.version}\n"""+
                            """sonar.projectName=${pom.artifactId}\n"""+
                            """sonar.projectVersion=${pom.version}\n"""+
                            """${sonar_project_properties}"""
            // 设置 SonarQube 代码扫描工具,引用先前全局工具配置中设置工具的名称
            def sonarqubeScanner = tool name: 'sonar-scanner'
            // 设置 SonarQube 环境,其中参数设置为之前系统设置中SonarQuke服务器配置的 Name
            withSonarQubeEnv('jenkins') {
                // 执行代码扫描
                sh "${sonarqubeScanner}/bin/sonar-scanner"
            }
        }
    }
}
```
![](/Jenkins_SonarQube/jenkins-sona-1013.jpg)
# 七、执行 Jenkins 任务
## 1、执行 Jenkins Pipeline 任务

点击 Build with Parameters 执行 Jenkins 任务
![](/Jenkins_SonarQube/jenkins-sona-1014.jpg)
## 2、查看任务执行日志

查看日志信息为：
```
......
[Pipeline] { (Git 拉取阶段)
[Pipeline] echo
Git 阶段
 > git rev-parse --is-inside-work-tree # timeout=10
Fetching changes from the remote Git repository
 > git config remote.origin.url https://github.com/a324670547/springboot-helloworld # timeout=10
Fetching upstream changes from https://github.com/a324670547/springboot-helloworld
 > git --version # timeout=10
 > git fetch --tags --progress https://github.com/a324670547/springboot-helloworld 
Commit message: "修改jenkinsfile"
 > git rev-list --no-walk a34691106075d58bc99d9dcc06f5eadcc03ca759 # timeout=10
[Pipeline] { (Maven 编译阶段)
[Pipeline] tool
+ /var/jenkins_home/tools/hudson.tasks.Maven_MavenInstallation/maven/bin/mvn -B -e clean install -Dmaven.test.skip=true
[INFO] Error stacktraces are turned on.
[INFO] Scanning for projects...
[INFO] 
[INFO] ------------------< club.mydlq:springboot-helloworld >------------------
[INFO] Building springboot-helloworld 0.0.1
[INFO] --------------------------------[ jar ]---------------------------------
[INFO] 
[INFO] --- maven-clean-plugin:3.1.0:clean (default-clean) @ springboot-helloworld ---
[INFO] Deleting /var/jenkins_home/workspace/sonar-qube-coding/target
[INFO] 
[INFO] --- maven-resources-plugin:3.1.0:resources (default-resources) @ springboot-helloworld ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] Copying 1 resource
[INFO] Copying 0 resource
[INFO] 
[INFO] --- maven-compiler-plugin:3.8.0:compile (default-compile) @ springboot-helloworld ---
[INFO] Changes detected - recompiling the module!
[INFO] Compiling 2 source files to /var/jenkins_home/workspace/sonar-qube-coding/target/classes
[INFO] 
[INFO] --- maven-resources-plugin:3.1.0:testResources (default-testResources) @ springboot-helloworld ---
[INFO] Not copying test resources
[INFO] 
[INFO] --- maven-compiler-plugin:3.8.0:testCompile (default-testCompile) @ springboot-helloworld ---
[INFO] Not compiling test sources
[INFO] 
[INFO] --- maven-surefire-plugin:2.22.1:test (default-test) @ springboot-helloworld ---
[INFO] Tests are skipped.
[INFO] 
[INFO] --- maven-jar-plugin:3.1.1:jar (default-jar) @ springboot-helloworld ---
[INFO] Building jar: /var/jenkins_home/workspace/sonar-qube-coding/target/springboot-helloworld-0.0.1.jar
[INFO] 
[INFO] --- spring-boot-maven-plugin:2.1.4.RELEASE:repackage (repackage) @ springboot-helloworld ---
[INFO] Replacing main artifact with repackaged archive
[INFO] 
[INFO] --- maven-install-plugin:2.5.2:install (default-install) @ springboot-helloworld ---
[INFO] Installing /var/jenkins_home/workspace/sonar-qube-coding/target/springboot-helloworld-0.0.1.jar to /root/.m2/repository/club/mydlq/springboot-helloworld/0.0.1/springboot-helloworld-0.0.1.jar
[INFO] Installing /var/jenkins_home/workspace/sonar-qube-coding/pom.xml to /root/.m2/repository/club/mydlq/springboot-helloworld/0.0.1/springboot-helloworld-0.0.1.pom
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  3.695 s
[INFO] Finished at: 2019-05-09T17:59:45Z
[INFO] ------------------------------------------------------------------------
[Pipeline] }
[Pipeline] { (SonarQube 扫描阶段)
[Pipeline] readMavenPom
[Pipeline] writeFile
[Pipeline] tool
[Pipeline] withSonarQubeEnv
Injecting SonarQube environment variables using the configuration: jenkins
[Pipeline] {
[Pipeline] sh
+ /var/jenkins_home/tools/hudson.plugins.sonar.SonarRunnerInstallation/sonar-scanner/bin/sonar-scanner
INFO: Scanner configuration file: /var/jenkins_home/tools/hudson.plugins.sonar.SonarRunnerInstallation/sonar-scanner/conf/sonar-scanner.properties
INFO: Project root configuration file: /var/jenkins_home/workspace/sonar-qube-coding/sonar-project.properties
INFO: SonarQube Scanner 3.3.0.1492
INFO: Java 1.8.0_212 Oracle Corporation (64-bit)
INFO: Linux 3.10.0-957.1.3.el7.x86_64 amd64
INFO: User cache: /root/.sonar/cache
INFO: SonarQube server 7.4.0
INFO: Default locale: "en", source code encoding: "UTF-8"
INFO: Publish mode
INFO: Load global settings
INFO: Load global settings (done) | time=89ms
INFO: Server id: D549D2A8-AWpYoogtP1ytl0VN9Fsr
INFO: User cache: /root/.sonar/cache
INFO: Load/download plugins
INFO: Load plugins index
INFO: Load plugins index (done) | time=31ms
INFO: Plugin [l10nzh] defines 'l10nen' as base plugin. This metadata can be removed from manifest of l10n plugins since version 5.2.
INFO: Load/download plugins (done) | time=38ms
INFO: Loaded core extensions: 
INFO: Process project properties
INFO: Load project repositories
INFO: Load project repositories (done) | time=11ms
INFO: Load quality profiles
INFO: Load quality profiles (done) | time=32ms
INFO: Load active rules
INFO: Load active rules (done) | time=201ms
INFO: Load metrics repository
INFO: Load metrics repository (done) | time=24ms
INFO: Project key: springboot-helloworld:0.0.1
INFO: Project base dir: /var/jenkins_home/workspace/sonar-qube-coding
INFO: -------------  Scan springboot-helloworld
INFO: Base dir: /var/jenkins_home/workspace/sonar-qube-coding
INFO: Working dir: /var/jenkins_home/workspace/sonar-qube-coding/.scannerwork
INFO: Source paths: src
INFO: Source encoding: UTF-8, default locale: en
INFO: Load server rules
INFO: Load server rules (done) | time=109ms
INFO: Language is forced to java
INFO: Index files
WARN: File '/var/jenkins_home/workspace/sonar-qube-coding/src/main/resources/application.yaml' is ignored because it doesn't belong to the forced language 'java'
INFO: 2 files indexed
INFO: Quality profile for java: Sonar way
INFO: Sensor JavaSquidSensor [java]
INFO: Configured Java source version (sonar.java.source): 8
INFO: JavaClasspath initialization
WARN: Bytecode of dependencies was not provided for analysis of source files, you might end up with less precise results. Bytecode can be provided using sonar.java.libraries property.
INFO: JavaClasspath initialization (done) | time=8ms
INFO: JavaTestClasspath initialization
INFO: JavaTestClasspath initialization (done) | time=0ms
INFO: Java Main Files AST scan
INFO: 2 source files to be analyzed
INFO: 2/2 source files have been analyzed
INFO: Java Main Files AST scan (done) | time=609ms
INFO: Java Test Files AST scan
INFO: 0 source files to be analyzed
INFO: Java Test Files AST scan (done) | time=1ms
INFO: Sensor JavaSquidSensor [java] (done) | time=1334ms
INFO: Sensor SurefireSensor [java]
INFO: 0/0 source files have been analyzed
INFO: parsing [/var/jenkins_home/workspace/sonar-qube-coding/target/surefire-reports]
INFO: Sensor SurefireSensor [java] (done) | time=55ms
INFO: Sensor JaCoCoSensor [java]
INFO: Sensor JaCoCoSensor [java] (done) | time=2ms
INFO: Sensor JavaXmlSensor [java]
INFO: Sensor JavaXmlSensor [java] (done) | time=0ms
INFO: Sensor Zero Coverage Sensor
INFO: Sensor Zero Coverage Sensor (done) | time=8ms
INFO: Sensor Java CPD Block Indexer
INFO: Sensor Java CPD Block Indexer (done) | time=10ms
INFO: SCM Publisher is disabled
INFO: 2 files had no CPD blocks
INFO: Calculating CPD for 0 files
INFO: CPD calculation finished
INFO: Analysis report generated in 114ms, dir size=13 KB
INFO: Analysis reports compressed in 39ms, zip size=6 KB
INFO: Analysis report uploaded in 671ms
INFO: ANALYSIS SUCCESSFUL, you can browse http://10.2.5.143:9000/dashboard?id=springboot-helloworld%3A0.0.1
INFO: Note that you will be able to access the updated dashboard once the server has processed the submitted analysis report
INFO: More about the report processing at http://10.2.5.143:9000/api/ce/task?id=AWqdwF0moB4s4osu4wHu
INFO: Task total time: 3.412 s
INFO: ------------------------------------------------------------------------
INFO: EXECUTION SUCCESS
INFO: ------------------------------------------------------------------------
INFO: Total time: 4.469s
INFO: Final Memory: 10M/158M
INFO: ------------------------------------------------------------------------
......
Finished: SUCCESS
```
八、SonarQube 查看代码扫描结果

登录 SonarQube 平台，查看代码扫描结果
![](/Jenkins_SonarQube/jenkins-sona-1015.jpg)

转载地址：http://www.mydlq.club/article/11/