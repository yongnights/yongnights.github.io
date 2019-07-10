---
title: 从0玩转jQuery
date: 2019-07-10 08:48:13
tags:
- HTML 
- jQuery
categories: 
- jQuery
---


# 一、初识jQuery

> 课前须知: 学习jQuery前必须先掌握JavaScript
>  jQuery虽然属于前端技术, 但是对于后端人员(诸如Java、PHP等,也需要掌握)

## 1. jQuery是什么？

![](/image_jquery/logo.png)

- jQuery是一款优秀的JavaScript库，从命名可以看出jQuery最主要的用途是用来做查询（jQuery=js+Query）.
- 在jQuery官方Logo下方还有一个副标题（write less, do more）, 体现了jQuery除了查询以外,还能让我们对HTML文档遍历和操作、事件处理、动画以及Ajax变得更加简单
- 体验jQuery 
  - 原生JS设置背景（先不要求看懂代码，先看看谁更爽）

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>01-初识jQuery</title>
    <script type="text/javascript">
        window.onload = function (ev) {
            // 查询
            var div = document.getElementsByClassName("box01");
            // 操作css
            div[0].style.backgroundColor = "red";
        };
    </script>
    <style type="text/css">
        div {
            width: 100px;
            height: 100px;
            border: 1px solid #000000;
        }
    </style>
</head>
<body>
<div class="box01"></div>
</body>
</html>
```

<escape><!-- more --></escape>

- 使用jQuery设置背景

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>01-初识jQuery</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            // 查询，操作CSS一步到位
            $("div").eq(0).css('background', 'yellow');
        });
    </script>
    <style type="text/css">
        div {
            width: 100px;
            height: 100px;
            border: 1px solid #000000;
        }
    </style>
</head>
<body>
<div class="box01"></div>
</body>
</html>
```

## 2. 为什么要使用jQuery？

- 强大的选择器: 方便快速查找DOM元素
  - 如上面实例所展示一样，通过jQuery查找DOM元素要比原生js快捷很多
  - jQuery允许开发者使用CSS1-CSS3几乎所有的选择器,以及jQuery独创的选择器
- 支持链式调用: 可以通过.不断调用jQuery对象的方法
  - 如上面实例所展示一样，jQuery可以通过.（点）.不断调用jQuery对象的方法，而原生JavaScript则不一定

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>01-初识jQuery</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">
        // 1.原生JavaScript
        var div = document.getElementsByTagName("div");
        // 报错,必须分开写
        div[0].style.backgroundColor = "red".width = 200 + "px";
        //    div[0].style.width = 200+"px";

        // 2.jQuery
        $(document).ready(function () {
            // 不报错,后面还可以接着继续写
            $("div").eq(1).css('background', 'yellow').css('width', '200px');
        });
    </script>
    <style type="text/css">
        div {
            width: 100px;
            height: 100px;
            border: 1px solid #000000;
        }
    </style>
</head>
<body>
<div class="box01"></div>
</body>
</html>
```

- 隐式遍历(迭代): 一次操作多个元素

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>01-初识jQuery</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">
        // 1.原生JavaScript
        var div = document.getElementsByTagName("div");
        // div.style.backgroundColor = "red";// 无效
        for (var i = 0; i < div.length; i++) {
            div[i].style.backgroundColor = "red";
        }

        // 2.jQuery
        $(document).ready(function () {
            // 隐式遍历(迭代)找到的所有div
            $("div").css('background', 'yellow');
        });
    </script>
    <style type="text/css">
        div {
            width: 100px;
            height: 100px;
            border: 1px solid #000000;
        }
    </style>
</head>
<body>
<div>div1</div>
<div>div2</div>
<div>div3</div>
</body>
</html>
```

- 读写合一: 读数据/写数据使用是一个函数

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>01-初识jQuery</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            // 读取数据
            var $tx = $("div").eq(0).text();
            alert($tx);
            // 写入数据
            $("div").eq(0).text("新的数据");
        });
    </script>
    <style type="text/css">
        div {
            width: 100px;
            height: 100px;
            border: 1px solid #000000;
        }
    </style>
</head>
<body>
<div>div1</div>
<div>div2</div>
<div>div3</div>
</body>
</html>
```

- 事件处理
- DOM操作(C增U改D删)
- 样式操作
- 动画
- 丰富的插件支持
- 浏览器兼容(前端开发者痛点)

![img](https:////upload-images.jianshu.io/upload_images/647982-534499becbe5cc2c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000)

  - [1.x](https://link.jianshu.com?t=https%3A%2F%2Fcode.jquery.com%2F)：兼容IE678，但相对其它版本文件较大，官方只做BUG维护，功能不再新增，最终版本：1.12.4 (2016年5月20日).

  - [2.x](https://link.jianshu.com?t=https%3A%2F%2Fcode.jquery.com%2F)：不兼容IE678，相对1.x文件较小，官方只做BUG维护，功能不再新增，最终版本：2.2.4 (2016年5月20日)

  - [3.x](https://link.jianshu.com?t=https%3A%2F%2Fcode.jquery.com%2F)：不兼容IE678，只支持最新的浏览器，很多老的jQuery插件不支持这个版本，相对1.x文件较小，提供不包含Ajax/动画API版本。

- 应该选择几点几版本jQuery?
    - 查看百度网页源码使用1.x
    - 查看腾讯网页源码使用1.x
    - 查看京东网页源码使用1.x
    - 综上所述学习1.x,选择1.x

- 应该使用开发版还是生产版?
    - 开发版: 所有代码没有经过压缩,体积更大(200-300KB)
    - 生产版:所有代码经过压缩,提及更小(30-40KB)
    - 初学者为了更好的理解jQuery编码时使用开发板,项目上线时为了提升访问速度使用生产版

- ……


## 3. 如何使用jQuery？

- 下载jQuery库 
  - 下载地址: [http://code.jquery.com/](https://link.jianshu.com?t=http%3A%2F%2Fcode.jquery.com%2F) 
- 引入下载的jQuery库

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>02</title>
    <!--<script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>-->
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        // 注意:以下两个引入的jQuery版本不同，弹出顺序也不同
        // 引入的是1.x版本的，则先弹出jQuery写法的，然后再弹出原生写法的
        // 引入的是3.x版本的，则先弹出原生写法的，然后再弹出jQuery写法的

        // 1.原生JS的固定写法
        window.onload = function (ev) {
            alert('Hello World! 1');
        };

        // 2.jQuery的固定写法
        $(document).ready(function () {
            alert('Hello World! 2');
        });
    </script>
</head>
<body>

</body>
</html>
```

- 编写jQuery代码

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>01-初识jQuery</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            // 所有jQuery代码写在这里面
            alert("hello LNJ");
        });
    </script>
</head>
<body>
</body>
</html>
```

# 二、入口函数

## 1.  jQuery与JavaScript加载模式对比

- 多个window.onload只会执行一次, 后面的会覆盖前面的
- 多个$(document).ready()会执行多次,后面的不会覆盖前面的
- 不会覆盖的本质(了解,后面jQuery原理会详细讲解)
  - jQuery框架本质是一个闭包,每次执行我们都会给ready函数传递一个新的函数,不同函数内部的数据不会相互干扰

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>03-jQuery和js加载模式</title>
    <!--<script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>-->
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">
        /*
         * 原生JS和jQuery入口函数的的加载模式不同
         * 原生JS会等到DOM元素加载完毕，并且图片也加载完毕才会执行
         * jQuery会等到DOM元素加载完毕，但是不会等到图片也加载完毕就会执行
         */
        
        /*
        window.onload = function (ev) {
            // 1.通过原生的JS的入口函数可以拿到DOM元素
            var img = document.getElementsByTagName('img')[0];
            console.log(img); // 快捷键写法:先写img,然后再写.log,最后按Tab键就会出来
            // 2.通过原生的JS的入口函数可以拿到DOM元素的宽度
            var width = window.getComputedStyle(img).width;
            console.log('onload', width); // onload 1024px
        };
        */
        
        /*
        $(document).ready(function () {
            // 1.通过jQuery的入口函数可以拿到DOM元素
            var $img = $("img")[0];
            console.log($img);
            // 2.通过jQuery的入口函数不可以拿到DOM元素的宽度
            var $width = $img.width;
            console.log('ready', $width); // ready 0
        });
        */

        /*
         * 原生JS如果编写了多个入口函数，后面编写的会覆盖前面编写的
         * jQuery编写了多个入口函数，后面编写的不会覆盖前面编写的
         */
        window.onload = function (ev) {
            alert('Hello World! 1'); // 不弹出
        };
        window.onload = function (ev) {
            alert('Hello World! 2'); // 弹出
        };

        $(document).ready(function () {
            alert('Hello World! 3'); // 弹出
        });
        $(document).ready(function () {
            alert('Hello World! 4'); // 弹出
        });

    </script>
</head>
<body>
<img src="images/风采铃.jpg" alt="">
</body>
</html>

```

|            | window.onload                                            | $(document).ready()                                   |
| --------   | -------------------------------------------------------- | ----------------------------------------------------- |
| 执行时机   | 必须等待网页全部加载完毕(包括图片等),然后再执行包裹代码 | 只需要等待网页中的DOM结构加载完毕,就能执行包裹的代码 |
| 执行次数   | 只能执行一次,如果有第二次,那么第一次的执行会被覆盖        | 可以执行多次,第N次都不会被上 一次覆盖                 |
| 简写方案   | 无                                                       | $(function () { });                                   |


- 为什么我们能访问$符号?
  - 因为$符号jQuery框架对外暴露的一个全局变量
- JavaScript中如何定义一个全局变量?
- 所有全局变量是 window 对象的属性

```js
    function test () {
        var customValue = 998;
        alert(customValue);
        // 1.没有如下代码customValue就不是一个全局变量,函数执行完毕之后
        // customValue会被自动释放,test函数以外的地方访问不到customValue
        // 2.加上如下代码之后customValue就会变成一个全局变量,函数执行完毕也不
        // 会被释放,test函数以外的地方可以访问customValue
        // window.customValue = customValue;
    }
    test();
    alert(customValue);
```

- 所以jQuery框架源码实现

```js
window.jQuery = window.$ = jQuery;
```

- 所以想要使用jQuery框架只有两种方式,一种是通过$,一种是通过jQuery
- jQuery入口函数的其它编写方式如下

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>04-jQuery入口函数其它写法</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">
        // 方法一
        $(document).ready(function () {
            alert('Hello World!');
        });
        // 方式二 (推荐使用这种写法)
        jQuery(document).ready(function () {
            alert('Hello World!');
        });
        // 方式三  (推荐使用这种写法)
        $(function () {
            alert('Hello World!');
        });
        // 方式四
        jQuery(function () {
            alert('Hello World!');
        });
    </script>
</head>
<body>

</body>
</html>
```

## 2.  解决$符号冲突问题

- 为什么是window.jQuery = window.$ = jQuery;,而不是window.jQuery = jQuery;
  - jQuery框架之所以提供了jQuery访问还提供$访问,就是为了提升开发者的编码效率
- $符号冲突怎么办?
  - 很多js的框架都提供了类似jQuery这样的便捷访问方式,所以很有可能某一天我们在使用多个框架的时,多个框架作者提供的便捷访问方式冲突(A框架通过$访问,B框架也通过​$访问)
- 释放$使用权
  - 当便捷访问符号发生冲突时,我们可以释放$使用权, 释放之后只能使用jQuery
- 自定义便捷访问符号
  - 当便捷访问符号发生冲突时,我们可以自定义便捷访问符号

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>05-jQuery冲突问题</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript" src="js/test.js"></script>
    <script type="text/javascript">
        // 1.释放$符号的控制权
        // 注意点：释放操作必须在编写其他jQuery代码之前编写
        //        释放之后就不能在使用$，改为使用jQuery
        jQuery.noConflict();
        jQuery(document).ready(function () {
            alert('Hello World!');
        });

        // 2.自定义访问符号
        var nl = jQuery.noConflict();
        nl(document).ready(function () {
            alert('Hello World!');
        });
    </script>
</head>
<body>

</body>
</html>
```

# 三、核心函数和静态方法

## 1.  jQuery核心函数

- 从jQuery文档中可以看出,jQuery核心函数一共3大类4小类
- jQuery(callback)
  - 当DOM加载完成后执行传入的回调函数
- jQuery([sel,[context]])
  - 接收一个包含 CSS 选择器的字符串，然后用这个字符串去匹配一组元素,并包装成jQuery对象
- 原生JS对象和jQuery对象相互转换

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
    <!--<script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>-->
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">
        $(function () {
            var $box = $("#box");
            //  $box.text("新的数据");
            //  jQuery对象不能使用原生js对象的方法
            //  $box.innerText = "新的数据";
            //  将jQuery对象转换为原生js对象
            //  注意: 不是eq(0),eq函数返回的是jQuery类型对象,get函数返回的是原生类型对象
            //  var box = $box.get(0);
            var box = $box[0];
            box.innerText = "新的数据";

            var box2 = document.getElementById("box");
            //  原生js对象不能使用jQuery对象的方法
            //  box2.text("新的数据2");
            //  原生js对象只能使用原生的js方法
            //  box2.innerText = "新的数据2";

            //  将原生js对象转换为jQuery对象
            var $box2 = $(box);
            $box2.text("新的数据2");
        });
    </script>
</head>
<body>

</body>
</html>
```
> Tips:为了方便开发者之间沟通和阅读,一般情况下所有jQuery操作相关的变量前面加上$

- jQuery(html,[ownerDoc])
  - 根据 HTML 标记字符串，动态创建DOM元素

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>06-jQuery核心函数</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">
        // $();代表jQuery的核心函数

        // 1.接收一个函数,作为入口函数
        $(function () {
            alert('Hello World!');
            // 2.接收一个字符串
            // 2.1接收一个字符串选择器
            // 返回一个jQuery对象，对象中保存了找到的DOM元素
            var $box1 = $(".box1");
            var $box2 = $("#box2");
            console.log($box1);
            console.log($box2);
            // 2.2接收一个代码片段
            // 返回一个jQuery对象，对象中保存了创建的DOM元素
            var $p = $("<p>我是p</p>");
            console.log($p);
            $box1.append($p);
            // 2.3接收一个DOM元素
            // 会被包装成一个jQuery对象返回给我们
            var span = document.getElementsByTagName('span')[0];
            console.log(span); // 原生DOM元素
            var $span = $(span);
            console.log($span); // 把原生DOM元素包装成一个jQuery对象
        });
    </script>
</head>
<body>

<div class="box1"></div>
<div id="box2"></div>
<span>我是span</span>

</body>
</html>
```

## 2. jQuery对象

- jQuery对象的本质是什么? 
  - jQuery对象的本质是一个伪数组
- 什么是伪数组? 
  - 有0到length-1的属性
  - 并且有length属性

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>07-jQuery对象</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            /*
            * 1.什么是jQuery对象
            * jQuery对象是一个伪数组
            * 
            * 2.什么是伪数组
            * 由0到length-1的属性，并且有length属性
            */
            var $div = $("div");
            console.log($div);

            var arr = [1, 3, 5];
            console.log(arr);
        });
    </script>
</head>
<body>
<div>div1</div>
<div>div2</div>
<div>div3</div>
</body>
</html>
```

## 3.  jQuery静态方法

- 什么是静态方法? 
  - 静态方法对应的是对象方法,对象方法用实例对象调用,而静态方法用类名调用 

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>08-静态方法和实例方法</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">
        // 1.定义一个类
        function AClass() {

        };
        // 2.给这个类添加一个静态方法
        // 直接添加给类的就是静态方法
        AClass.staticMthod = function () {
            alert('staticMthod');
        };
        // 静态方法通过类名调用
        AClass.staticMthod();

        // 2.给这个类添加一个实例方法
        AClass.prototype.instanceMethod = function () {
            alert('instanceMethod');
        };
        // 实例方法通过类的实例调用
        // 创建一个实例
        var a = new AClass();
        a.instanceMethod();

    </script>
</head>
<body>

</body>
</html>
```

- jQuery.holdReady(hold)
  - 暂停或者恢复jQuery.ready()事件
  - 传入true或false
  
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>12-jQuery-holdReady方法</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">
        // 使用$直接调用,是静态方法
        $.holdReady(true); // 作用：暂停ready代码的执行
        $(function () {
            alert('function');
        })
    </script>
</head>
<body>
<button>点击测试弹出</button>
<script type="text/javascript">
    var btn = document.getElementsByTagName('button')[0];
    btn.onclick = function () {
        alert('btn');
        $.holdReady(false); // 不解除的话alert('function');不会弹出
    };
</script>
</body>
</html>
```

- $.each(object,[callback])
  - 遍历对象或数组
  - 优点统一遍历对象和数组的方式
  - 回调参数的顺序更符合我们的思维模式 
  
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>09-jQuery-each方法</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        var arr = [1, 3, 5, 7, 9];
        var obj = {0: 1, 1: 3, 2: 5, 3: 7, 4: 9, length: 5};

        /*
        * 第一个参数：遍历到的元素
        * 第二个参数：当前遍历到的索引
        * 注意点：原生的forEach方法只能遍历数组，不能遍历伪数组
        * */
        arr.forEach(function (value, index) {
            console.log(index, value);
        });

        // TypeError: obj.forEach is not a function
        /*
        obj.forEach(function (value, index) {
            console.log(index, value);
        });
        */

        // 1.利用jQuery的each静态方法遍历数组
        /*
        * 第一个参数：当前遍历到的索引
        * 第二个参数：遍历到的数组
        * 注意点：jQuery的each方法可以遍历伪数组
        * */
        $.each(arr, function (index, value) {
            console.log(index, value);
        });

        $.each(obj, function (index, value) {
            console.log(index, value);
        });

    </script>

</head>
<body>

</body>
</html>
```


- $.map(arr|obj,callback)
  - 遍历对象或数组,将回调函数的返回值组成一个新的数组返回

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>10-jQuery-map方法</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        var arr = [1, 3, 5, 7, 9];
        var obj = {0: 1, 1: 3, 2: 5, 3: 7, 4: 9, length: 5};

        // 1.利用原生JS的map方法遍历
        /* 第一个参数:当前遍历到的元素
         * 第二个参数：当前遍历到的索引
         * 第三个参数：当前被遍历的数组
         * 注意点：和原生的forEach一样，不能遍历伪数组
         * */
        arr.map(function (value, index, array) {
            console.log(index, value, array);
        });
        // TypeError: obj.map is not a function
        /*
        obj.map(function (value, index, array) {
            console.log(index, value, array);
        });
        */

        /* 第一个参数:要遍历的数组
         * 第二个参数：每遍历一个元素之后执行的回调函数
         * 回调函数的参数：
         * 第一个参数：遍历到的元素
         * 第二个参数：遍历到的索引
         * 注意点：和jQuery中的each静态方法一样，map静态方法可以遍历伪数组
         * */
        $.map(arr, function (value, index) {
            console.log(index, value);
        });
        $.map(obj, function (value, index) {
            console.log(index, value);
        });

        // jQuery中的each静态方法和map静态方法的区别
        // each静态方法默认的返回值就是，遍历谁就返回谁
        // map静态方法默认的返回值是一个空数组

        // each静态方法不支持在回调函数中对遍历的数组进行处理
        // map静态方法可以在回调函数中通过return对遍历的数组进行处理，然后生成一个新数组返回

        var res1 = $.each(arr, function (index, value) {
            console.log(index, value);
            return value + index;
        });

        var res2 = $.map(arr, function (value, index) {
            console.log(index, value);
            return value + index;
        });

        console.log(res1);
        console.log(res2);

    </script>
</head>
<body>

</body>
</html>
```

- $.trim(str)
  - 去掉字符串起始和结尾的空格
- $.isArray(obj)
  - 判断是否是数组
- $.isFunction(obj)
  - 判断是否是函数
- $.isWindow(obj)
  - 判断是否是window对象

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>11-jQuery其它静态方法</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">
        /*
        * $.trim();
        * 作用：去除字符串两端的空格
        * 参数：需要去除空格的字符串
        * 返回值：去除空格之后的字符串
        * */
        var str = '----   Hello   -----';
        console.log(str);
        var res = $.trim(str);
        console.log(res);

        // 真数组
        var arr = [1, 3, 5, 7, 9];
        // 伪数组
        var arrlike = {0: 1, 1: 3, 2: 5, 3: 7, 4: 9, length: 5};
        // 对象
        var obj = {'name': 'hello', 'age': 33};
        // 函数
        var fn = function () {
        };
        // window对象
        var w = window;

        /*
        * $.isWindow();
        * 作用：判断传入的对象是否是window对象
        * 返回值：true/false
        * */
        var res = $.isWindow(arr);
        console.log(res);

        /*
        * $.isArray();
        * 作用：判断传入的对象是否是真数组
        * 返回值：true/false
        * */
        var res = $.isArray(arr);
        console.log(res);

        /*
        * $.isFunction();
        * 作用：判断传入的对象是否是一个函数
        * 返回值：true/false
        * */
        var res = $.isFunction(arr);
        console.log(res);
        /*
        * 注意点: jQuery框架本质上是一个函数
        * (function (windos, undefined) {
        * })(window);
        * */

        var res = $.isFunction(jQuery);
        console.log(res); // true

        (function (windos, undefined) {
        })(window);

    </script>
</head>
<body>

</body>
</html>
```

补充知识
1. 使用IDE软件的快捷键方便引用jquery文件
Settings，Editor，Live Templates，在右边找到HTML/XML，在Abbreviation中输入字母作为快捷键，在Template text中输入要引用的jquery代码，左下角设置成HTML text,点击应用，以后输入这个字母后按tab键就会自动出来相应的jquery代码
![](/image_jquery/settings-1.jpg)

2. 使用快捷键打开浏览器
Settings，Appearance&Behavior，Keymap，搜索“default”，在Other的Open in deafult browser中鼠标右键，Add Keyboard Shortcut，给打开默认浏览器设置一个快捷键。以后在html中打开浏览器的话就不用鼠标点击了，直接按快捷键即可。
![](/image_jquery/settings-2.jpg)

# 四、选择器

## 1.  基础选择器

- **视频参考第十章-CSS选择器**

| 选择器                        | 名称         | 描述                                   | 返回     | 示例                                                         |
| ----------------------------- | ------------ | -------------------------------------- | -------- | ------------------------------------------------------------ |
| #id                           | id选择器     | 根据给定的id匹配一个元素               | 单个元素 | $("#box");选取id为box元素                                    |
| .class                        | 类选择器     | 根据给定的类名匹配元素                 | 集合元素 | $(".box");选取所有类名为box元素                              |
| element                       | 元素选择器   | 根据给定的元素名称匹配元素             | 集合元素 | $("p");选取所有<p>元素                                       |
| *                             | 通配符选择器 | 匹配所有元素                           | 集合元素 | $("*");选取所有元素                                          |
| selector1,selector2,selectorN | 并集选择器   | 将所有选择器匹配到的元素合并后一起返回 | 集合元素 | $("div,p,.box");选取所有<div>元素,所有<p>元素和所有类名为box元素 |

------

## 2. 层次选择器

- **视频参考第十章-CSS选择器**

| 选择器                   | 名称           | 描述                                                         | 返回     | 示例                                                   |
| ------------------------ | -------------- | ------------------------------------------------------------ | -------- | ------------------------------------------------------ |
| $("ancestor descendant") | 后代选择器     | 选取ancestor元素的所有descendant后代标签(不光是儿子,包括孙子/重孙子等) | 集合元素 | $("div span");选取<div>元素里所有的<span>元素          |
| $("parent > child")      | 子元素选择器   | 找到选取parent 元素中所有直接子元素child(只有儿子,不包括孙子/重孙子等) | 集合元素 | $("div>span");选取<div>元素下元素名称是<span>的子元素  |
| $("prev + next")         | 相邻兄弟选择器 | 选取prev元素后面紧跟的那个next元素                           | 集合元素 | $(".one+div");选取类名为one的下一个同级的<div>元素     |
| $("prev ~ siblings")     | 通用兄弟选择器 | 选取prev元素后面的所有next元素                               | 集合元素 | $("#two~div");选取id名为two元素后面所有同级的<div>元素 |

## 3. 序选择器

- **视频参考第十章-CSS选择器**

> 如上内容不再一一赘述,观看第十章-CSS选择器,使用时查询文档即可
>  做开发是脑力活,我们需要掌握的是解决问题的方法,而不是死记硬背

## 4.  属性选择器

- **视频参考第十章-CSS选择器**

> 如上内容不再一一赘述,观看第十章-CSS选择器,使用时查询文档即可
>  做开发是脑力活,我们需要掌握的是解决问题的方法,而不是死记硬背

## 5.  内容过滤选择器

| 选择器          | 描述                             | 返回     |
| --------------- | -------------------------------- | -------- |
| :empty          | 选取不包含子元素或文本为空的元素 | 集合元素 |
| :parent         | 选取含有子元素或文本的元素       | 集合元素 |
| :contains(text) | 选取含有文本内容为text的元素     | 集合元素 |
| :has(selector)  | 选取含有选择器所匹配的元素的元素 | 集合元素 |

- :empty
- :parent
- :contains(text)
- :has(selector)
  - 和:parent区别,parent只要有子元素就会被找到,:has(selector)不仅要有子元素,而且子元素还必须满足我们的条件

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>14-jQuery内容选择器</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        // :empty
        // 作用：找到既没有文本内容也没有子元素的指定元素
        var $div = $('div:empty');
        console.log($div);

        // :parent
        // 作用：找到有文本内容或有子元素的指定元素
        var $div = $('div:parent');
        console.log($div);

        // :contains(text)
        // 作用：找到包含指定文本内容的指定元素
        var $div = $("div:contains('我是div')");
        console.log($div);

        // :has(selector)
        // 作用：找到包含指定子元素的指定元素
        var $div = $("div:has('span')");
        console.log($div);

    </script>
    <style type="text/css">
        div {
            width: 100px;
            height: 100px;
            background: greenyellow;
            margin-top: 5px;
        }
    </style>

</head>
<body>
<div></div>
<div>我是div</div>
<div>我是div123</div>
<div><span></span></div>
<div><p></p></div>
</body>
</html>
```

# 五、属性相关

## 1. 属性和属性节点

- 什么是属性?
  - 属性就是对象身上的变量
  - 只要对象身上都可以添加属性(无论是自定义对象,还是DOM对象)
- 什么是属性节点?
  - 在html中编写的所有标签，里面的属性都是属性节点 
- 如果操作属性?
  - 添加或修改属性(没有就会添加,有就会修改) 
    - `对象.属性名称 = 值;`
    - `对象["属性名称"] = 值;`
  - 获取属性 
    - `对象.属性名称`
    - `对象["属性名称"]`
- 如何操作属性节点?
  - 获取属性节点 
    - `DOM对象.getAttribute("属性节点名称")`
  - 设置属性节点 
    - `DOM对象.setAttribute("属性节点名称", "值");`

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>15-属性和属性节点</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        /*
        * 1.什么是属性
        * 对象身上保存的变量就是属性
        * 2.如何操作属性
        * 设置：对象.属性名称 = 值
        * 获取：对象.属性名称
        * 设置：对象['属性名称'] = 值
        * 获取：对象['属性名称']
        * 3.什么是属性节点
        * <span name="it"></span>
        * 在编写html标签中添加的属性就是属性节点
        * 在浏览器中找到span这个DOM元素之后，在attributes中保存的所有内容都是属性节点
        * 4.如何操作属性节点
        * DOM元素.setAttribute('属性名称','属性值');
        * DOM元素.getAttribute('属性名称');
        * 5.属性和属性节点有什么区别
        * 任何对象都有属性，但是只有DOM对象只有属性节点
        * */

        function Func() {
            var p = new Func();
            p.name = 'hello';
            console.log(p.name);
    
            p['age'] = 23;
            console.log(p['age']);
    
            var span = document.getElementsByTagName('span')[0];
            console.log(span);
            span.setAttribute('name', 'world!');
            console.log(span.getAttribute('name'));
        }
    </script>
</head>
<body>
<span name="it">11</span>
</body>
</html>
```


## 2. jQuery中的attr和prop方法

- attr(name|pro|key,val|fn)方法
  - 用于设置或获取属性节点的值
- removeAttr(name)方法
  - 用于删除指定属性节点 

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>16-jQuery-attr方法</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">
        // 1.attr(name|pro|key,val|fn)
        // 作用：获取或设置属性节点的值，可以传递一个参数，也可以传递两个
        // 如果传递一个参数代表获取属性节点的值
        // 如果传递两个参数代表获取属性节点的值
        // 注意点：如果是获取：不论找到多少个元素，只返回第一个元素指定节点的值
        //        如果是设置：找到多少个元素就会设置多少个元素
        //        如果是设置：如果设置的属性节点不存在，那么系统会自动新增
        // 2.removeAttr(name)
        // 作用：删除属性节点
        // 注意点：会删除所有找到元素指定的属性节点


        $(function () {
            // console.log($('span').attr('class')); // span1
            // $('span').attr('class','box');
            // $('span').attr('abc','123');
            // $('span').removeAttr('class');
            $('span').removeAttr('class name'); // 删除多个属性节点
        });

    </script>
</head>
<body>

<span class="span1" name="it111"></span>
<span class="span2" name="it222"></span>

</body>
</html>
```

- prop(n|p|k,v|f)方法
  - 用于设置或者获取元素的属性值
- removeProp(name)方法

- attr方法和prop方法区别
  - 既然所有的DOM对象，都有一个attributes属性,而prop可以操作属性,所以也可以操作属性节点
  - 官方推荐在操作属性节点时,具有 true 和 false 两个属性的属性节点，如 checked, selected 或者 disabled 使用prop()，其他的使用 attr()
  - 因为如果具有 true 和 false 两个属性的属性节点,如果没有编写默认attr返回undefined,而prop返回false

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>17-jQuery-prop方法</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">
        // 1.prop(n|p|k,v|f)
        // 特点和attr方法一样
        // 2.removeProp(name)
        // 特点和removeAttr方法一样
        $(function () {
            $('span').eq(0).prop('demo','debug'); // 给指定DOM元素设置属性节点
            $('span').prop('demo'); // 获取指定DOM元素的属性节点
            $('span').removeProp('demo'); // 删除指定DOM元素的属性节点
        });

        /*
        * prop方法不仅能操作属性，还能操作属性节点
        *
        */

        console.log($('span').prop('class')); // 获取属性节点
        $('span').prop('class','box'); // 修改属性节点
                                               // 有checked / 无checked
        console.log($('input').prop('check')); // true      / false
        console.log($('input').attr('check')); // checked   / undefined

    </script>
</head>
<body>
<span class="span1" name="it111"></span>
<span class="span2" name="it222"></span>

<input type="checkbox" checked>
</body>
</html>
```

### 练习

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>18-attr和prop练习</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">
        // 作用是在输入框里输入图片地址，比如：images/2.jpg，然后点击切换图片，下方的图片就会发生变化
        $(function () {
            // 1.给按钮添加点击事件
            var btn = document.getElementsByTagName('button')[0];
            btn.onclick = function () {
                // 2.获取输入框的内容
                var input = document.getElementsByTagName('input')[0];
                var text = input.value;
                // 3.修改img的src属性节点的值
                $('img').attr('src', text);
            }
        });

    </script>
</head>
<body>
<input type="text">
<button>切换图片</button>
<br/>
<img src="images/1.jpg" alt="">
</body>
</html>
```

## 3. jQuery增删Class

- jQuery CSS类相关方法都是用于操作DOM对象的class属性节点的值
- addClass(class|fn)
  - 给元素添加一个或多个类
- removeClass([class|fn])
  - 删除元素的一个或多个类
- toggleClass(class|fn[,sw])
  - 添加或删除一个类(存在就删除不存在就添加)

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>19-jQuery类操作相关方法</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            // 1.addClass(class|fn)
            // 作用：添加一个类，如果要添加多个，中间用空格隔开
            // 2.removeClass([class|fn])
            // 作用：删除一个类，如果要删除多个，中间用空格隔开
            // 3.toggleClass(class|fn[,sw])
            // 作用：切换，有就删除，没有就添加

            var btns = document.getElementsByTagName('button');
            btns[0].onclick = function () {
                $('div').addClass('class1 class2');
            };
            btns[1].onclick = function () {
                $('div').removeClass('class1 class2');
            };
            btns[2].onclick = function () {
                $('div').toggleClass('class1 class2');
            };
        });

    </script>
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        .class1 {
            width: 100px;
            height: 100px;
            background: red;
        }

        .class2 {
            border: 10px solid yellowgreen;
        }
    </style>
</head>
<body>
<button>添加类</button>
<button>删除类</button>
<button>切换类</button>
<div></div>
</body>
</html>
```


## 4. jQuery代码/文本/值

- html([val|fn])
  - 添加或获取元素中的HTML
- text([val|fn])
  - 添加或获取元素中的文本
  - text方法能做的html方法都能做,所以一般使用html方法即可
- val([val|fn|arr])
  - 添加或获取元素value属性的值

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>20-jQuery文本值相关操作</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">
        // 1.html([val|fn])
        // 和原生JS中的innerHTML一模一样
        // 2.text([val|fn])
        // 和原生JS中的innerTEXT一模一样
        // 3.val([val|fn|arr])

        $(function () {
            var btns = document.getElementsByTagName('button');
            btns[0].onclick = function () {
                $('div').html('<p>我是段落<span>我是span</span></p>');
            };
            btns[1].onclick = function () {
                console.log($('div').html());
            };
            btns[2].onclick = function () {
                $('div').text('<p>我是段落<span>我是span</span></p>');
            };
            btns[3].onclick = function () {
                console.log($('div').text());
            };
            btns[4].onclick = function () {
                $('input').val('请输入内容');
            };
            btns[5].onclick = function () {
                console.log($('input').val());
            };
        });

    </script>

    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        div {
            width: 100px;
            height: 100px;
            border: 1px solid;
        }
    </style>
</head>
<body>
<button>设置html</button>
<button>获取html</button>
<button>设置text</button>
<button>获取text</button>
<button>设置value</button>
<button>获取value</button>
<div></div>
<br/>
<input type="text">
</body>
</html>
```

# 六、CSS操作

## 1. jQuery操作CSS样式

- css(name|pro|[,val|fn])方法
  - 用于设置或获取元素CSS样式
  - 格式1：DOM元素.css("样式名称", "值");
  - 格式2：DOM元素.css({"样式名称1":"值1","样式名称2":"值2"});


```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>21-jQuery操作样式方法</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            // 1.逐个设置
            $('div').css('width', '100px');
            $('div').css('height', '100px');
            $('div').css('background', 'yellow');
            // 2.链式设置
            // 注意点：链式操作如果大于三步，建议分开
            $('div').css('width', '100px').css('height', '100px').css('background', 'red');
            // 3.批量设置
            $('div').css({
                width: '100px',
                height: '100px',
                background: 'green'
            });

            // 4.获取
            console.log($('div').css('width'));
            console.log($('div').css('height'));
        });

    </script>
</head>
<body>
<div></div>
</body>
</html>
```


## 2. jQuery操作元素尺寸

- width([val|fn])方法
  - 设置或获取元素宽度(相当于获取width属性值)

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>11-jQuery操作位置和尺寸</title>
    <style>
        *{
            margin: 0;
            padding: 0;
        }
        .father{
            width: 250px;
            height: 250px;
            background-color: red;
            margin-left: 50px;
            position: relative;
        }
        .son{
            width: 100px;
            height: 100px;
            background-color: blue;
            position: absolute;
            left: 50px;
            top: 50px;
        }
    </style>
    <script src="代码/js/jquery-1.12.4.js"></script>
    <script>
        $(function () {
            $("button").eq(0).click(function () {
                // 1.获取元素宽度(不包括padding和border)
//                alert($('.son').width());
            });
            $("button").eq(1).click(function () {
                // 2.设置元素宽度(不包括padding和border)
//                $(".son").width("50px");
            });
        });
    </script>
</head>
<body>
<div class="father">
    <div class="son"></div>
</div>
<button>获取</button>
<button>设置</button>
</body>
</html>
```

- height([val|fn])方法
  - 设置或获取元素宽度(相当于获取height属性值)
  - 用上面按钮代码自己写,工作后都得靠自己,多锻炼自学能力(如何查看文档,如何编写测试案例等)
- innerHeight()/innerWidth()
  - 用上面按钮代码自己写,工作后都得靠自己,多锻炼自学能力(如何查看文档,如何编写测试案例等)
- outerHeight/outerWidth()
  - 用上面按钮代码自己写,工作后都得靠自己,多锻炼自学能力(如何查看文档,如何编写测试案例等)


## 3. jQuery操作元素位置

- offset([coordinates])
  - 获取或设置元素相对窗口的偏移位
- position()
  - 获取相对于它最近的具有相对位置(position:relative或position:absolute)的父级元素的距离

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>22-jQuery尺寸和位置操作</title>
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        .father {
            width: 200px;
            height: 200px;
            background: yellowgreen;
            border: 50px solid #000000;
            margin-left: 50px;
            position: relative;
        }

        .son {
            width: 100px;
            height: 100px;
            background: gold;
            position: absolute;
            top: 50px;
            left: 50px;
        }
    </style>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            var btns = document.getElementsByTagName('button');
            // 监听获取
            btns[0].onclick = function () {
                // 获取元素的宽度
                // console.log($('.father').width());
            };
            // 监听设置
            btns[1].onclick = function () {
                // 设置元素的宽度
                // $('.father').width('500px');
                // $('.son').offset({
                //     left:10
                // })
            };

                // offset([coordinates])
                // 作用：获取元素距离窗口的偏移位
                // console.log($('.son').offset().left);
                // position()
                // 作用：获取元素距离定位元素的偏移位,只能获取，不能设置
                // $('.son').position({
                //     left:20
                // })
                console.log($('.son').position().left);
                $('.son').css({
                    left:20,
                })

        });

    </script>

</head>
<body>
<div class="father">
    <div class="son">

    </div>
</div>
<button>获取</button>
<button>设置</button>
</body>
</html>
```

- scrollTop([val])
  - 设置或获取匹配元素相对滚动条顶部的偏移。
- scrollLeft([val])
  - 用上面按钮代码自己写,工作后都得靠自己,多锻炼自学能力(如何查看文档,如何编写测试案例等)

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>23-jQuery的scrollTop方法</title>
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        .scroll {
            width: 100px;
            height: 100px;
            border: 1px solid black;
            overflow: auto;
        }

    </style>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            var btns = document.getElementsByTagName('button');
            btns[0].onclick = function () {
                // 获取滚动的偏移位
                console.log($('.scroll').scrollTop());
                // 获取网页滚动的偏移位
                // 注意点：为了保证浏览器的兼容，需要按照以下写法
                console.log($('html').scrollTop() + $('body').scrollTop());
            };
            btns[1].onclick = function () {
                // 设置滚动的偏移位
                $('.scroll').scrollTop(10);
                // 设置网页的滚动偏移位
                // 注意点：为了保证浏览器的兼容，设置网页滚动偏移位的时候需要按照以下写法
                $('html,body').scrollTop(20)
            };


        });

    </script>
</head>
<body>
<div class="scroll">
    我是div
    我是div
    我是div
    我是div
    我是div
    我是div
    我是div
    我是div
</div>
<button>获取</button>
<button>设置</button>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
</body>
</html>
```


# 七、事件处理

## 1. 事件绑定

- jQuery中事件绑定有两种方式
  - eventName(function(){}) 
    - 绑定对应事件名的监听,   例如：$('#div').click(function(){});
  - on(eventName, funcion(){}) 
    - 通用的绑定事件监听, 例如：$('#div').on('click', function(){});
- 优缺点:
  - eventName: 编码方便, 但有的事件监听不支持
  - on: 编码不方便, 但更通用
- 企业开发中如何选择?
  - 能用eventName就用eventName, 不能用eventName就用on
- 示例:


```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>24-jQuery事件绑定</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            // jQuery中有两种绑定事件方式
            // 1.eventName(fn);
            // 编码效率略高,部分事件jQuery没有实现，所有不能添加
            $('button').click(function () {
                alert('hello');
            });

            // 2.on(eventName,fn);
            // 编码效率略低，所有js事件都可以添加
            $('button').on('click', function () {
                alert('hello click');
            })

            // 注意点:
            // 可以多次添加相同或不同类型的事件不,且会覆盖
        });

    </script>
</head>
<body>
<button>我是按钮</button>
</body>
</html>
```

## 2. 事件解绑

- jQuery中可以通过off(eventName,function);解绑事件
- 示例:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>25-jQuery事件解绑</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">
        $(function () {

            function test1() {
                alert('test1');
            }

            function test2() {
                alert('test2');
            }

            $('button').click(test1);
            $('button').click(test2);

            $('button').mouseleave(function () {
                alert('mouseleave');
            });

            $('button').mouseenter(function () {
                alert('mouseenter');
            });
            // off方法如果不传递参数，会移除所有的事件
            // $('button').off();
            // off方法如果传递一个参数，会移除所有指定类型的事件
            // $('button').off('click');
            // off方法如果传递两个参数，会移除所有指定类型的指定事件
            // $('button').off('click，test1');
        });

    </script>

</head>
<body>
<button>我是按钮</button>
</body>
</html>
```

## 3. 获取事件的坐标

- 当事件被触发时,系统会将事件对象(event)传递给回调函数,通过event对象我们就能获取时间的坐标
- 获取事件坐标有三种方式
  - event.offsetX, event.offsetY 相对于事件元素左上角
  - event.pageX, event.pageY  相对于页面的左上角
  - event.clientX, event.clientY  相对于视口的左上角
- event.page和event.client区别
  - 网页是可以滚动的,而视口是固定的
  - 所以想获取距离可视区域坐标通过event.client
  - 想获取距离网页左上角的坐标通过event.client
- 示例代码

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>13-jQuery事件绑定和解绑</title>
    <style>
        *{
            margin: 0;
            padding: 0;
        }
        .father{
            width: 200px;
            height: 200px;
            background: red;
            overflow: hidden;
        }
        .son{
            width: 100px;
            height: 100px;
            background: blue;
            margin-top: 50px;
            margin-left: 50px;
        }
    </style>
    <script src="../day01/代码/js/jquery-1.12.4.js"></script>
    <script>
        $(function () {
            // 获取事件的坐标
            $(".son").click(function (event) {
                // 获取相对于事件元素左上角坐标
                console.log(event.offsetX, event.offsetY);
                // 获取相对于视口左上角坐标
                console.log(event.clientX, event.clientY);
                // 获取相对于页面左上角坐标
                console.log(event.pageX, event.pageY);
            });
        });
    </script>
</head>
<body>
<div class="father">
    <div class="son"></div>
</div>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
</body>
</html>
```

------

## 4. 阻止事件冒泡

- 什么是事件冒泡?
  - 事件冒泡是从目标元素逐级向上传播到根节点的过程
  - 小明告诉爸爸他有一个女票,爸爸告诉爷爷孙子有一个女票,一级级向上传递就是事件冒泡
- 如何阻止事件冒泡?
  - 多数情况下，我们希望在触发一个元素的事件处理程序时，不影响它的父元素, 此时便可以使用停止事件冒泡

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>26-jQuery事件冒泡和默认行为</title>
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        .father {
            width: 200px;
            height: 200px;
            background: yellowgreen;
        }

        .son {
            width: 100px;
            height: 100px;
            background: gold;
        }
    </style>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            // 1.什么是事件冒泡
            // 2.如何阻止事件冒泡
            // 第一种是使用return false;
            // 第二种是调用event.stopPropagation();
            $('.son').click(function (event) {
                alert('son');
                // return false;
                event.stopPropagation();

            });
            $('.father').click(function () {
                alert('father');
            });
        });

    </script>
</head>
<body>
<div class="father">
    <div class="son">
    </div>
</div>

</body>
</html>
```


## 5. 阻止事件默认行为

- 什么是默认行为?
  - 网页中的元素有自己的默认行为,例如单击超链接后会跳转,点击提交表单按钮会提交
- 如何阻止事件默认行为?
  - 可以使用event.preventDefault();方法阻止事件默认行为方法

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>26-jQuery事件冒泡和默认行为</title>
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        .father {
            width: 200px;
            height: 200px;
            background: yellowgreen;
        }

        .son {
            width: 100px;
            height: 100px;
            background: gold;
        }
    </style>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            // 1.什么是默认行为
            // 2.如何阻止默认行为
            // 第一种是使用return false;
            // 第二种是调用event.stopPropagation();
            $('a').click(function (event) {
                alert('弹出注册框');
                // return false;
                event.stopPropagation();
            });
        });

    </script>
</head>
<body>
<a href="http://www.baidu.com">我是百度</a>
<form action="http://www.taobao.com">
    <input type="text">
    <input type="submit">
</form>
</body>
</html>
```


## 6. 自动触发事件

- 什么是自动触发事件
  - 通过代码控制事件, 不用人为点击/移入/移除等事件就能被触发
- 自动触发事件方式
  - $("selector").trigger("eventName"); 
    - 触发事件的同时会触发事件冒泡
    - 触发事件的同时会触发事件默认行为
  - $("selector").triggerHandler("eventName"); 
    - 触发事件的同时不会触发事件冒泡
    - 触发事件的同时不会触发事件默认行为

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>27-jQuery事件自动触发</title>
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        .father {
            width: 200px;
            height: 200px;
            background: yellowgreen;
        }

        .son {
            width: 100px;
            height: 100px;
            background: gold;
        }
    </style>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {

            $('.son').click(function () {
                alert('son');

            });
            $('.father').click(function () {
                alert('father');
            });

            /*
            * trigger:如果利用trigger自动触发事件，会触发事件冒泡
            * triggerHandler：如果利用trigger自动触发事件，不会触发事件冒泡
            */
            // $('.father').trigger('click');
            // $('.son').trigger('click');
            // $('.father').triggerHandler('click');
            // $('.son').triggerHandler('click');

            /*
             * trigger:如果利用trigger自动触发事件，会触发默认行为
             * triggerHandler：如果利用trigger自动触发事件，不会触发默认行为
             */
            // $("input[type='submit']").click(function () {
            //     alert('submit');
            // });

            // $("input[type='submit']").trigger('click');
            // $("input[type='submit']").triggerHandler('click');

            $('a').click(function () {
                alert('a');
            });
            // 注意点：trigger和triggerHandler针对a标签的操作一样，不会触发默认行为
            // $('a').trigger('click');
            // $('a').triggerHandler('click');
            // 但是若想a标签自动触发，且有默认行为,需要针对a标签里的span元素进行操作
            $('span').trigger('click');
        });

    </script>
</head>
<body>
<div class="father">
    <div class="son">

    </div>
</div>
<a href="http://www.baidu.com">我是百度</a>
<a href="http://www.baidu.com"><span>我是有默认行为的</span></a>
<form action="http://www.taobao.com">
    <input type="text">
    <input type="submit">
</form>
</body>
</html>
```


## 7. 事件命名空间和自定义事件

- 什么是自定义事件
  - 自定义事件就是自己虾XX起一个不存在的事件名称来注册事件, 然后通过这个名称还能触发对应的方法执行, 这就是传说中的自定义事件
- 自定义事件的前提条件
  - 1.事件必须是通过on绑定的
  - 2.事件必须通过trigger来触发
  - 因为trigger方法可以自动触发对应名称的事件,所以只要事件的名称和传递给trigger的名称一致就能执行对应的事件方法

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>28-jQuery自定义事件</title>
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        .father {
            width: 200px;
            height: 200px;
            background: yellowgreen;
        }

        .son {
            width: 100px;
            height: 100px;
            background: gold;
        }
    </style>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            /*
            * 自定义事件需要满足两个条件
            * 1.事件必须是通过on绑定
            * 2.事件必须通过trigger来触发
            *
            * */
            // $('.son').myClick(function () {
            //     alert('son');
            // });
            // $('.son').trigger('myClick');

            $('.son').on('myClick', function () {
                alert('son');
            });
            $('.son').trigger('myClick');

        });

    </script>
</head>
<body>
<div class="father">
    <div class="son">
    </div>
</div>
</body>
</html>
```

- 什么是事件命名空间
- 众所周知一个元素可以绑定多个相同类型的事件.企业多人协同开发中,如果多人同时给某一个元素绑定了相同类型的事件,但是事件处理的方式不同,就可能引发事件混乱
- 为了解决这个问题jQuery提出了事件命名空间的概念
  - 事件命名空间主要用于区分相同类型的事件,区分不同前提条件下到底应该触发哪个人编写的事件
  - 格式: "eventName.命名空间"
- 添加事件命名空间的前提条件
  - 1.事件是通过on来绑定的
  - 2.通过trigger触发事件
- 注意点(面试题!!!面试题!!!面试题!!!):
  - 不带命名空间事件被trigger调用,会触发带命名空间事件
  - 带命名空间事件被trigger调用,只会触发带命名空间事件
  - 下级不带命名空间事件被trigger调用,会冒泡触发上级不带命名空间和带命名空间事件
  - 下级带命名空间事件被trigger调用,不会触发上级不带命名空间事件
  - 下级带命名空间事件被trigger调用,会触发上级带命名空间事件
- 示例:


```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>29-jQuery事件命名空间</title>
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        .father {
            width: 200px;
            height: 200px;
            background: yellowgreen;
        }

        .son {
            width: 100px;
            height: 100px;
            background: gold;
        }
    </style>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            /*
            * 想要事件的命名空间有效，必须满足两个条件
            * 1.事件是通过on绑定的
            * 2.通过trigger触发事件
            * */
            $('.son').on('click.zs', function () {
                alert('click-1'); // 自动弹出
            });
            $('.son').on('click.ls', function () {
                alert('click-2');
            });
            $('.son').trigger('click.zs');
            // $('.son').trigger('click.ls');
        });

    </script>
</head>
<body>
<div class="father">
    <div class="son">
    </div>
</div>
</body>
</html>
```

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>30-jQuery事件命名空间面试题</title>
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        .father {
            width: 200px;
            height: 200px;
            background: yellowgreen;
        }

        .son {
            width: 100px;
            height: 100px;
            background: gold;
        }
    </style>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            $('.father').on('click.zs', function () {
                alert('father click-1'); 
            });
            $('.father').on('click', function () {
                alert('father click-2');
            });
            $('.son').on('click.zs', function () {
                alert('son click-1');
            });
            // 1.利用trigger触发子元素带有命令空间的事件，那么父元素带相同命名空间的事件也会被触发，而父元素没有命令空间的不会被触发
            // $('.son').trigger('click.zs');

            // 2.利用trigger触发子元素不带命令空间的事件，那么子元素所有相同类型的事件和父元素所有相同的事件都会被触发
            $('.son').trigger('click');
        });

    </script>
</head>
<body>
<div class="father">
    <div class="son">
    </div>
</div>
</body>
</html>
```

## 8.事件委托

- 什么是事件委托
  - 例如: 张三在寝室不想去食堂吃饭,那么张三可以"委托"李四帮忙带一份饭
  - 例如: 张三先找房,但是对要找房的地点又不熟悉,那么张三可以"委托"中介帮忙找房
  - 所以得出结论: 
    - 事件委托就是请其他人帮忙做我们想做的事
    - 做完之后最终的结果还是会反馈到我们这里
- js中事件委托的好处
  - 减少监听数量 
    - 添加到页面上的事件处理程序数量将直接关系到页面的整体运行性能，因为需要不断的与dom节点进行交互，访问dom的次数越多，引起浏览器重绘与重排的次数也就越多，就会延长整个页面的交互就绪时间
    - 每个监听的函数都是一个对象，是对象就会占用内存，对象越多，内存占用率就越大，自然性能就越差
    - ... ...
  - 新增元素自动有事件响应处理 
    - 默认情况下新增的元素无法响应新增前添加的事件
- jQuery中如何添加事件委托
    - 添加前
      - $("li").click隐式迭代给界面上所有li都添加了click事件(监听数量众多)
      - 通过$("ul").append新添加的li无法影响click事件
    - 添加后 
      - 格式:$(parentSelector).delegate(childrenSelector, eventName, callback)
      - $("ul").delegate隐式迭代所有ul添加事件(相比开始迭代li,必然ul的个数会少很多)
      - 当事件被触发时,系统会自动动态查找当前是哪个li触发了事件,所以新增的li也能响应到事件

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>31-jQuery事件委托</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            /*
            * 1.什么是事件委托
            * 请别人帮忙做事情，然后将做完的结果反馈给我们
            * */
            
            $('button').click(function () {
                $('ul').append('<li>我是新增的li</li>');
            });
            // 在jQuery中如果通过核心函数找到的元素不止一个，那么在添加事件的时候jQuery会遍历所有找到的元素，给所有找到的元素添加事件
            // $('ul>li').click(function () {
            //     console.log($(this).html());
            // });
            
            $('ul').delegate('li','click',function () {
                console.log($(this).html());
            })
        });

    </script>
</head>
<body>
<ul>
    <li>我是第1个li</li>
    <li>我是第2个li</li>
    <li>我是第3个li</li>
</ul>
<button>新增1个li</button>
</body>
</html>
```

### 事件委托练习
点击登录按钮，出现一个登录界面(其实是个图片),登录界面右上角使用span标签定义了关闭(移除)操作，同时阻止了默认行为

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>32-jQuery事件委托练习</title>
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        html, body {
            width: 100%;
            height: 100%;
        }

        .mask {
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            position: fixed;
            top: 0;
            left: 0;
        }

        .login {
            width: 522px;
            height: 290px;
            margin: 100px auto;
            position: relative;
        }

        .login > span {
            width: 50px;
            height: 50px;
            /*background: red;*/ /*显示出关闭按钮的位置*/
            position: absolute;
            top: 0;
            right: 0;
        }
    </style>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            $('a').click(function () {
                var $mask = $("<div class=\"mask\">\n" +
                    "    <div class=\"login\">\n" +
                    "        <img src=\"images/login.jpg\" alt=\"\">\n" +
                    "        <span></span>\n" +
                    "    </div>\n" +
                    "</div>");
                $('body').append($mask);
                $('body').delegate('.login>span', 'click', function () {
                    $mask.remove();
                });
                return false;
            });
        });

    </script>
</head>
<body>

<a href="http://www.baidu.com">点击登录</a>
<div>
    我是段落
    我是段落
    我是段落
    我是段落
    我是段落
    我是段落
    我是段落
    我是段落
    我是段落
    我是段落
</div>
</body>
</html>
```

## 9.移入移出事件

- mouseenter和mouseleave 
  - 移动到子元素不会触发事件
- mouseover和mouseout 
  - 移动到子元素会触发事件
- hover 
  - 内容监听移入和移出
  - 内部实现就是调用mouseenter和mouseleave

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>33-jQuery移入移出事件</title>
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        .father {
            width: 200px;
            height: 200px;
            background: yellowgreen;
        }

        .son {
            width: 100px;
            height: 100px;
            background: gold;
        }
    </style>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            /*
            * mouseover/mouseout事件，子元素被移入移出也会触发父元素的事件
            * */
            // $(".father").mouseover(function () {
            //     console.log('father被移入了！')
            // });
            // $(".father").mouseout(function () {
            //     console.log('father被移出了！')
            // });

            /*
            * mouseenter/mouseleave事件，子元素被移入移出不会触发父元素的事件
            * 推荐大家使用
            * */
            // $(".father").mouseenter(function () {
            //     console.log('father被移入了！')
            // });
            // $(".father").mouseleave(function () {
            //     console.log('father被移出了！')
            // });

            /*
            * hover事件，第一个函数是监听移入事件，第二个函数是监听移出事件，子元素被移入移出不会触发父元素的事件
            * */
            // $(".father").hover(function () {
            //     console.log('father被移入了！')
            // }, function () {
            //     console.log('father被移出了！')
            // });

            /*
            * hover事件只用一个函数，监听移入和移出事件，子元素被移入移出不会触发父元素的事件
            * */
            $(".father").hover(function () {
                console.log('father被移入移出了！');
            });

        });

    </script>
</head>
<body>
<div class="father">
    <div class="son"></div>
</div>
</body>
</html>
```

## 10. 移入移出练习

- 电影排行榜：鼠标移动到哪一行,哪一行展开效果

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>35-电影排行榜下</title>
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        .box {
            width: 300px;
            height: 450px;
            margin: 50px auto;
            border: 1px solid black;
        }

        .box h1 {
            font-size: 20px;
            line-height: 35px;
            color: deeppink;
            padding-left: 10px;
            border-bottom: 1px dashed #cccccc;
        }

        ul li {
            list-style: none;
            padding: 5px 10px;
            border: 1px dashed #cccccc;

        }

        ul li:nth-child(-n+3) span {
            background: deeppink;
        }

        ul li span {
            display: inline-block;
            width: 20px;
            height: 20px;
            background: #cccccc;
            text-align: center;
            line-height: 20px;
            margin-right: 10px;

        }

        .content {
            overflow: hidden;
            margin-top: 5px;
            display: none;
        }

        .content img {
            width: 80px;
            height: 120px;
            float: left;
        }

        .content p {
            width: 180px;
            height: 120px;
            float: right;
            font-size: 12px;
            line-height: 20px;
        }

        .current .content {
            display: block;
        }
    </style>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            // 1.监听li的移出事件
            // $('li').mouseenter(function () {
            //     $(this).addClass('current');
            // });
            // 2.监听li的移出事件
            // $('li').mouseleave(function () {
            //     $(this).removeClass('current');
            // });

            // 使用hover监听li的移入移出事件
            $('li').hover(function () {
                $(this).addClass('current');
            }, function () {
                $(this).removeClass('current');
            });
        });

    </script>
</head>
<body>
<div class="box">
    <h1>电影排行榜</h1>
    <ul>
        <li><span>1</span>电影名称
            <div class="content">
                <img src="images/3.jpg" alt="">
                <p>这是一段文字介绍这是一段文字介绍这是一段文字介绍这是一段文字介绍这是一段文字介绍
                    这是一段文字介绍这是一段文字介绍这是一段文字介绍
                </p>
            </div>
        </li>
        <li><span>2</span>电影名称
            <div class="content">
                <img src="images/3.jpg" alt="">
                <p>这是一段文字介绍这是一段文字介绍这是一段文字介绍这是一段文字介绍这是一段文字介绍
                    这是一段文字介绍这是一段文字介绍这是一段文字介绍
                </p>
            </div>
        </li>
        <li><span>3</span>电影名称
            <div class="content">
                <img src="images/3.jpg" alt="">
                <p>这是一段文字介绍这是一段文字介绍这是一段文字介绍这是一段文字介绍这是一段文字介绍
                    这是一段文字介绍这是一段文字介绍这是一段文字介绍
                </p>
            </div>
        </li>
        <li><span>4</span>电影名称
            <div class="content">
                <img src="images/3.jpg" alt="">
                <p>这是一段文字介绍这是一段文字介绍这是一段文字介绍这是一段文字介绍这是一段文字介绍
                    这是一段文字介绍这是一段文字介绍这是一段文字介绍
                </p>
            </div>
        </li>
        <li><span>5</span>电影名称
            <div class="content">
                <img src="images/3.jpg" alt="">
                <p>这是一段文字介绍这是一段文字介绍这是一段文字介绍这是一段文字介绍这是一段文字介绍
                    这是一段文字介绍这是一段文字介绍这是一段文字介绍
                </p>
            </div>
        </li>
        <li><span>6</span>电影名称
            <div class="content">
                <img src="images/3.jpg" alt="">
                <p>这是一段文字介绍这是一段文字介绍这是一段文字介绍这是一段文字介绍这是一段文字介绍
                    这是一段文字介绍这是一段文字介绍这是一段文字介绍
                </p>
            </div>
        </li>
    </ul>
</div>
</body>
</html>
```

狼性法则：要培养学生超强的学习能力，一定要培养学生对于客观世界的好奇心，用兴趣来作为他学习的老师。这样的学生在未来的人生道路上，就能不断对工作有新创建和新灵感

- Tab选项卡：鼠标移动到哪个选项卡就显示哪个选项卡对应的图片 


```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>37-Tab选项卡下</title>
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        .box {
            width: 440px;
            height: 298px;
            border: 1px solid black;
            margin: 50px auto;

        }

        .nav li {
            list-style: none;
            width: 110px;
            height: 50px;
            background: orange;
            text-align: center;
            line-height: 50px;
            float: left;

        }

        .nav .current {
            background: #cccccc;
        }

        .content li {
            list-style: none;
            display: none;
        }

        .content .show {
            display: block;
        }
    </style>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            // 1.监听选项卡的移入事件
            $('.nav li').mouseenter(function () {
                // 1.1
                $(this).addClass('current');
                // 1.2还原其他兄弟选项卡的背景颜色
                $(this).siblings().removeClass('current');
                // 1.3获取当前选项卡的索引
                var index = $(this).index();
                // 1,4根据索引找到对应的图片
                var $li = $('.content li').eq(index);
                // 1.5隐藏非当前索引的其他图片
                $li.siblings().removeClass('show');
                // 1.6显示当前对应图片
                $li.addClass('show');
            });
        });

    </script>
</head>
<body>
<div class="box">
    <ul class="nav">
        <li class="current">HTML+CSS</li>
        <li>jQuery</li>
        <li>C语言</li>
        <li>Go语言</li>
    </ul>
    <ul class="content">
        <li class="show"><img src="images/4-1.jpg" alt=""></li>
        <li><img src="images/4-2.jpg" alt=""></li>
        <li><img src="images/4-3.jpg" alt=""></li>
        <li><img src="images/4-4.jpg" alt=""></li>
    </ul>
</div>
</body>
</html>
```


- 鼠标移入到哪个序号就显示哪个序号对应图片

```js
<script type="text/javascript">
    $(function () {
        // 1.监听索引移入事件
        $(".index>li").mouseenter(function () {
            // 2.给移入的索引添加背景,其它索引删除背景
            $(this).addClass("cur").siblings().removeClass("cur");
            // 3.找到当前移入索引的序号
            var $idx = $(this).index();
            // 4.找到序号对应的图片
            var $li = $(".content>li").eq($idx);
            // 5.显示对应图片,并且让其它图片小事
            $li.addClass("show").siblings().removeClass("show");
        });
    });
</script>
```

# 八、动画效果

## 1.显示、隐藏动画

- [show([s,[e\],[fn]])](https://link.jianshu.com?t=http%3A%2F%2Fhemin.cn%2Fjq%2Fshow.html)
- 显示动画
- 内部实现原理根据当前操作的元素是块级还是行内决定, 块级内部调用display:block;,行内内部调用display:inline;

- [hide([s,[e\],[fn]])](https://link.jianshu.com?t=http%3A%2F%2Fhemin.cn%2Fjq%2Fhide.html)
- 隐藏动画

- [toggle([spe\],[eas],[fn])](https://link.jianshu.com?t=http%3A%2F%2Fhemin.cn%2Fjq%2Ftoggle.html)
- 切换动画(显示变隐藏,隐藏变显示)


```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        div {
            width: 200px;
            height: 200px;
            background: red;
            display: none;
        }
    </style>
    <title>39-jQuery显示隐藏动画</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            $('button').eq(0).click(function () {
                // $('div').css('display', 'block');
                // 动画效果，单位毫秒，回调函数:动画执行完毕之后调用
                $('div').show(1000, function () {
                    alert('显示动画执行完毕');
                });
            });
            $('button').eq(1).click(function () {
                // $('div').css('display', 'none');
                $('div').hide(1000, function () {
                    alert('隐藏动画执行完毕');
                });
            });
            $('button').eq(2).click(function () {
                $('div').toggle(1000, function () {
                    alert('切换动画执行完毕');
                });
            });
        });

    </script>
</head>
<body>
<button>显示</button>
<button>隐藏</button>
<button>切换</button>
<div></div>
</body>
</html>
```

- 注意事项: 
  - show(1000, function () {};) 第一个参数单位是毫秒, 1000毫秒等于1秒
  - 默认的动画时长是400毫秒
  - 除了指定毫秒以外还可以指定三个预设参数 slow、normal、fast 
    - slow本质是600毫秒
    - normal本质是400毫秒
    - fast本质是200毫秒
  - 其它两个方法同理可证

- 对联广告：页面滚动显示

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>40-对联广告</title>
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        .left {
            float: left;
            position: fixed;
            left: 0;
            top: 200px;
        }

        .right {
            float: right;
            position: fixed;
            right: 0;
            top: 200px;
        }

        img {
            width: 200px;
            display: none;
        }

    </style>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            // 1.监听网页滚动
            $(window).scroll(function () {
                // console.log("网页滚动了");
                // console.log($("html,body").scrollTop());
                // 1.1获取网页滚动的偏移位
                var offset = $("html,body").scrollTop();
                if (offset > 500) {
                    // 1.3显示广告
                    $('img').show(1000);
                } else {
                    $('img').hide(1000);
                }
            })
        });

    </script>
</head>
<body>
<img src="images/5.jpg" alt="" class="left">
<img src="images/5.jpg" alt="" class="right">
<br/>
<br/>
<br/>
<br/>
<br/>
....

<!-- 还有很多`<br/>`，目的是页面上出现滚动条-->

</body>
</html>

```


## 2. 展开、收起动画

- 参数、注意事项和显示隐藏动画一模一样, 只不过动画效果不一样而已
- [slideDown([s\],[e],[fn])](https://link.jianshu.com?t=http%3A%2F%2Fhemin.cn%2Fjq%2FslideDown.html)
- 展开动画
- [slideUp([s,[e\],[fn]])](https://link.jianshu.com?t=http%3A%2F%2Fhemin.cn%2Fjq%2FslideUp.html)
- 收起动画
- [slideToggle([s\],[e],[fn])](https://link.jianshu.com?t=http%3A%2F%2Fhemin.cn%2Fjq%2FslideToggle.html)
- 切换动画(展开变收起,收起变展开)


```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>41-jQuery展开和收起动画</title>
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        div {
            width: 100px;
            height: 300px;
            background: red;
            display: none;
        }
    </style>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            $('button').eq(0).click(function () {
                $('div').slideDown(1000, function () {
                    alert('展开完毕')
                });
            });
            $('button').eq(1).click(function () {
                $('div').slideUp(1000, function () {
                    alert('收起完毕')
                });
            });
            $('button').eq(2).click(function () {
                $('div').slideToggle(1000, function () {
                    alert('切换完毕')
                });
            });
        });

    </script>
</head>
<body>
<button>展开</button>
<button>收起</button>
<button>切换</button>
<div></div>
</body>
</html>
```

- 练习：折叠菜单


```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        .nav {
            list-style: none;
            width: 300px;
            margin: 100px auto;
            /*border: 1px solid #000000;*/
        }

        .nav > li {
            border: 1px solid #000000;
            line-height: 35px;
            border-bottom: none;
            text-indent: 2em;
            position: relative;
        }

        /*注意：此处一定要使用>来表示特定的子元素*/
        .nav > li:last-child {
            border-bottom: 1px solid #000000;
            border-bottom-right-radius: 10px;
            border-bottom-left-radius: 10px;
        }

        /*注意：此处一定要使用>来表示特定的子元素*/
        .nav > li:first-child {
            border-top-right-radius: 10px;
            border-top-left-radius: 10px;
        }

        .nav > li > span {
            /*此处是向右箭头的图片*/
            background: url("images/arrow-right.jpg") no-repeat center center;
            display: inline-block;
            width: 32px;
            height: 32px;
            position: absolute;
            right: 10px;
            top: 3px;
        }

        .sub {
            display: none;
        }

        .sub > li {
            list-style: none;
            background: mediumpurple;
            border-bottom: 1px solid white;
        }

        .sub > li:hover {
            background: red;
        }

        .nav > .current > span {
            transform: rotate(90deg);
        }
    </style>
    <title>43-折叠菜单下</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            // 1.监听一级菜单点击事件
            $(".nav>li").click(function () {
                // 1.1 拿到二级菜单
                var $sub = $(this).children('.sub');
                // 1.2 让二级菜单展开
                $sub.slideDown(1000);
                // 1.3 拿到所有非当前的二级菜单
                var otherSub = $(this).siblings().children('.sub');
                // 1.4 让所有非当前的二级菜单收起
                otherSub.slideUp(1000);
                // 1.5 让被点击的一级菜单箭头朝下
                $(this).addClass('current');
                // 1.6 让所有非被点击的一级菜单箭头还原
                $(this).siblings().removeClass('current');
            });
        });

    </script>
</head>
<body>
<ul class="nav">
    <li>一级菜单<span></span>
        <ul class="sub">
            <li>二级菜单</li>
            <li>二级菜单</li>
            <li>二级菜单</li>
            <li>二级菜单</li>
        </ul>
    </li>
    <li>一级菜单<span></span>
        <ul class="sub">
            <li>二级菜单</li>
            <li>二级菜单</li>
            <li>二级菜单</li>
            <li>二级菜单</li>
        </ul>
    </li>
    <li>一级菜单<span></span>
        <ul class="sub">
            <li>二级菜单</li>
            <li>二级菜单</li>
            <li>二级菜单</li>
            <li>二级菜单</li>
        </ul>
    </li>
    <li>一级菜单<span></span>
        <ul class="sub">
            <li>二级菜单</li>
            <li>二级菜单</li>
            <li>二级菜单</li>
            <li>二级菜单</li>
        </ul>
    </li>
    <li>一级菜单<span></span></li>
    <li>一级菜单<span></span></li>
    <li>一级菜单<span></span></li>
    <li>一级菜单<span></span></li>
</ul>
</body>
</html>
```

- 练习：下拉菜单


```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>44-下拉菜单</title>
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        .nav {
            list-style: none;
            width: 300px;
            height: 50px;
            background: red;
            margin: 100px auto;
        }

        .nav > li {
            width: 100px;
            height: 50px;
            line-height: 50px;
            text-align: center;
            float: left;
        }

        .sub {
            list-style: none;
            background: mediumaquamarine;
            display: none;
        }
    </style>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            /*
            * 在jQuery中如果需要执行动画，建议在执行动画之前先调用stop方法，然后再执行动画
            * */
            // 1.监听一级菜单的移入事件
            $('.nav>li').mouseenter(function () {
                // 1.1 拿到二级菜单
                $sub = $(this).children('.sub');
                // 停止当前正在运行的动画
                $sub.stop();
                // 1.2 展开二级菜单
                $sub.slideDown(1000);
            });
            // 2.监听一级菜单的移除事件
            $('.nav>li').mouseleave(function () {
                // 2.1 拿到二级菜单
                $sub = $(this).children('.sub');
                // 停止当前正在运行的动画
                $sub.stop();
                // 2.2 展开二级菜单
                $sub.slideUp(1000);
            });
        });

    </script>
</head>
<body>

<ul class="nav">
    <li>一级菜单
        <ul class="sub">
            <li>二级菜单</li>
            <li>二级菜单</li>
            <li>二级菜单</li>
            <li>二级菜单</li>
            <li>二级菜单</li>
        </ul>
    </li>
    <li>一级菜单</li>
    <li>一级菜单</li>
</ul>
</body>
</html>

```

## 3. 淡入、淡出动画

- 参数、注意事项和显示隐藏动画一模一样, 只不过动画效果不一样而已
- [fadeIn([s\],[e],[fn])](https://link.jianshu.com?t=http%3A%2F%2Fhemin.cn%2Fjq%2FfadeIn.html)
- 淡入动画
- [fadeOut([s\],[e],[fn])](https://link.jianshu.com?t=http%3A%2F%2Fhemin.cn%2Fjq%2FfadeOut.html)
- 淡出动画
- [fadeToggle([s,[e\],[fn]])](https://link.jianshu.com?t=http%3A%2F%2Fhemin.cn%2Fjq%2FfadeToggle.html)
- 切换动画(显示变淡出,不显示变淡入)
- [fadeTo([[s\],o,[e],[fn]])](https://link.jianshu.com?t=http%3A%2F%2Fhemin.cn%2Fjq%2FfadeTo.html)
- 淡入到指定透明度动画
- 可以通过第二个参数,淡入到指定的透明度(取值范围0~1)


```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>45-jQuery淡入淡出动画</title>
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        div {
            width: 100px;
            height: 100px;
            background: red;
            display: none;
        }
    </style>

    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            $('button').eq(0).click(function () {
                $('div').fadeIn(1000, function () {
                    alert('淡入完毕');
                });
            });
            $('button').eq(1).click(function () {
                $('div').fadeOut(1000, function () {
                    alert('淡出完毕');
                });
            });
            $('button').eq(2).click(function () {
                $('div').fadeToggle(1000, function () {
                    alert('切换完毕');
                });
            });
            $('button').eq(3).click(function () {
                // 第二个参数表示淡入淡出的程度,范围0~1
                $('div').fadeTo(1000, 0.5, function () {
                    alert('切换完毕');
                });
            });
        });

    </script>
</head>
<body>
<button>淡入</button>
<button>淡出</button>
<button>切换</button>
<button>淡入到</button>
<div></div>
</body>
</html>
```

- 练习：弹窗广告
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>46-弹窗广告</title>
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        .ad {
            position: fixed;
            right: 0;
            bottom: 0;
            display: none;
        }

        .ad > span {
            display: inline-block;
            width: 30px;
            height: 30px;
            /*background: red;*/
            position: absolute;
            top: 0;
            right: 0;
        }
    </style>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            //1.监听span的监听事件
            $('span').click(function () {
                $(".ad").remove();
            });
            // 2.执行广告动画
            // $('.ad').slideDown(1000,function () {
            //     $('.ad').fadeOut(1000,function () {
            //         $('.ad').fadeIn(1000);
            //     });
            // });

            // 链式写法
            $('.ad').stop().slideDown(1000).fadeOut(1000).fadeIn(1000);

        });

    </script>
</head>
<body>
<div class="ad">
    <img src="images/ad-pic.jpg" alt="">
    <span></span>
</div>
</body>
</html>

```


## 4. 自定义动画

- 有时候jQuery中提供的集中简单的固定动画无法满足我们的需求, 所以jQuery还提供了一个自定义动画方法来满足我们复杂多变的需求
- [animate(p,[s\],[e],[fn])](https://link.jianshu.com?t=http%3A%2F%2Fhemin.cn%2Fjq%2Fanimate.html)
- 每次开始运动都必须是初始位置或者初始状态,如果想在上一次位置或者状态下再次进行动画可以使用累加动画
- 同时操作多个属性,自定义动画会执行同步动画,多个被操作的属性一起执行动画


```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>47-jQuery自定义动画</title>
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        div {
            width: 100px;
            height: 100px;
            margin-top: 10px;
            background: red;
        }

        .two {
            background: blue;
        }
    </style>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {

            $('button').eq(0).click(function () {
                /*
                $('.one').animate({
                    width: 500,
                }, 1000, function () {
                    alert('自定义动画执行完毕');
                });
                */
                $('.one').animate({
                    marginLeft: 500,
                }, 5000, function () {
                    alert('自定义动画执行完毕');
                });
                /*
                * 第一个参数：接收一个对象，可以在对象中修改属性
                * 第二个参数：指定动画时长
                * 第三个参数：指定动画节奏，默认是swing
                * 第四个参数：指定动画执行完毕之后的回调函数
                * */
                $('.two').animate({
                    marginLeft: 500,
                }, 5000, 'linear', function () {
                    alert('自定义动画执行完毕');
                });
            });

            $('button').eq(1).click(function () {
                $('.one').animate({
                    // 字符串，表示在原有基础上进行累加
                    width: '+=100'
                }, 1000, function () {
                    alert('自定义动画执行完毕');
                });
            });

            $('button').eq(2).click(function () {
                $('.one').animate({
                    // 字符串，hide：隐藏，toggle：切换
                    width: 'toggle'
                }, 1000, function () {
                    alert('自定义动画执行完毕');
                });
            });
        });

    </script>
</head>
<body>
<button>操作属性</button>
<button>累加属性</button>
<button>关键字</button>
<div class="one"></div>
<div class="two"></div>
</body>
</html>
```

- 练习：图标特效


```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>49-图标特效</title>
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        ul {
            list-style: none;
            width: 400px;
            height: 250px;
            border: 1px solid #000000;
            margin: 100px auto;
        }

        ul > li {
            width: 100px;
            height: 50px;
            margin-top: 50px;
            text-align: center;
            float: left;
            overflow: hidden;
        }

        ul > li > span {
            display: inline-block;
            width: 24px;
            height: 24px;
            background: url("images/1.jpg") no-repeat 0 0;
            position: relative;
        }
    </style>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            // 1.遍历所有的li
            $('li').each(function (index, value) {
                // 1.1生成新的图片位置
                var $url = 'background: url("images/1.jpg") no-repeat 0' + (index * -24) + 'px';
                // 1.2设置新的图片位置
                $(this).children('span').css("background", $url);
            });

            // 2.监听li移入事件
            $('li').mouseenter(function () {
                // 2.1将图片往上移动
                $(this).children('span').animate({
                    top: -50
                }, 1000, function () {
                    // 2.2将图片往下移动
                    $(this).css('top', '50px');
                    // 2.3将图片复位
                    $(this).animate({
                        top: 0
                    }, 1000);
                })
            });
        });

    </script>
</head>
<body>
<ul>
    <li><span></span>
        <p>百度</p></li>
    <li><span></span>
        <p>百度</p></li>
    <li><span></span>
        <p>百度</p></li>
    <li><span></span>
        <p>百度</p></li>
    <li><span></span>
        <p>百度</p></li>
    <li><span></span>
        <p>百度</p></li>
    <li><span></span>
        <p>百度</p></li>
    <li><span></span>
        <p>百度</p></li>

</ul>
</body>
</html>
```


## 5.  动画队列

- 多个动画方法链式编程,会等到前面的动画执行完毕再依次执行后续动画

```
$("div").slideDown(1000).slideUp(1000).show(1000);

$(".one").slideDown(1000,function () {
    $(".one").slideUp(1000, function () {
        $(".one").show(1000);
    });
});
```

- 但是如果后面紧跟一个非动画方法则会被立即执行

```
// 立刻变为黄色,然后再执行动画
$(".one").slideDown(1000).slideUp(1000).show(1000).css("background", "yellow");
```

- 如果想颜色再动画执行完毕之后设置, 1.使用回调 2.使用动画队列

```
$(".one").slideDown(1000,function () {
    $(".one").slideUp(1000, function () {
        $(".one").show(1000, function () {
            $(".one").css("background", "yellow")
        });
    });
});

$(".one").slideDown(1000).slideUp(1000).show(1000).queue(function () {
    $(".one").css("background", "yellow")
});
```

- 注意点: 
  - 动画队列方法queue()后面不能继续直接添加queue()
  - 如果想继续添加必须在上一个queue()方法中next()方法

```
$(".one").slideDown(1000).slideUp(1000).show(1000).queue(function (next) {
    $(".one").css("background", "yellow");
    next(); // 关键点
}).queue(function () {
    $(".one").css("width", "500px")
});
```


## 6.  动画相关方法

- delay(d,[q])
  - 设置动画延迟时长
- - [stop([c\],[j])](https://link.jianshu.com?t=http%3A%2F%2Fhemin.cn%2Fjq%2Fstop.html)
  - 停止指定元素上正在执行的动画


```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        .one {
            width: 100px;
            height: 100px;
            background: red;
        }

        .two {
            width: 500px;
            height: 10px;
            background: blue;
        }
    </style>
    <title>48-jQuery的stop和delay方法</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            $('button').eq(0).click(function () {
                // 在jQuery的{}中可以同时修改多个属性，中间用逗号隔开，多个属性的动画会同时执行
                /*
                $('.one').animate({
                    width: 500,
                    height: 500
                }, 1000);
                */

                // 分开写可以分别执行
                /*
                $('.one').animate({
                    width: 500
                }, 1000);
                $('.one').animate({
                    height: 500
                }, 1000);
                */

                // 使用链式写法
                // delay方法的作用就是用于高速系统延迟时长
                $('.one').animate({
                    width: 500
                }, 1000).delay(2000).animate({
                    height: 500
                }, 1000).animate({width: 100}, 1000).animate({height: 100}, 1000);
            });
            $('button').eq(1).click(function () {
                // 立即停止当前动画，继续执行后续动画
                // $('div').stop();
                // $('div').stop(false);
                // $('div').stop(false,false);

                // 立即停止当前动画和后续所有动画
                // $('div').stop(true);
                // $('div').stop(true,false);

                // 立即完成当前的，继续执行后续动画
                // $('div').stop(false,true);

                // 立即完成当前的，并且停止后续所有的
                $('div').stop(true, true);
            });
        });

    </script>
</head>
<body>
<button>开始动画</button>
<button>停止动画</button>
<div class="one"></div>
<div class="two"></div>
</body>
</html>

```

- 练习：无限循环滚动


```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>51-无限循环滚动下</title>
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        div {
            width: 600px;
            height: 161px;
            border: 1px solid #000000;
            margin: 100px auto;
            overflow: hidden;
        }

        ul {
            list-style: none;
            width: 1800px;
            height: 161px;
            background: black;

        }

        ul > li {
            float: left;
        }
    </style>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            // 0.定义变量保存偏移位
            var offset = 0;
            // 1.让图片滚动起来
            var timer;

            function autoPlay() {
                timer = setInterval(function () {
                    offset += -10;
                    if (offset <= -1200) {
                        offset = 0;
                    }
                    $('ul').css('marginLeft', offset)
                }, 50);
            }

            autoPlay();

            // 2.监听li的移入和移出事件
            $('li').hover(function () {
                // 停止滚动
                clearInterval(timer);
                // 给非当前选中的添加蒙版
                $(this).siblings().fadeTo(100, 0.5);
                // 去除当前选中蒙版
                $(this).fadeTo(100, 1)
            }, function () {
                // 继续滚动
                autoPlay();
                // 去除所有蒙版
                $('li').fadeTo(100, 1);
            })
        });

    </script>
</head>
<body>
<div>
    <ul>
        <li><img src="images/a.jpg" alt=""></li>
        <li><img src="images/b.jpg" alt=""></li>
        <li><img src="images/c.jpg" alt=""></li>
        <li><img src="images/d.jpg" alt=""></li>
        <li><img src="images/a.jpg" alt=""></li>
        <li><img src="images/b.jpg" alt=""></li>
    </ul>
</div>
</body>
</html>

```

# 九、文档处理

## 1. 添加节点

- 内部插入
- [append(content|fn)](https://link.jianshu.com?t=http%3A%2F%2Fhemin.cn%2Fjq%2Fappend.html)
- appendTo(content)
  - 将元素添加到指定元素内部的最后
- [prepend(content|fn)](https://link.jianshu.com?t=http%3A%2F%2Fhemin.cn%2Fjq%2Fprepend.html)
- prependTo(content)
  - 将元素添加到指定元素内部的最前面

- 外部插入
- [after(content|fn)](https://link.jianshu.com?t=http%3A%2F%2Fhemin.cn%2Fjq%2Fafter.html)
- insertAfter(content)
  - 将元素添加到指定元素外部的后面
- [before(content|fn)](https://link.jianshu.com?t=http%3A%2F%2Fhemin.cn%2Fjq%2Fbefore.html)
- insertBefore(content)
  - 将元素添加到指定元素外部的前面


```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>52-jQuery添加节点相关方法</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            /*
            内部插入
            append(content|fn) ：会将元素添加到指定元素内部的最后
            appendTo(content)  ：会将元素添加到指定元素内部的最后
            prepend(content|fn)：会将元素添加到指定元素内部的最前面
            prependTo(content) ：会将元素添加到指定元素内部的最前面

            外部插入
            after(content|fn)  ：会将元素添加到指定元素外部的后面
            before(content|fn) ：会将元素添加到指定元素外部的前面
            insertAfter(content)  ：会将元素添加到指定元素外部的后面
            insertBefore(content) ：会将元素添加到指定元素外部的前面

            *
            *
            */

            $('button').click(function () {
                // 1.创建一个节点
                var $li = $('<li>新增的li</li>');
                // 2.添加节点
                // $('ul').append($li);
                // $('ul').prepend($li);
                // 注意点：作用一样但是写法不一样
                // $li.appendTo('ul');
                // $li.prependTo('ul');

                // $('ul').after($li);
                // $('ul').before($li);

                // $li.insertAfter('ul');
                $li.insertBefore('ul');

            });
        });

    </script>
</head>
<body>
<button>添加节点</button>
<ul>
    <li>我是第1个li</li>
    <li>我是第2个li</li>
    <li>我是第3个li</li>
</ul>
</body>
</html>

```

## 2.  删除节点

- empty()
  - 删除指定元素的内容和子元素, 指定元素自身不会被删除
- remove([expr])
  - 删除指定元素
- detach([expr])
- remove和detach区别 
  - remove删除元素后,元素上的事件会被移出
  - detach删除元素后,元素上的事件会被保留


```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>53-jQuery删除节点相关方法</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            /*
            删除
            remove([expr]) : 删除指定元素
            empty() :  删除指定元素的内容和子元素，指定元素自身不会被删除
            detach([expr]) ：等用于remove([expr])
            * */
            $('button').click(function () {
                // $('div').remove();
                $('div').empty();
            });
        });

    </script>
</head>
<body>
<button>删除节点</button>
<ul>
    <li class="item">我是第1个li</li>
    <li>我是第2个li</li>
    <li class="item">我是第3个li</li>
    <li>我是第4个li</li>
    <li class="item">我是第5个li</li>
</ul>
<div>我是div
    <p>我是一个段落</p>
</div>
</body>
</html>
```

## 3. 替换节点

- replaceWith(content|fn)
  - 将所有匹配的元素替换成指定的HTML或DOM元素
  - replaceWith参数可以是一个DOM元素
  - replaceWith参数也可以是一个代码片段
- replaceAll(selector)
  - 用匹配的元素替换掉所有 selector匹配到的元素


```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>54-jQuery替换节点相关方法</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            /*
            替换
            replaceWith(content|fn)
            replaceAll(selector)
            作用:替换所有匹配的元素为指定的元素
            */
            $('button').click(function () {
                // 1.新建一个元素
                var $h6 = $('<h6>我是标题6</h6>');
                // 2.替换元素
                // $('h1').replaceWith($h6);
                $h6.replaceAll('h1');

            });
        });

    </script>
</head>
<body>
<button>替换节点</button>
<h1>我是标题1</h1>
<h1>我是标题1</h1>
<p>我是段落</p>
</body>
</html>
```


## 4.  复制节点

- [clone([Even[,deepEven\]])](https://link.jianshu.com?t=http%3A%2F%2Fhemin.cn%2Fjq%2Fclone.html)
- 复制一个节点
- 浅复制不会复制节点的事件
- 深复制会复制节点的事件


```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>55-jQuery复制节点相关方法</title>
    <script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
    <script type="text/javascript">

        $(function () {
            // 复制
            // clone([Even[,deepEven]])
            // 如果传入false就是浅复制，如果传入true就是深复制
            // 浅复制只会复制元素，不会复制元素的事件
            // 深复制会复制元素，而且还会复制元素的事件
            $('button').eq(0).click(function () {
                // 1.浅复制一个元素
                var $li = $('li:first').clone(false);
                // 2.将复制的元素添加到ul中
                $('ul').append($li);
            });
            $('button').eq(1).click(function () {
                // 1.深复制一个元素
                var $li = $('li:first').clone(true);
                // 2.将复制的元素添加到ul中
                $('ul').append($li);
            });

            $('li').click(function () {
                alert('li');
            });
        });

    </script>
</head>
<body>
<button>浅复制节点</button>
<button>深复制节点</button>
<ul>
    <li>我是第1个li</li>
    <li>我是第2个li</li>
    <li>我是第3个li</li>
    <li>我是第4个li</li>
    <li>我是第5个li</li>
</ul>
</body>
</html>
```


## 5. 包裹节点

- 都讲了这么多了, 骚年动动手, 查阅下文档, 尝试下自学这几个方法
- 编程不是死记硬背, 是学会找到解决问题的思路和自学新知识的方法

## 6.  节点操作练习

![img](https:////upload-images.jianshu.io/upload_images/647982-bf214e85239fa278.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000)

