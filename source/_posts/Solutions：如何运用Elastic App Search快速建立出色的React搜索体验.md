---
title: Solutions：如何运用Elastic App Search快速建立出色的React搜索体验
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
建立搜索体验是一项艰苦的工作。 乍一看似乎很容易：建立一个搜索栏，将数据放入数据库，然后让用户输入对该数据库的查询。 但是，在数据建模，底层逻辑以及（当然）总体设计和用户体验方面，有很多事情要考虑。

我们将逐步介绍如何使用Elastic的开源Search UI库构建出色的基于React的搜索体验。 大约需要30分钟，然后您便可以将搜索带到需要它的任何应用程序中。

但是首先，是什么使创建搜索如此具有挑战性？

# 搜索是很难创建的

开发人员在搜索开发中采用许多错误的假设。比如许多相信的假设：
- “知道他们要寻找的客户将按照您期望的方式进行搜索。”
- “您可以编写一个查询解析器，该解析器将始终成功解析查询。”
- “一旦设置，下周搜索将以相同的方式进行。”
- “同义词很容易。”
- ...

得出的结论是，搜索面临许多挑战--而且这些挑战并不简单。 您需要考虑如何管理状态，构建用于过滤，构面，排序，分页，同义词，语言处理等等的组件，等等。 但是，总而言之：

建立出色的搜索需要两个复杂的部分：

(1)搜索引擎，它提供用于增强搜索功能的API
(2)搜索库，它描绘了搜索体验。

对于搜索引擎，我们将查看Elastic App Search。

为了获得搜索体验，我们将介绍一个操作系统搜索库：Search UI。

完成后，将如下所示。您也可以在地址(https://codesandbox.io/embed/happy-wilbur-hwzsh?view=preview&initialpath=%3Fq%3Dfinal%20fantasy)上进行在线体验。

<escape><!-- more --></escape>

# 搜索引擎: Elastic App Search

App Search可作为付费托管服务或免费的自助托管发行版(https://www.elastic.co/downloads/app-search?ultron=searchui-howto-react&blade=codeburst&hulk=content)提供。 我们将在本教程中使用托管服务，但是请记住，如果您自己托管，您的团队可以免费使用带有基本许可的Search UI和App Search。

计划：将代表有史以来最好的视频游戏的文档编入搜索引擎，然后设计和优化搜索体验以对其进行搜索。

首先，注册14天的试用期(https://www.elastic.co/products/app-search/service?ultron=searchui-howto-react&blade=codeburst&hulk=content)-无需信用卡。

创建一个引擎。 您可以选择13种不同的语言。

我们将其命名为video-games，并将语言设置为英语。

![](https://img-blog.csdnimg.cn/20191116192801149.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

下载最佳视频游戏数据集(https://drive.google.com/file/d/14-3wzemyLzJh6XHVUotFsdl0tZ7K2v1E/view)，然后使用导入程序将其上传到App Search。

![](https://img-blog.csdnimg.cn/20191116193301523.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

接下来，单击进入引擎，然后选择“Credentials”选项卡。

使用仅对video-games引擎具有Limited Engine Access的方式创建新的Public Search Key。

![](https://img-blog.csdnimg.cn/20191116193658823.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

![](https://img-blog.csdnimg.cn/20191116194536444.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们可以记下我们刚创建的Public Search Key及Host Indentifier以便下面之用。

尽管看起来我们目前做的并不多，但我们现在拥有功能全面的搜索引擎，可以使用完善的搜索API来搜索我们的视频游戏数据。

到目前为止，这是我们所做的：

- 创建了一个搜索引擎
- 建立了索引文档
- 创建一个默认的索引schema
- 创建了一个有限的可以用于外界访问的凭证（credential）

让我们开始使用“Search UI”来建立我们的搜索体验。

# 搜索库：Search UI

我们将使用create-react-app(https://github.com/facebook/create-react-app)脚手架实用程序创建一个React应用：
```
    npm install -g create-react-app
    create-react-app video-game-search --use-npm
    cd video-game-search
```
在此基础上，我们将安装Search UI和App Search连接器：
```
npm install --save @elastic/react-search-ui @elastic/search-ui-app-search-connector
```
并以开发模式启动该应用程序：
```
npm start
```
在您喜欢的文本编辑器中打开src/App.js

我们将从一些样板代码开始，注意评论部分！
```
    // Step #1, import statements
    import React from "react";
    import AppSearchAPIConnector from "@elastic/search-ui-app-search-connector";
    import { SearchProvider, Results, SearchBox } from "@elastic/react-search-ui";
    import { Layout } from "@elastic/react-search-ui-views";
    import "@elastic/react-search-ui-views/lib/styles/styles.css";
    // Step #2, The connector
    const connector = new AppSearchAPIConnector({
      searchKey: "[YOUR_SEARCH_KEY]",
      engineName: "video-games",
      hostIdentifier: "[YOUR_HOST_IDENTIFIER]"
    });
     
    // Step #3: Configuration options
    const configurationOptions = {
      apiConnector: connector
      // Let's fill this in together.
    };
     
    // Step #4, SearchProvider: The finishing touches
    export default function App() {
      return (
        <SearchProvider config={configurationOptions}>
          <div className="App">
            <Layout
            // Let's fill this in together.
            />
          </div>
        </SearchProvider>
      );
    }
```
## Step 1: 导入声明

我们需要导入我们的Search UI依赖关系和React。

核心组件，连接器和视图组件包含在三个不同的程序包中：
```
    @elastic/search-ui-app-search-connector
    @elastic/react-search-ui
    @elastic/react-search-ui-views
```
继续进行时，我们将详细了解它们
```
    import React from "react";
    import AppSearchAPIConnector from "@elastic/search-ui-app-search-connector";
    import { SearchProvider, Results, SearchBox } from "@elastic/react-search-ui";
    import { Layout } from "@elastic/react-search-ui-views";
```
我们还将为该项目导入默认样式表，这将使我们拥有良好的外观，而无需编写我们自己的CSS行：
```
import "@elastic/react-search-ui-views/lib/styles/styles.css";
```

## Step 2:  连接器

我们有来自App Search的Public Search Key和Host Identifier。

是时候让他们工作了！

Search UI中的连接器对象使用credentials连接到App Search和超级搜索：
```
    const connector = new AppSearchAPIConnector({
      searchKey: "[YOUR_SEARCH_KEY]",
      engineName: "video-games",
      hostIdentifier: "[YOUR_HOST_IDENTIFIER]"
    });
```
搜索用户界面可与任何搜索API配合使用。 但是通过连接器可以使搜索API正常工作，而无需进行任何更深入的配置。

## Step 3: configurationOptions

在深入探讨configurationOptions之前，让我们花点时间进行反思。

我们将一组数据导入了搜索引擎。 但是，它是什么样的数据？

我们对数据了解的越多，我们就会越了解如何将数据呈现给搜索者。 这样一来，您便可以了解如何配置搜索体验。

我们来看一个对象，这是该数据集中所有对象中的一个：
```
    { 
      "id":"final-fantasy-vii-ps-1997",
      "name":"Final Fantasy VII",
      "year":1997,
      "platform":"PS",
      "genre":"Role-Playing",
      "publisher":"Sony Computer Entertainment",
      "global_sales":9.72,
      "critic_score":92,
      "user_score":9,
      "developer":"SquareSoft",
      "image_url":"https://r.hswstatic.com/w_907/gif/finalfantasyvii-MAIN.jpg"
    }
```
我们看到它有几个文本字段，例如name，year，platform等等，还有一些数字字段，例如critic_score，global_sales和user_score。

如果我们提出三个关键问题，我们将足够了解，以提供扎实的搜索体验：

- 大多数人将如何搜索？ 以视频游戏的名称命名。
- 大多数人想要看到的结果是什么？ 视频游戏的名称，类型，发行商，得分和平台。
- 大多数人将如何过滤，排序和构面？ 按得分，体裁，发布者和平台分类。

然后，我们可以将这些答案转换为我们的configurationOptions：
```
    const configurationOptions = {
      apiConnector: connector,
      searchQuery: {
        search_fields: {
          // 1. Search by name of video game.
          name: {}
        },
        // 2. Results: name, genre, publisher, scores, and platform.
        result_fields: {
          name: {
            // A snippet means that matching search terms will be wrapped in <em> tags.
            snippet: {
              size: 75, // Limit the snippet to 75 characters.
              fallback: true // Fallback to a "raw" result.
            }
          },
          genre: {
            snippet: {
              size: 50,
              fallback: true
            }
          },
          publisher: {
            snippet: {
              size: 50,
              fallback: true
            }
          },
          critic_score: {
            // Scores are numeric, so we won't snippet.
            raw: {}
          },
          user_score: {
            raw: {}
          },
          platform: {
            snippet: {
              size: 50,
              fallback: true
            }
          },
          image_url: {
            raw: {}
          }
        },
        // 3. Facet by scores, genre, publisher, and platform, which we'll use to build filters later.
        facets: {
          user_score: {
            type: "range",
            ranges: [
              { from: 0, to: 5, name: "Not good" },
              { from: 5, to: 7, name: "Not bad" },
              { from: 7, to: 9, name: "Pretty good" },
              { from: 9, to: 10, name: "Must play!" }
            ]
          },
          critic_score: {
            type: "range",
            ranges: [
              { from: 0, to: 50, name: "Not good" },
              { from: 50, to: 70, name: "Not bad" },
              { from: 70, to: 90, name: "Pretty good" },
              { from: 90, to: 100, name: "Must play!" }
            ]
          },
          genre: { type: "value", size: 100 },
          publisher: { type: "value", size: 100 },
          platform: { type: "value", size: 100 }
        }
      }
    };
```
我们已经将Search UI连接到我们的搜索引擎，现在我们有一些选项可以控制我们如何搜索数据，显示结果并探索这些结果。 但是我们需要一些东西来将所有内容绑定到Search UI的动态前端组件。

## Step 4: SearchProvider

这是统治所有对象的对象。 SearchProvider是所有其他组件嵌套的地方。

Search UI提供了一个Layout组件，用于绘制典型的搜索布局。 有很深的自定义选项，但我们不会在本教程中介绍。

我们将做两件事：
1. 将configurationOptions传递给SearchProvider。
2. 将一些结构性构建基块放入Layout中，并添加两个基本组件：SearchBox和Results。
```
    export default function App() {
      return (
        <SearchProvider config={configurationOptions}>
          <div className="App">
            <Layout
              header={<SearchBox />}
              // titleField is the most prominent field within a result: the result header.
              bodyContent={<Results titleField="name" urlField="image_url" />}
            />
          </div>
        </SearchProvider>
      );
    }
```
至此，我们已经在前端建立了基础。 在运行此后端之前，还有一些其他细节需要在后端解决。 我们还应该研究相关性模型，以便针对该项目的独特需求微调搜索。


# 重新进入搜索平台

App Search具有强大且完善的搜索引擎功能。 它使曾经复杂的调优变得更加有趣。 只需单击几下，我们便可以进行细粒度的相关性调整和无缝的模式更改。

我们将首先调整schema以使其实际运行。

登录到App Search，输入video-games引擎，然后单击“Manage”部分下的“Schema”。

![](https://img-blog.csdnimg.cn/2019111620131166.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

出现架构。 默认情况下，这11个字段中的每一个均被视为文本。

在configurationOptions对象中，我们定义了两个范围构面来帮助我们搜索数字：user_score和critic_score。 为了使range facet按预期工作，字段类型必须为数字(number)。

![](https://img-blog.csdnimg.cn/2019111620153379.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

单击每个字段旁边的下拉菜单，将其更改为数字，然后单击“Update Types”。引擎会即时重新更新索引。 然后，当我们将构面（facet）组件添加到布局中时，范围过滤器将按预期运行。 现在，进入真正的漂亮东西。

## 下面的部分是高度相关的

具有三个关键的相关功能：Synonyms，Curations和Relevance Tuning。

![](https://img-blog.csdnimg.cn/20191116202037160.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

在边栏中的“Search Settings”部分下选择每个功能：

## Synonyms

世界各地的人们使用不同的词来形容事物。 同义词可帮助您创建被视为一个或一组相同的术语集。

就video game搜索引擎而言，我们知道人们会希望找到Final Fantasy。 但是也许他们会改用FF。

单击进入同义词，然后选择创建同义词集并输入术语：

![](https://img-blog.csdnimg.cn/20191116202424195.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

单击Save。 您可以根据需要添加任意多个同义词集。

现在，搜索FF与搜索Final Fantasy的权重相同。

## Curations
Curations是最最让人喜欢的。 如果有人搜索Final Fantasy或FF，该怎么办？ 系列赛中有很多游戏-他们会得到哪些？

默认情况下，前五个结果如下所示：

1.最终幻想VIII
2.最终幻想X
3.最终幻想策略
4.最终幻想IX
5.最终幻想XIII

这似乎不正确……Final Fantasy VII是所有游戏中最好的Final Fantasy游戏。 而且Final Fantasy XIII不是很好！ 😜

我们可以做到这一点，以便搜索Final Fantasy的人会收到Final Fantasy VII作为第一结果吗？ 我们可以从搜索结果中删除Final Fnatasy XIII吗？

我们可以！

单击“Curations”，然后输入查询：“Final Fantasy”。

接下来，通过抓住表格最左侧的把手将“Final FantasyVII”文档拖到“Promoted Documents”部分。 然后单击“Final Fantasy XIII”文档上的“Hide Result”按钮（那个有一条线穿过眼睛的图标，下图列表中第三个图标）：

![](https://img-blog.csdnimg.cn/20191116203344151.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

现在，执行“Final Fantasy”或“FF”搜索的任何人都将首先看到“Final Fantasy VII”。

他们根本看不到Final Fantasy XIII。 哈！

我们可以升级和隐藏许多文档。 我们甚至可以对升级后的文档进行排序，因此我们可以完全控制每个查询顶部显示的内容。

## Relevance tuning

单击边栏中的“Relevance Tuning”。

我们搜索一个文本字段：name字段。 但是，如果我们有多个文本字段可供人们搜索，例如name字段和description字段，该怎么办？ 我们正在使用的video game数据集不包含description字段，因此我们假想一些文档以进行仔细考虑。

说我们的文档看起来像这样：
```
    { 
      "name":"Magical Quest",
      "description": "A dangerous journey through caves and such." 
    },
    { 
      "name":"Dangerous Quest",
      "description": "A magical journey filled with magical magic. Highly magic." 
    }
```
如果有人想找到游戏Magical Quest，他们会输入该内容作为查询。 但是第一个结果将是Dangerous Quest：

![](https://img-blog.csdnimg.cn/2019111620413498.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

为什么？ 因为在“Dangerous”的description中“Magical”一词出现了3次，所以搜索引擎不会知道一个字段比另一个字段更重要。 然后，它将使“Dangerous Quest”的排名更高。 这就是为什么存在相关性调整的难题。

我们可以选择一个字段，除其他外，还可以增加其相关性的权重：

![](https://img-blog.csdnimg.cn/20191116204408945.gif)

我们看到，当我们增加权重时，正确的项目“ Magical Quest”上升到顶部，因为name字段变得更重要。 我们需要做的就是将滑块拖动到更高的值，然后单击“Save”。

现在，我们已经使用App Search实现了如下的任务：

- 调整schema，并将user_score和critic_score更改为数字字段。
- 微调关联（relevance）模型。

这样就总结出了精美的“仪表板”功能-每个功能都有一个匹配的API端点，如果您不是GUI的用户，则可以使用它们使程序以编程方式工作。

现在，让我们结束UI。

# 最后加工

此时，您的UI应该可以正常工作了。 尝试一些查询。 首先要说的是，我们缺少探索结果的工具，例如过滤，分面(facet)，排序等，但是搜索有效。 我们需要完善用户界面。

在初始的src/App.js文件中，我们导入了三个基本组件：
```
import { SearchProvider, Results, SearchBox } from "@elastic/react-search-ui";
```
根据我们为配置选项定义的内容，让我们添加更多内容。

导入以下组件将启用UI中缺少的功能：

- PagingInfo：在当前页面上显示信息。
- ResultsPerPage：配置每页上显示多少个结果。
- Paging：浏览不同的页面。
- Facet：以数据类型独有的方式过滤和浏览数据。
- Sort：重新定向给定字段的结果。
```
    import {
      PagingInfo,
      ResultsPerPage,
      Paging,
      Facet,
      SearchProvider,
      Results,
      SearchBox,
      Sorting
    } from "@elastic/react-search-ui";
```
导入后，可以将组件放置到布局中。

布局组件将页面分为多个部分，可以通过prop将组件放置在这些部分中。

它包含以下部分：

- header：搜索框/栏
- bodyContent：结果容器
- sideContent：侧边栏，其中包含构面和排序选项
- bodyHeader：围绕结果的“包装器”，其中包含上下文丰富的信息，例如当前页面和每页结果数
- bodyFooter：用于在页面之间快速导航的分页选项

组件呈现数据。根据我们在configurationOptions中提供的搜索设置获取数据。现在，我们将每个组件放置在适当的布局部分中。

例如，我们在configurationOptions中描述了五个方面的维度，因此我们将创建五个方面的组件。每个Facet组件都将使用“字段”属性作为返回数据的键。

我们将它们与我们的Sorting组件一起放在sideContent部分中，然后将Paging，PagingInfo和ResultsPerPage组件放在最适合它们的部分中：
```
    <Layout
      header={<SearchBox />}
      bodyContent={<Results titleField="name" urlField="image_url" />}
      sideContent={
        <div>
          <Sorting
            label={"Sort by"}
            sortOptions={[
              {
                name: "Relevance",
                value: "",
                direction: ""
              },
              {
                name: "Name",
                value: "name",
                direction: "asc"
              }
            ]}
          />
          <Facet field="user_score" label="User Score" />
          <Facet field="critic_score" label="Critic Score" />
          <Facet field="genre" label="Genre" />
          <Facet field="publisher" label="Publisher" isFilterable={true} />
          <Facet field="platform" label="Platform" />
        </div>
      }
      bodyHeader={
        <>
          <PagingInfo />
          <ResultsPerPage />
        </>
      }
      bodyFooter={<Paging />}
    />
```
现在，让我们看一下本地开发环境中的搜索体验。

好多了！ 我们提供了丰富的选项来探索搜索结果。

我们引入了一些额外的好处，例如多种排序选项，并且通过添加单个标志使发布者的面可过滤。 尝试使用空白查询进行搜索并浏览所有选项。

最后，让我们看一下搜索体验的最后一项功能。 这是一个受欢迎的...

## 自动完成 (Autocomplete)

搜索者喜欢自动完成功能，因为它可以提供即时反馈。 它的建议有两种形式：结果和查询。 取决于哪种口味，搜索者将收到相关结果或可能导致结果的潜在查询。

我们将重点关注自动填充作为一种查询建议形式。

这需要两个快速更改。

首先，我们需要将自动完成功能添加到configurationOptions对象中：
```
    const configurationOptions = {
      autocompleteQuery: {
        suggestions: {
          types: {
            documents: {
              // Which fields to search for suggestions
              fields: ["name"]
            }
          },
          // How many suggestions appear
          size: 5
        }
      },
      ...
    };
```
其次，我们需要根据SearchBox启用自动填充功能：
```
    ...
            <Layout
              ...
              header={<SearchBox autocompleteSuggestions={true} />}
    />
    ...
```
是的，就是这样。

尝试搜索-键入时，将显示自动完成查询建议。

## 总结

现在，我们拥有美观的功能性搜索体验。 而且，我们避免了人们在尝试实施搜索时经常会遇到的一堆陷阱。 30分钟还不错，你不是说吗？你可以在地址进行一个完美的体验。

如果你想进一步动态生成数据集，请参阅文章https://swiftype.com/documentation/app-search/api/documents#create

 

你可以在如下地址找到这个项目的源码：https://github.com/liu-xiao-guo/swiftype-video-game-search

 

参考：

【1】How to Build Great React Search Experiences Quickly
————————————————
版权声明：本文为CSDN博主「Elastic官方博客」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/UbuntuTouch/article/details/103101698