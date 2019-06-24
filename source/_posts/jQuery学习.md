---
title: jQuery学习
date: 2019-06-17 09:04:45
tags: 
- JavaScript 
- jQuery 
categories: 
- JavaScript 
- jQuery
---
# 1. jquery介绍

jQuery的版本分为1.x系列和2.x、3.x系列，1.x系列兼容低版本的浏览器，2.x、3.x系列放弃支持低版本浏览器，目前使用最多的是1.x系列的。

jquery是一个函数库，一个js文件，页面用script标签引入这个js文件就可以使用。
```html
<script type="text/javascript" src="jquery-3.3.1.min.js"></script>
```

jquery的口号和愿望 Write Less, Do More（写得少，做得多）。

1、官方网站 <http://jquery.com/> 
2、版本下载 <https://code.jquery.com/>

<escape><!-- more --></escape>

# 2. jquery加载

将获取元素的语句写到页面头部，会因为元素还没有加载而出错，jquery提供了ready方法解决这个问题，它的速度比原生的 window.onload 更快。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
    <script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
    <script type="text/javascript">
        // 原生js写法
        window.onload = function () {
            var oDiv = document.getElementById('div1');
            alert('原生弹出的'+oDiv);
        };

		// ready 比window.onload 要快：
		// 原因是，window.onload是等标签加载完后，再渲染完之后才运行，
		// ready是等标签加载完后就运行
		
        // jquery写法,ready的完整写法
        $(document).ready(function () {
            var $div = $('#idv1');
            alert('jquery弹出的'+$div);
        });
        
        // jquery写法,ready的简写写法
        $(function () {
            var $div = $('#idv1');
            alert('jquery弹出的-2'+$div);
        })

    </script>
</head>
<body>

<div id="div1">这是一个div元素</div>

</body>
</html>
```

## 2.1 jquery引入容易出错的写法

```html
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Document</title>
	<!--  不能直接在jquery的引入标签里写js代码，需要另外写一个script标签，在这个标签里面写js代码   -->
	<script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
    <script type="text/javascript">
		$(function(){

		});
	</script>

</head>
<body>
	<div id="div1">div元素</div>
</body>
</html>
```

# 3. jquery选择器

jquery用法思想一
选择某个网页元素，然后对它进行某种操作 

## 3.1 jquery选择器

jquery选择器可以快速地选择元素，选择规则和css样式相同，使用length属性判断是否选择成功。

```js
$('#myId') //选择id为myId的网页元素
$('.myClass') // 选择class为myClass的元素
$('li') //选择所有的li元素
$('#ul1 li span') //选择id为为ul1元素下的所有li下的span元素
$('input[name=first]') // 选择name属性等于first的input元素
```

```html
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Document</title>
	<script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
	<script type="text/javascript">		
		$(function(){
			
			// 代替css改变元素样式
			
			var $div = $('#div1');
			$div.css({'color':'red'}); // 样式使用python字典的写法

            // 使用jquery的话，两个选择的元素都发生变化
			var $div2 = $('.box');
			$div2.css({'color':'green'});

			var $li = $('.list li');
			// 带“-”的样式属性，可以写成驼峰式，也可以写成原始
			$li.css({'background-color':'pink','color':'red'});

		});

	</script>
</head>

<body>
	<div id="div1">这是一个div元素</div>

	<div class="box">这是第二个div元素</div>
	<div class="box">这是第三个div元素</div>

	<!-- ul.list>li{$}*8 -->

	<ul class="list">
		<li>1</li>
		<li>2</li>
		<li>3</li>
		<li>4</li>
		<li>5</li>
		<li>6</li>
		<li>7</li>
		<li>8</li>
	</ul>

</body>
</html>
```

## 3.2 对选择集进行过滤 

```js
$('div').has('p'); // 选择包含p元素的div元素
$('div').not('.myClass'); //选择class不等于myClass的div元素
$('div').filter('.myClass'); //选择class等于myClass的div元素
$('div').eq(5); //选择第6个div元素
```

```html
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Document</title>
	<script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
	<script type="text/javascript">
		$(function(){

			/* 完整写法
			var $div = $('div');
			$div.css({'backgroundColor':'gold'});
			*/
			
             // 省略写法 
			$('div').css({'backgroundColor':'gold'});
			$('div').has('p').css({'fontSize':'30px'});
			$('div').eq(4).css({'textIndent':'20px'}); // 这里面的4表示的是从0开始的第四个元素，在这里指的是<div>5</div>

        })
	</script>
</head>
<body>
	<div>1</div>
	<div>
        <p>2</p>
    </div>
	<div>3</div>
	<div>4</div>
	<div>5</div>
	<div>6</div>
	<div>7</div>
	<div>
        <span>8</span>
        <span class="tip">9</span>
    </div>
</body>
</html>
```

## 3.3 选择集转移

```js
$('div').prev(); //选择div元素前面紧挨的同辈元素
$('div').prevAll(); //选择div元素之前所有的同辈元素
$('div').next(); //选择div元素后面紧挨的同辈元素
$('div').nextAll(); //选择div元素后面所有的同辈元素
$('div').parent(); //选择div的父元素
$('div').children(); //选择div的所有子元素
$('div').siblings(); //选择div的同级元素
$('div').find('.myClass'); //选择div内的class等于myClass的元素
```

```html
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Document</title>
	<script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
	<script type="text/javascript">
		$(function(){

			/* 完整写法
			var $div = $('div');
			$div.css({'backgroundColor':'gold'});
			*/
			
             // 省略写法 
			$('div').eq(4).prev().css({'color':'red'});
			$('div').find('.tip').css({'fontSize':'30px'});

		})
	</script>
</head>
<body>
	<div>3</div>
	<div>4</div>
	<div>5</div>
	<div>6</div>
	<div>7</div>
	<div>
        <span>8</span>
        <span class="tip">9</span>
    </div>
</body>
</html>
```

## 3.4 判断是否选择到了元素

jquery有容错机制，即使没有找到元素，也不会出错，可以用length属性来判断是否找到了元素,length等于0，就是没选择到元素，length大于0，就是选择到了元素。

```js
var $div1 = $('#div1');
var $div2 = $('#div2');
alert($div1.length); // 弹出1
alert($div2.length); // 弹出0
......
<div id="div1">这是一个div</div>
```

```html
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Document</title>
	<script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
	<script type="text/javascript">
		$(function(){

			$div = $('#div1');
			alert($div.length);

			// 没有选中元素，也不会报错，程序正常运行
			$div2 = $('#div2');

			alert($div2.length);
			// if($div2.length>0) 通过length属性来判断是否选中了元素
		})
	</script>
</head>
<body>
	<div id="div1">div元素</div>
</body>
</html>
```

# ４. jquery样式操作

 jquery用法思想二
同一个函数完成取值和赋值

## 4.1 操作行间样式 

```js
// 获取div的样式
$("div").css("width");
$("div").css("color");

//设置div的样式
$("div").css("width","30px"); // 没有用大括号，中间是逗号
$("div").css({"width":"30px"}); // 使用大括号，中间是冒号
$("div").css({fontSize:"30px",color:"red"});
```

特别注意
选择器获取的多个元素，获取信息获取的是第一个，比如：$("div").css("width")，获取的是第一个div的width。

```html
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Document</title>
	<script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
	<script type="text/javascript">
		$(function(){

			var $div = $('#box');

			// 读取属性值
			var sTr = $div.css('fontSize');
			alert(sTr);

			// 写属性值
			$div.css({'color':'red','backgroundColor':'pink','fontSize':'20px'});

			/*
			原生js无法读取行间没有定义的css属性值
			var oDiv = document.getElementById('box');
			alert(oDiv.style.fontSize);
			*/

		})

	</script>
</head>
<body>
	<div id="box">div元素</div>
</body>
</html>
```

## 4.2 操作样式类名 

```js
$("#div1").addClass("divClass2") //为id为div1的对象追加样式divClass2
$("#div1").removeClass("divClass")  //移除id为div1的对象的class名为divClass的样式
$("#div1").removeClass("divClass divClass2") //移除多个样式
$("#div1").toggleClass("anotherClass") //重复切换anotherClass样式
```

```html
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Document</title>
	<script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
	<script type="text/javascript">
		$(function(){

			var $div = $('.box');

			// 在原来样式名的基础上加上“big”的样式名
			$div.addClass('big');

			// 在原来样式名的基础上去掉“red”的样式名
			$div.removeClass('red');
			
		})

	</script>
	<style type="text/css">
		
		.box{
			width:100px;
			height:100px;
			background-color:gold;
		}

		.big{
			font-size:30px;
		}

		.red{
			color:red;
		}

	</style>
</head>
<body>
	<div class="box red">div元素</div>
</body>
</html>
```

# 5. 绑定click事件

## 5.1 给元素绑定click事件

```js
$('#btn1').click(function(){

    // 内部的this指的是原生对象
    // 使用jquery对象用 $(this)

})
```

```html
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Document</title>
	<script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
	<script type="text/javascript">
		$(function(){
			
			// 绑定click事件
			$('#btn').click(function(){

				/*
				if($('.box').hasClass('col01')){
					$('.box').removeClass('col01');
				}
				else {
					$('.box').addClass('col01');
				}
				*/
                
                // 简化成下面的写法：
				$('.box').toggleClass('col01');
			})

		})

	</script>
    <style type="text/css">
        .box{
            width:200px;
            height:200px;
            background-color:gold;
        }
        .col01{
            background-color:green;
        }
    </style>
</head>
<body>
	<input type="button" name="" value="切换样式" id="btn">
	<div class="box">div元素</div>
</body>
</html>
```

## 5.2 获取元素的索引值 

```js
var $li = $('.list li').eq(1);
alert($li.index()); // 弹出1
......
<ul class="list">
    <li>1</li>
    <li>2</li>
    <li>4</li>
    <li>5</li>
    <li>6</li>
</ul>
```

```html
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Document</title>
	<script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
	<script type="text/javascript">
		$(function(){

			var $li = $('.list li');

			//alert($li.length); // 弹出 8
			//alert($li.eq(3).index());  // 弹出3

			alert( $li.filter('.myli').index() ); // 弹出4

		})


	</script>
</head>
<body>
	<ul class="list">
		<li>1</li>
		<li>2</li>
		<li>3</li>
		<li>4</li>
		<li class="myli">5</li>
		<li>6</li>
		<li>7</li>
		<li>8</li>
	</ul>
</body>
</html>
```

## 5.3 选项卡练习
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Document</title>

    <script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
    <script type="text/javascript">
        $(function () {
            var $btn = $('.btns input');
            var $div = $('.cons div');

            $btn.click(function () {
                // this 指的是原生的this，它表示当前点击的对象，使用jquery的对象需要用$(this)

                // 当前点击的按钮加上current样式后，除了当前，其他的按钮去掉current样式
                $(this).addClass('current').siblings().removeClass('current');

                //alert( $(this).index() ; //弹出当前按钮的索引值
                // 当前点击的按钮对应索引值的div加上active样式，其他的去掉active样式
                $div.eq($(this).index()).addClass('active').siblings().removeClass('active');
            })
        })

    </script>

    <style type="text/css">
        .btns input {
            width: 100px;
            height: 40px;
            background-color: #ddd;
            border: 0;
        }

        .btns .current {
            background-color: gold;
        }


        .cons div {
            width: 500px;
            height: 300px;
            background-color: gold;
            display: none;
            text-align: center;
            line-height: 300px;
            font-size: 30px;
        }

        .cons .active {
            display: block;
        }

    </style>
</head>
<body>
<div class="btns">
    <input type="button" name="" value="01" class="current">
    <input type="button" name="" value="02">
    <input type="button" name="" value="03">
</div>
<div class="cons">
    <div class="active">选项卡一的内容</div>
    <div>选项卡二的内容</div>
    <div>选项卡三的内容</div>
</div>
</body>
</html>
```

# 6. jquery特殊效果

```text
fadeIn() 淡入
fadeOut() 淡出
fadeToggle() 切换淡入淡出
hide() 隐藏元素
show() 显示元素
toggle() 切换元素的可见状态
slideDown() 向下展开
slideUp() 向上卷起
slideToggle() 依次展开或卷起某个元素
```

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Document</title>
    <script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
    <script type="text/javascript">
        $(function () {
            $('#btn').click(function () {
                
                //$('.box').fadeIn();
                
                //$('.box').fadeIn(1000,function(){
                //    alert('动画完了！');
                //});

                $('.box').fadeToggle(1000,function(){
                    alert('动画完了！');
                });

                // $('.box').show();

                //$('.box').toggle();

                //$('.box').slideDown();

                //$('.box').slideToggle(1000, function () {
                //    alert('动画完了')
                //});


            });

        })

    </script>
    <style type="text/css">
        .box {
            width: 300px;
            height: 300px;
            background-color: gold;
            display: none;
        }
    </style>
</head>

<body>
    <input type="button" name="" value="动画" id="btn">
    <div class="box"></div>
</body>
</html>
```

# 7. jquery链式调用

jquery对象的方法会在执行完后返回这个jquery对象，所有jquery对象的方法可以连起来写

```js
$('#div1') // id为div1的元素
.children('ul') //该元素下面的ul子元素
.slideDown('fast') //高度从零变到实际高度来显示ul元素
.parent()  //跳到ul的父元素，也就是id为div1的元素
.siblings()  //跳到div1元素平级的所有兄弟元素
.children('ul') //这些兄弟元素中的ul子元素
.slideUp('fast');  //高度实际高度变换到零来隐藏ul元素
```

## 7.1 层级菜单练习
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>层级菜单</title>
    <script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
    <script type="text/javascript">
        $(function () {
            $('.level1').click(function () {

                //当前点击的元素紧挨的同辈元素向下展开，再跳到此元素的父级(li),再跳到此父级的其他的同辈元素(li),选择其他同辈元素(li)的子元素ul，然后将它向上收起。

                // 通过stop() 可以修正反复点击导致的持续动画的问题
                $(this).next().stop().slideToggle().parent().siblings().children('ul').slideUp();
            });
        });
    </script>

    <style type="text/css">
        body {
            font-family: 'Microsoft Yahei';
        }
        body, ul {
            margin: 0px;
            padding: 0px;
        }
        ul {
            list-style: none;
        }
        .menu {
            width: 200px;
            margin: 20px auto 0;
        }
        .menu .level1, .menu li ul a {
            display: block;
            width: 200px;
            height: 30px;
            line-height: 30px;
            text-decoration: none;
            background-color: #3366cc;
            color: #fff;
            font-size: 16px;
            text-indent: 10px;
        }
        .menu .level1 {
            border-bottom: 1px solid #afc6f6;

        }
        .menu li ul a {
            font-size: 14px;
            text-indent: 20px;
            background-color: #7aa1ef;
        }
        .menu li ul li {
            border-bottom: 1px solid #afc6f6;
        }
        .menu li ul {
            display: none;
        }

        .menu li ul.current {
            display: block;
        }
        .menu li ul li a:hover {
            background-color: #f6b544;
        }
    </style>
</head>
<body>
<ul class="menu">
    <li>
        <a href="#" class="level1">水果</a>
        <ul class="current">
            <li><a href="#">苹果</a></li>
            <li><a href="#">梨子</a></li>
            <li><a href="#">葡萄</a></li>
            <li><a href="#">火龙果</a></li>
        </ul>
    </li>
    <li>
        <a href="#" class="level1">海鲜</a>
        <ul>
            <li><a href="#">蛏子</a></li>
            <li><a href="#">扇贝</a></li>
            <li><a href="#">龙虾</a></li>
            <li><a href="#">象拔蚌</a></li>
        </ul>
    </li>
    <li>
        <a href="#" class="level1">肉类</a>
        <ul>
            <li><a href="#">内蒙古羊肉</a></li>
            <li><a href="#">进口牛肉</a></li>
            <li><a href="#">野猪肉</a></li>
        </ul>
    </li>
    <li>
        <a href="#" class="level1">蔬菜</a>
        <ul>
            <li><a href="#">娃娃菜</a></li>
            <li><a href="#">西红柿</a></li>
            <li><a href="#">西芹</a></li>
            <li><a href="#">胡萝卜</a></li>
        </ul>
    </li>
    <li>
        <a href="#" class="level1">速冻</a>
        <ul>
            <li><a href="#">冰淇淋</a></li>
            <li><a href="#">湾仔码头</a></li>
            <li><a href="#">海参</a></li>
            <li><a href="#">牛肉丸</a></li>
        </ul>
    </li>

</ul>
</body>
</html>
```

# 8. jquery动画

通过animate方法可以设置元素某属性值上的动画，可以设置一个或多个属性值，动画执行完成后会执行一个函数。

```js
$('#div1').animate({
    width:300,
    height:300
},1000,'swing',function(){
    alert('done!');
});

// 参数可以写成数字表达式
$('#div1').animate({
    width:'+=100', // 每次加100
    height:300
},1000,'swing',function(){
    alert('done!');
});
```

## 8.1 jquery动画
```html
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Document</title>
	<script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
	<script type="text/javascript">
		$(function(){
			$('#btn').click(function(){
				$('.box').animate({'width':600},1000,function(){
					$('.box').animate({'height':400},1000,function(){
						$('.box').animate({'opacity':0}); // 透明度变成0
					});
				});
			});

			$('#btn2').click(function(){
				$('.box2').stop().animate({'width':'+=100'});
			});
		});
	</script>

	<style type="text/css">
		.box,.box2{
			width:100px;
			height:100px;
			background-color:gold;
		}
	</style>

</head>
<body>
	<input type="button" name="" value="动画" id="btn">
	<div class="box"></div>
	<br />
	<br />
	<input type="button" name="" value="动画" id="btn2">
	<div class="box2"></div>
</body>
</html>
```

## 8.2 滑动选项卡

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Document</title>
    <script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
    <script type="text/javascript">
        $(function () {
            var $btn = $('.btns input');
            var $slides = $('.cons .slides');

            $btn.click(function () {
                // this 指的是原生的this，它表示当前点击的对象，使用jquery的对象需要用$(this)
                // 当前点击的按钮加上current样式后，除了当前，其他的按钮去掉current样式
                $(this).addClass('current').siblings().removeClass('current');
                $slides.stop().animate({'left': -500 * $(this).index()});

            })
        })

    </script>

    <style type="text/css">
        .btns input {
            width: 100px;
            height: 40px;
            background-color: #ddd;
            border: 0;
            outline: none;
        }

        .btns .current {
            background-color: gold;
        }

        .cons {
            width: 500px;
            height: 300px;
            overflow: hidden;
            position: relative;
        }

        .slides {
            width: 1500px;
            height: 300px;
            position: absolute;
            left: 0;
            top: 0;
        }

        .cons .slides div {
            width: 500px;
            height: 300px;
            background-color: gold;
            text-align: center;
            line-height: 300px;
            font-size: 30px;
            float: left;
        }

        .cons .active {
            display: block;
        }

    </style>
</head>
<body>
<div class="btns">
    <input type="button" name="" value="01" class="current">
    <input type="button" name="" value="02">
    <input type="button" name="" value="03">
</div>
<div class="cons">
    <div class="slides">
        <div>选项卡一的内容</div>
        <div>选项卡二的内容</div>
        <div>选项卡三的内容</div>
    </div>
</div>
</body>
</html>
```

# 9. 尺寸相关、滚动事件

## 9.1 获取和设置元素的尺寸

```text
width()、height()    获取元素width和height  
innerWidth()、innerHeight()  包括padding的width和height  
outerWidth()、outerHeight()  包括padding和border的width和height  
outerWidth(true)、outerHeight(true)   包括padding和border以及margin的width和height
```

```html
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Document</title>
	<script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
	<script type="text/javascript">
		$(function(){

			var $div = $('.box');

			// 盒子内容的尺寸
			console.log($div.width());
			console.log($div.height());

			// 盒子内容加上padding的尺寸
			console.log($div.innerWidth());
			console.log($div.innerHeight());

			//盒子的真实尺寸，内容尺寸+padding+border
			console.log($div.outerWidth());
			console.log($div.outerHeight());

			// 盒子的真实尺寸再加上margin
			console.log($div.outerWidth(true));
			console.log($div.outerHeight(true));

		})
        
	</script>
	<style type="text/css">

		.box{
			width:300px;
			height:200px;
			padding:20px;
			border:10px solid #000;
			margin:20px;
			background-color:gold;
		}

	</style>
</head>
<body>
	<div class="box"></div>
</body>
</html>
```

## 9.2 获取元素相对页面的绝对位置

```text
offset()
```

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Document</title>
    <script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
    <script type="text/javascript">
        $(function () {
            var $div = $('.box');
            $div.click(function () {
                var oPos = $div.offset();
                document.title = oPos.left + "|" + oPos.top; // 在标题栏面显示出来
                console.log(oPos);
            });
        })
    </script>
    <style type="text/css">
        .box {
            width: 200px;
            height: 200px;
            background-color: gold;
            margin: 50px auto 0;
        }
    </style>
</head>

<body>
	<div class="box">
</div>
</body>
</html>
```

## 9.2-1 加入购物车动画练习

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Document</title>
    <script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
    <script type="text/javascript">
        $(function () {
            var $chart = $('.chart');
            var $count = $('.chart em');
            var $btn = $('.add');
            var $point = $('.point');

            var $w01 = $btn.outerWidth();
            var $h01 = $btn.outerHeight();

            var $w02 = $chart.outerWidth();
            var $h02 = $chart.outerHeight();

            $btn.click(function () {
                var oPos01 = $btn.offset();
                var oPos02 = $chart.offset();
                $point.css({'left': oPos01.left + parseInt($w01 / 2) - 8, 'top': oPos01.top + parseInt($h01 / 2) - 8});
                $point.show();

                $point.stop().animate({
                    'left': oPos02.left + parseInt($w02 / 2) - 8,
                    'top': oPos02.top + parseInt($h02 / 2) - 8
                }, 800, function () {
                    $point.hide();
                    var iNum = $count.html();
                    $count.html(parseInt(iNum) + 1);
                });
            })
        });
    </script>

    <style type="text/css">
        .chart {
            width: 150px;
            height: 50px;
            border: 2px solid #000;
            text-align: center;
            line-height: 50px;
            float: right;
            margin-right: 100px;
            margin-top: 50px;
        }
        .chart em {
            font-style: normal;
            color: red;
            font-weight: bold;
        }
        .add {
            width: 100px;
            height: 50px;
            background-color: green;
            border: 0;
            color: #fff;
            float: left;
            margin-top: 300px;
            margin-left: 300px;
        }
        .point {
            width: 16px;
            height: 16px;
            background-color: red;
            position: fixed;
            left: 0;
            top: 0;
            display: none;
            z-index: 9999;
            border-radius: 50%;
        }
    </style>
</head>
<body>
<div class="chart">购物车<em>0</em></div>
<input type="button" name="" value="加入购物车" class="add">
<div class="point"></div>
</body>
</html>
```

## 9.3 获取浏览器可视区宽度高度

```js
$(window).width();
$(window).height();
```

## 9.4 获取页面文档的宽度高度

如果页面有滚动条，则页面文档的高度大于浏览器可视区高度

```js
$(document).width();
$(document).height();
```

## 9.5 获取页面滚动距离

```js
$(document).scrollTop();  
$(document).scrollLeft();
```

![](/jquery/scrolltop-left.jpg)

## 9.6 页面滚动事件

```js
$(window).scroll(function(){  
    ......  
})
```

## 9.6-1 置顶菜单和滚动到顶部练习

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Document</title>
    <script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
    <script type="text/javascript">
        $(function () {
            $menu = $('.menu');
            $menu_back = $('.menu_back');
            $totop = $('.totop');

            $(window).scroll(function () {
                //console.log('abc');
                var iNum = $(document).scrollTop();
                //document.title = iNum;
                if (iNum > 200) {
                    $menu.css({
                        'position': 'fixed',
                        'left': '50%',
                        'top': 0,
                        'marginLeft': -480
                    });
                    $menu_back.show();
                } else {
                    $menu.css({
                        'position': 'static',
                        'marginLeft': 'auto'
                    });
                    $menu_back.hide();
                }

                if (iNum > 400) {
                    $totop.fadeIn();
                } else {
                    $totop.fadeOut();
                }

            });
            $totop.click(function () {
                $('html,body').animate({'scrollTop': 0});
            });
        })
    </script>

    <style type="text/css">
        body {
            margin: 0;
        }
        .banner {
            width: 960px;
            height: 200px;
            background-color: cyan;
            margin: 0 auto;
        }
        .menu {
            width: 960px;
            height: 80px;
            background-color: gold;
            margin: 0 auto;
            text-align: center;
            line-height: 80px;
        }
        .menu_back {
            width: 960px;
            height: 80px;
            margin: 0 auto;
            display: none;
        }
        p {
            text-align: center;
            color: red;
        }
        .totop {
            width: 60px;
            height: 60px;
            background-color: #000;
            color: #fff;
            position: fixed;
            right: 20px;
            bottom: 50px;
            line-height: 60px;
            text-align: center;
            font-size: 40px;
            border-radius: 50%;
            cursor: pointer;
            display: none;
        }
    </style>
</head>
<body>
<div class="banner"></div>
<div class="menu">菜单</div>
<div class="menu_back"></div>
<div class="totop">↑</div>

<p>文档内容</p>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>

..........

</body>
</html>
```

# 10. jquery属性操作

## 10.1 html() 取出或设置html内容
```js
// 取出html内容
var $htm = $('#div1').html();

// 设置html内容
$('#div1').html('<span>添加文字</span>');
```

## 10.2 prop() 取出或设置某个属性的值
```js
// 取出图片的绝对地址地址
var $src = $('#img1').prop('src');

// 设置图片的地址和alt属性
$('#img1').prop({src: "test.jpg", alt: "Test Image" });
```
```html
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Document</title>
	<script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
	<script type="text/javascript">
		$(function(){

			var $a = $('.link');
			var $img = $('#img01');
			var $div = $('#div1');

			// 读取class属性值
			console.log( $a.prop('class')); // link

			// 没有设置的属性读取为空
			console.log($a.prop('title'));

			// 获取是图片的绝对地址
			console.log($img.prop('src'));
			//alert($img.prop('src'));

			// 设置属性
			$a.prop({'href':'http://www.baidu.com','title':'百度网链接'});

			//console.log($a.prop('title'));

			//读取标签内包含的内容
			console.log($a.html());
             // 写入标签的内容，会代替原来的内容
			$div.html('<span>div里面的span元素</span>'); // <span>div里面的span元素</span>
		})
	</script>
</head>
<body>
	<a href="#" class="link">这是一个链接</a>
	<img src="images/002.jpg" id="img01" alt="水果">
	<div id="div1"></div>
</body>
</html>
```
# 11. jquery循环

对jquery选择的对象集合分别进行操作，需要用到jquery循环操作，此时可以用对象上的each方法

```js
$(function () {
    $('.list li').each(function (i) {
        alert(i); // 弹出li标签里面的值
        // alert($(this).index()); // 弹出li标签里面的值的索引
        // alert($(this).html(i)); // 弹出object对象
    });
});
......
<ul class="list">
    <li>1</li>
    <li>2</li>
    <li>3</li>
    <li>4</li>
    <li>5</li>
    <li>6</li>
</ul>
```

## 11.1 手风琴练习
```html
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
    <script type="text/javascript">
        $(function () {
            var $li = $('#accordion li');
            $li.click(function () {
                //alert($(this).html());
                $(this).animate({'left': 21 * $(this).index()});
                //点击的li前面的li向左运动到各自的位置
                $(this).prevAll().each(function () {
                    //这里的$(this)指的是循环选择的每个li
                    $(this).animate({'left': 21 * $(this).index()});

                });
                //   第5个li在右边的left值   727-21*1 等同于 727-21*(5-$(this).index())
                //   第4个li在右边的left值   727-21*2 等同于 727-21*(5-$(this).index())
                //   第3个li在右边的left值   727-21*3 等同于 727-21*(5-$(this).index())
                $(this).nextAll().each(function () {
                    $(this).animate({'left': 727 - 21 * (5 - $(this).index())});
                });
            })
        })

    </script>
    <style>
        * {
            margin: 0;
            padding: 0;
        }
        body {
            font-size: 12px;
        }
        #accordion {
            width: 727px;
            height: 350px;
            margin: 100px auto 0 auto;
            position: relative;
            overflow: hidden;
            border: 1px solid #CCC;
        }
        #accordion ul {
            list-style: none;
        }
        #accordion ul li {
            width: 643px;
            height: 350px;
            position: absolute;
            background: #FFF;
        }
        #accordion ul li span {
            display: block;
            width: 20px;
            height: 350px;
            float: left;
            text-align: center;
            color: #FFF;
            padding-top: 5px;
            cursor: pointer;
        }
        #accordion ul li img {
            display: block;
            float: right;
        }
        .bar01 {
            left: 0px;
        }
        .bar02 {
            left: 643px;
        }
        .bar03 {
            left: 664px;
        }
        .bar04 {
            left: 685px;
        }
        .bar05 {
            left: 706px;
        }
        .bar01 span {
            background: #09E0B5;
        }
        .bar02 span {
            background: #3D7FBB;
        }
        .bar03 span {
            background: #5CA716;
        }
        .bar04 span {
            background: #F28B24;
        }
        .bar05 span {
            background: #7C0070;
        }
    </style>
    <title>手风琴效果</title>
</head>

<body>
<div id="accordion">
    <ul>
        <li class="bar01"><span>非洲景色01</span><img src="images/001.jpg" /></li>
        <li class="bar02"><span>非洲景色02</span><img src="images/002.jpg" /></li>
        <li class="bar03"><span>非洲景色03</span><img src="images/003.jpg" /></li>
        <li class="bar04"><span>非洲景色04</span><img src="images/004.jpg" /></li>
        <li class="bar05"><span>非洲景色05</span><img src="images/005.jpg" /></li>
    </ul>
</div>
</body>
</html>

```

# 12. jquery事件

## 12.1 事件函数列表
```js
blur() 元素失去焦点
focus() 元素获得焦点
click() 鼠标单击
mouseover() 鼠标进入（进入子元素也触发）
mouseout() 鼠标离开（离开子元素也触发）
mouseenter() 鼠标进入（进入子元素不触发）
mouseleave() 鼠标离开（离开子元素不触发）
hover() 同时为mouseenter和mouseleave事件指定处理函数
ready() DOM加载完成
resize() 浏览器窗口的大小发生改变
scroll() 滚动条的位置发生变化
submit() 用户递交表单
```

## 12.2 绑定事件的其他方式 
```js
$(function(){
    $('#div1').bind('mouseover click', function(event) {
        alert($(this).html());
    });
});
```

## 12.3 取消绑定事件 
```js
$(function(){
    $('#div1').bind('mouseover click', function(event) {
        alert($(this).html());

        // $(this).unbind();
        $(this).unbind('mouseover');

    });
});
```

```html
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
    <script type="text/javascript">
        /*
        $(function () {
            $("#btn").click(function () {
                alert('click事件');
            });

        });
        */
        // 点击或者鼠标移入的时候都执行绑定的函数
        $(function () {
            $("#btn").bind('click mouseover',function () {
                alert('bind绑定click事件和mouseover鼠标移入事件');
                $(this).unbind('mouseover');
            });
        });
    </script>
    <title>Documet</title>
</head>

<body>

<input type="button" name="" value="按钮" id="btn">

</body>
</html>
```

## 12.4 焦点和提交事件

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Document</title>
    <script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
    <script type="text/javascript">
        $(function () {
            // 在获得焦点的时候做什么事情
            /*$('#input01').focus(function(){
                alert('获得焦点')
            })*/
            //focus 一般用来让input元素开始就获取焦点，只能是一个元素获得焦点
            $('#input01').focus();

            $('#input01').blur(function () {
                // 获取input元素的value值用 val()
                var sVal = $(this).val();
                alert(sVal);
            });

            $('#form1').submit(function () {
                //alert('提交');
                // 阻止默认的提交行为
                return false;

            });
        })
    </script>
</head>
<body>
    <form id="form1" action="http://www.baidu.com">
        <input type="text" name="dat01" id="input01">
        <input type="text" name="dat02" id="input02">
        <input type="submit" name="" value="提交" id="sub">
    </form>
</body>
</html>
```

## 12.5 鼠标移入移出事件

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Document</title>
    <script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
    <script type="text/javascript">

        $(function () {

            // 鼠标移入，移入的子元素也会触发
            $('.con').mouseover(function () {
                alert('移入');
            });

            $('.con').mouseout(function () {
                alert('移出');
            });

            // 鼠标移入，移入的子元素不会触发
            /*
            $('.con2').mouseenter(function(){
                alert('移入');
            })
            $('.con2').mouseleave(function(){
                alert('移出');
            })
            */

            // 合并成下面的写法：
            $('.con2').hover(function () {
                alert('移入')
            }, function () {
                alert('移出')
            })


        })

    </script>
    <style type="text/css">
        .con, .con2 {
            width: 200px;
            height: 200px;
            background-color: gold;
        }

        .box, .box2 {
            width: 100px;
            height: 100px;
            background-color: green;
        }
    </style>
</head>
<body>
    <div class="con">
        <div class="box"></div>
    </div>

    <br/>
    <br/>
    <br/>
    <br/>

    <div class="con2">
        <div class="box2"></div>
    </div>

</body>
</html>
```

# 13. 事件冒泡

## 13.1 什么是事件冒泡

在一个对象上触发某类事件（比如单击onclick事件），如果此对象定义了此事件的处理程序，那么此事件就会调用这个处理程序，如果没有定义此事件处理程序或者事件返回true，那么这个事件会向这个对象的父级对象传播，从里到外，直至它被处理（父级对象所有同类事件都将被激活），或者它到达了对象层次的最顶层，即document对象（有些浏览器是window）。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Document</title>
    <script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
    <script type="text/javascript">
        $(function () {
            // 事件冒泡依据的是标签之间的层级关系，不是标签的位置
            $('.son').click(function () {
                alert(1);
            });
            $('.father').click(function () {
                alert(2);
            });
            $('.grandfather').click(function () {
                alert(3);
            });
        })
    </script>
    <style type="text/css">
        .grandfather {
            width: 300px;
            height: 300px;
            background-color: green;
            position: relative;
        }
        .father {
            width: 200px;
            height: 200px;
            background-color: gold;
        }
        .son {
            width: 100px;
            height: 100px;
            background-color: red;
            position: absolute;
            left: 0;
            top: 400px;
        }

    </style>
</head>
<body>
<div class="grandfather">
    <div class="father">
        <div class="son"></div>
    </div>
</div>
</body>
</html>
```

## 13.2 事件冒泡的作用

事件冒泡允许多个操作被集中处理（把事件处理器添加到一个父级元素上，避免把事件处理器添加到多个子级元素上），它还可以让你在对象层的不同级别捕获事件。

## 13.3 阻止事件冒泡

事件冒泡机制有时候是不需要的，需要阻止掉，通过 event.stopPropagation() 来阻止

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Document</title>
    <script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
    <script type="text/javascript">
        $(function () {
            // event 是发生事件的时候的事件对象，使用的时候，通过第一个参数传进来
            $('.son').click(function (event) {
                alert(1);
                //通过event对象上的stopPropagation的方法阻止事件冒泡
                event.stopPropagation();
            });
            $('.father').click(function () {
                alert(2);
            });

            $('.grandfather').click(function () {
                alert(3);
            });
        })
    </script>
    <style type="text/css">
        .grandfather {
            width: 300px;
            height: 300px;
            background-color: green;
            position: relative;
        }
        .father {
            width: 200px;
            height: 200px;
            background-color: gold;
        }
        .son {
            width: 100px;
            height: 100px;
            background-color: red;
            position: absolute;
            left: 0;
            top: 400px;
        }
    </style>
</head>
<body>
    <div class="grandfather">
        <div class="father">
            <div class="son"></div>
        </div>
    </div>
</body>
</html>
```

## 13.4 阻止默认行为

阻止表单提交 

```
$('#form1').submit(function(event){
    event.preventDefault();
})
```

## 13.5 合并阻止操作
实际开发中，一般把阻止冒泡和阻止默认行为合并起来写，合并写法可以用  

```
// event.stopPropagation();
// event.preventDefault();

// 合并写法：
return false;
```

## 13.6 课堂练习

页面弹框（点击弹框外弹框关闭），在document上绑定一个事件

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Document</title>
    <script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
    <script type="text/javascript">
        $(function () {
            $('#btn').click(function () {
                $('.pop_con').fadeIn();
                return false;
            });
            $(document).click(function () {
                $('.pop_con').fadeOut();
            });
            $('.pop').click(function () {
                return false;
            });
            $('#close').click(function () {
                $('.pop_con').fadeOut();
            });
        });
    </script>
    <style type="text/css">
        .pop_con {
            display: none;
        }
        .pop {
            position: fixed;
            width: 500px;
            height: 300px;
            background-color: #fff;
            border: 3px solid #000;
            left: 50%;
            top: 50%;
            margin-left: -250px;
            margin-top: -150px;
            z-index: 9999;
        }
        .mask {
            position: fixed;
            width: 100%;
            height: 100%;
            background-color: #000;
            opacity: 0.3;
            filter: alpha(opacity=30);
            left: 0;
            top: 0;
            z-index: 9990;

        }
        .close {
            float: right;
            font-size: 30px;
        }
    </style>
</head>
<body>
    <input type="button" name="" value="弹出" id="btn">
    <div class="pop_con">
        <div class="pop">
            弹框里面文字
            投资金额：<input type="text" name="">
            <a href="#" id="close" class="close">×</a>
        </div>
        <div class="mask"></div>
    </div>
</body>
</html>
```

# 14. 事件委托

事件委托就是利用冒泡的原理，把事件加到父级上，通过判断事件来源的子集，执行相应的操作，事件委托首先可以极大减少事件绑定次数，提高性能；其次可以让新加入的子元素也可以拥有相同的操作。

## 14.1 一般绑定事件的写法

```html
$(function(){
    $ali = $('#list li');
    $ali.click(function() {
        $(this).css({background:'red'});
    });
})
...
<ul id="list">
    <li>1</li>
    <li>2</li>
    <li>3</li>
    <li>4</li>
    <li>5</li>
</ul>
```

## 14.2 事件委托的写法

```html
$(function(){
    $list = $('#list');
    $list.delegate('li', 'click', function() {
        $(this).css({background:'red'});
    });
})
...
<ul id="list">
    <li>1</li>
    <li>2</li>
    <li>3</li>
    <li>4</li>
    <li>5</li>
</ul>
```

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Document</title>
    <script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
    <script type="text/javascript">
        $(function () {
            /*
            // 这个写法相当于绑定8次，比较损耗性能
            $('.list li').click(function(){
                $(this).css({'backgroundColor':'red'});
            });
            */

            // 新建一个li元素赋值给$li变量
            //var $li = $('<li>9</li>');

            //让新加的li有相同的事件，需要单独绑定
            //$li.click(....)

            // 把新建的li元素放到ul子集的最后面
            //$('.list').append($li);

            //事件委托，将li要发生的事件委托给li的父级
            $('.list').delegate('li', 'click', function () {
                //$(this) 指的是委托的子元素
                $(this).css({'backgroundColor': 'red'});
            });
            var $li = $('<li>9</li>');
            $('.list').append($li);
        })

    </script>
    <style type="text/css">
        .list {
            background-color: gold;
            list-style: none;
            padding: 10px;
        }
        .list li {
            height: 30px;
            background-color: green;
            margin: 10px;
        }
    </style>
</head>

<body>
    <ul class="list">
        <li>1</li>
        <li>2</li>
        <li>3</li>
        <li>4</li>
        <li>5</li>
        <li>6</li>
        <li>7</li>
        <li>8</li>
    </ul>
</body>
</html>
```

# 15.jquery元素节点操作

## 15.1 创建节点

```js
var $div = $('<div>');
var $div2 = $('<div>这是一个div元素</div>');
```

## 15.2 插入节点
1、append()和appendTo()：在现存元素的内部，从后面插入元素

```html
var $span = $('<span>这是一个span元素</span>');
$('#div1').append($span);
......
<div id="div1"></div>
```

2、prepend()和prependTo()：在现存元素的内部，从前面插入元素
3、after()和insertAfter()：在现存元素的外部，从后面插入元素，也就是在现存元素的父级元素后面插入新元素
4、before()和insertBefore()：在现存元素的外部，从前面插入元素，也就是在现存元素的父级元素前面插入新元素

注意：对已有的节点进行上述操作的话是剪切再粘贴。

```html
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Document</title>
	<script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
	<script type="text/javascript">
		$(function(){
            // 新增节点操作

			// 通过html的字符串的方式添加节点性能最高
            // 如下的这种方式会替换掉原来的
            //$('#div1').html('<a href="#">链接</a>')
            // 先获取到原来的，然后使用+拼接起来
			//$('#div1').html($('#div1').html()+'<a href="#">链接</a>')

			// 新建一个带有属性的a元素，把它赋值给$a
			$a = $('<a href="#">链接</a>');
			// 父元素内的后面放入子元素
			// $('#div1').append($a);
            //子元素放入到父元素内部的后面
			$a.appendTo($('#div1')); // 实际结果跟$('#div1').append($a);一样

			// 新建一个空的a元素
			$a2 = $('<a>');
            $('#div1').append($a2); // 实际效果：<a></a>

            $p = $('<p>这是一个p元素</p>');
			// 父元素内的前面放入子元素
			//$('#div1').prepend($p);
			//子元素放入到父元素内部的前面
			$p.prependTo($('#div1'));

            $h2 = $('<h2>这是一个h2</h2>');
			//$('#div1').after($h2);
			$h2.insertAfter($('#div1'));

            $h3 = $('<h3>这是一个h3</h3>');
			//$('#div1').before($h3);
			$h3.insertBefore($('#div1'));
		})
	</script>
</head>
<body>
	<div id="div1">
		<h1>这是一个H1元素</h1>
	</div>
</body>
</html>
```

## 15.3 删除节点

```
$('#div1').remove();
```

## 15.4 课堂练习

todolist(计划列表)实例

```html
<!-- a标签的href属性   -->

<!-- # 默认会链接到页面顶部   -->
<a href="#">链接</a>

<a href="javascript:alert('ok!');">链接</a>
<!-- 让链接的默认行为是 执行javascript的空语句，也就是什么都不做   -->
<a href="javascript:;">链接</a>
```

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>todolist</title>
    <script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
    <script type="text/javascript">
        $(function () {

            var $inputtxt = $('#txt1');
            var $btn = $('#btn1');
            var $ul = $('#list');

            $btn.click(function () {
                // 获取input输入框的内容
                var $val = $inputtxt.val();

                if ($val == "") {
                    alert('请输入内容');
                    return;
                }

                var $li = $('<li><span>' + $val + '</span><a href="javascript:;" class="up"> ↑ </a><a href="javascript:;" class="down"> ↓ </a><a href="javascript:;" class="del">删除</a></li>');

                /*
                var $a = $li.find('.del');

                    $a.click(function(){
                        $(this).parent().remove();
                    })
                */

                $ul.append($li);
                $inputtxt.val("");

            });

            /*
            $('.del').click(function(){

                $(this).parent().remove();

            })
            */

            $ul.delegate('a', 'click', function () {
                var $handler = $(this).prop('class');
                if ($handler == 'del') {
                    $(this).parent().remove();
                }
                if ($handler == 'up') {
                    if ($(this).parent().prev().length == 0) {
                        alert('到顶了！');
                        return;
                    }
                    $(this).parent().insertBefore($(this).parent().prev());
                }

                if ($handler == 'down') {
                    if ($(this).parent().next().length == 0) {
                        alert('到底了！');
                        return;
                    }
                    $(this).parent().insertAfter($(this).parent().next());
                }
            });
        });

    </script>
    <style type="text/css">
        .list_con {
            width: 600px;
            margin: 50px auto 0;
        }
        .inputtxt {
            width: 550px;
            height: 30px;
            border: 1px solid #ccc;
            padding: 0px;
            text-indent: 10px;
        }
        .inputbtn {
            width: 40px;
            height: 32px;
            padding: 0px;
            border: 1px solid #ccc;
        }
        .list {
            margin: 0;
            padding: 0;
            list-style: none;
            margin-top: 20px;
        }
        .list li {
            height: 40px;
            line-height: 40px;
            border-bottom: 1px solid #ccc;
        }
        .list li span {
            float: left;
        }
        .list li a {
            float: right;
            text-decoration: none;
            margin: 0 10px;
        }
    </style>
</head>
<body>

<div class="list_con">
    <h2>To do list</h2>
    <input type="text" name="" id="txt1" class="inputtxt">
    <input type="button" name="" value="增加" id="btn1" class="inputbtn">

    <ul id="list" class="list">
        <li><span>学习html</span><a href="javascript:;" class="up"> ↑ </a><a href="javascript:;" class="down"> ↓ </a><a
                href="javascript:;" class="del">删除</a></li>
        <li><span>学习css</span><a href="javascript:;" class="up"> ↑ </a><a href="javascript:;" class="down"> ↓ </a><a
                href="javascript:;" class="del">删除</a></li>
        <li><span>学习javascript</span><a href="javascript:;" class="up"> ↑ </a><a href="javascript:;" class="down">
            ↓ </a><a href="javascript:;" class="del">删除</a></li>
    </ul>

</div>
</body>
</html>
```

# 16. 滚轮事件与函数节流

## 16.1 jquery.mousewheel插件使用
jquery中没有鼠标滚轮事件，原生js中的鼠标滚轮事件不兼容，可以使用jquery的滚轮事件插件jquery.mousewheel.js。

## 16.2 函数节流
javascript中有些事件的触发频率非常高，比如onresize事件(jq中是resize)，onmousemove事件(jq中是mousemove)以及上面说的鼠标滚轮事件，在短事件内多处触发执行绑定的函数，可以巧妙地使用定时器来减少触发的次数，实现函数节流。

## 16.3 课堂实例

### 16.3.1 整屏滚动
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>整页滚动</title>
    <link rel="stylesheet" type="text/css" href="css/test.css">
    <script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
    <script type="text/javascript" src="js/jquery.mousewheel.js"></script>
    <script type="text/javascript">
        $(function () {
            var $screen = $('.pages_con');
            var $pages = $('.pages');
            var $len = $pages.length;
            var $h = $(window).height();
            var $points = $('.points li');
            var timer = null;

            var $nowscreen = 0;
            $pages.css({'height': $h});
            $pages.eq(0).addClass('moving');

            $points.click(function () {
                $nowscreen = $(this).index();
                $points.eq($nowscreen).addClass('active').siblings().removeClass('active');
                $screen.animate({'top': -$h * $nowscreen}, 300);
                $pages.eq($nowscreen).addClass('moving').siblings().removeClass('moving');
            });

            $(window).mousewheel(function (event, dat) {
                clearTimeout(timer);
                timer = setTimeout(function () {

                    if (dat == -1) {
                        $nowscreen++;
                    } else {
                        $nowscreen--;
                    }
                    if ($nowscreen < 0) {
                        $nowscreen = 0;
                    }

                    if ($nowscreen > $len - 1) {
                        $nowscreen = $len - 1;
                    }

                    $screen.animate({'top': -$h * $nowscreen}, 300);
                    $pages.eq($nowscreen).addClass('moving').siblings().removeClass('moving');

                    $points.eq($nowscreen).addClass('active').siblings().removeClass('active');

                }, 200)

            })
        })

    </script>
</head>
<body>
<div class="pages_con">

    <div class="pages page1">
        <div class="main_con">
            <div class="left_img"><img src="images/001.png"></div>
            <div class="right_info">
                Web前端开发是从网页制作演变而来的，名称上有很明显的时代特征。在互联网的演化进程中，网页制作是Web1.0时代的产物，那时网站的主要内容都是静态的，用户使用网站的行为也以浏览为主。

            </div>
        </div>
    </div>

    <div class="pages page2">
        <div class="main_con">
            <div class="right_img"><img src="images/002.png"></div>
            <div class="left_info">
                2005年以后，互联网进入Web2.0时代，各种类似桌面软件的Web应用大量涌现，网站的前端由此发生了翻天覆地的变化。网页不再只是承载单一的文字和图片，各种富媒体让网页的内容更加生动，网页上软件化的交互形式为用户提供了更好的使用体验，这些都是基于前端技术实现的。
            </div>
        </div>

    </div>

    <div class="pages page3">
        <div class="main_con">
            <div class="left_img"><img src="images/004.png"></div>
            <div class="right_info">
                以前会Photoshop和Dreamweaver就可以制作网页，现在只掌握这些已经远远不够了。无论是开发难度上，还是开发方式上，现在的网页制作都更接近传统的网站后台开发，所以现在不再叫网页制作，而是叫Web前端开发。


            </div>
        </div>
    </div>

    <div class="pages page4">
        <div class="main_con">
            <div class="left_img"><img src="images/003.png"></div>
            <div class="right_info">
                Web前端开发在产品开发环节中的作用变得越来越重要，而且需要专业的前端工程师才能做好，这方面的专业人才近几年来备受青睐。Web前端开发是一项很特殊的工作，涵盖的知识面非常广，既有具体的技术，又有抽象的理念。简单地说，它的主要职能就是把网站的界面更好地呈现给用户。
            </div>
        </div>
    </div>

    <div class="pages page5">
        <div class="main_con">
            <div class="center_img"><img src="images/005.png"></div>
        </div>

    </div>
</div>
<ul class="points">
    <li class="active"></li>
    <li></li>
    <li></li>
    <li></li>
    <li></li>
</ul>
</body>
</html>
```

### 16.3.2 幻灯片

### 16.3.3 制作CSS3动画
```html
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Document</title>
	<script type="text/javascript" src="js/jquery-1.12.4.min.js"></script>
	<script type="text/javascript">
		$(function(){
			$('#btn').click(function(){
				$('.box').addClass('moving');
			});	
		})
	</script>
    
	<style type="text/css">
		.box{
			width:200px;
			height:200px;
			background-color:gold;
			margin:50px auto 0;
			transition:all 1s ease;
		}
		.moving{
			transform:rotate(135deg);
		}
	</style>
</head>
<body>
	<input type="button" name="" value="动画" id="btn">
	<div class="box"></div>
</body>
</html>
```

# 17. json

json是 JavaScript Object Notation 的首字母缩写，单词的意思是javascript对象表示法，这里说的json指的是类似于javascript对象的一种数据格式，目前这种数据格式比较流行，逐渐替换掉了传统的xml数据格式。 

## 17.1 javascript自定义对象

```js
var oMan = {
    name:'tom',
    age:16,
    talk:function(s){
        alert('我会说'+s);
    }
}
```

## 17.2 json格式的数据

```json
{
    "name":"tom",
    "age":18
}
```

与json对象不同的是，json数据格式的属性名称和字符串值需要用双引号引起来，用单引号或者不用引号会导致读取数据错误。

json的另外一个数据格式是数组，和javascript中的数组字面量相同。

```dict
["tom",18,"programmer"]
```

# 18. ajax与jsonp

ajax技术的目的是让javascript发送http请求，与后台通信，获取数据和信息。ajax技术的原理是实例化xmlhttp对象，使用此对象与后台通信。ajax通信的过程不会影响后续javascript的执行，从而实现异步。

 **同步和异步** 
现实生活中，同步指的是同时做几件事情，异步指的是做完一件事后再做另外一件事，程序中的同步和异步是把现实生活中的概念对调，也就是程序中的异步指的是现实生活中的同步，程序中的同步指的是现实生活中的异步。

 **局部刷新和无刷新** 
ajax可以实现局部刷新，也叫做无刷新，无刷新指的是整个页面不刷新，只是局部刷新，ajax可以自己发送http请求，不用通过浏览器的地址栏，所以页面整体不会刷新，ajax获取到后台数据，更新页面显示数据的部分，就做到了页面局部刷新。

 **同源策略** 
ajax请求的页面或资源只能是同一个域下面的资源，不能是其他域的资源，这是在设计ajax时基于安全的考虑。
特征报错提示：

```
XMLHttpRequest cannot load https://www.baidu.com/. No  
'Access-Control-Allow-Origin' header is present on the requested resource.  
Origin 'null' is therefore not allowed access.
```

 ## 18.1 $.ajax使用方法
常用参数：
1、url 请求地址
2、type 请求方式，默认是'GET'，常用的还有'POST'
3、dataType 设置返回的数据格式，常用的是'json'格式，也可以设置为'html'
4、data 设置发送给服务器的数据
5、success 设置请求成功后的回调函数
6、error 设置请求失败后的回调函数
7、async 设置是否异步，默认值是'true'，表示异步  

以前的写法：

```
$.ajax({
    url: 'js/data.json',
    type: 'GET',
    dataType: 'json',
    data:{'aa':1}
    success:function(data){
        alert(data.name);
    },
    error:function(){
        alert('服务器超时，请重试！');
    }
});
```

新的写法(推荐)：

```
$.ajax({
    url: 'js/data.json',
    type: 'GET',
    dataType: 'json',
    data:{'aa':1}
})
.done(function(data) {
    alert(data.name);
})
.fail(function() {
    alert('服务器超时，请重试！');
});

// data.json里面的数据： {"name":"tom","age":18}
```

 **课堂练习** 
制作首页用户信息读取
```python
#!/usr/bin/env python
#-*- coding: utf-8 -*-

from flask import Flask,render_template,request,jsonify

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/login',methods=['GET','POST'])
def login():
    if request.method == 'GET':
        return render_template('login.html')
    else:
        # 和前端约定好，发送网络请求，不管用户名和密码是否验证成功
        # 我都返回同样格式的json对象给你
        # {"code":200,"message":""}
        username = request.form.get('username')
        password = request.form.get('password')
        print(username,password)

        data = {
            'username':username
        }

        if username == '111' and password == '222':
            return jsonify({"code":200,"message":"","data":data})
        else:
            return jsonify({"code":401,"message":"用户名或密码错误！"})

if __name__ == '__main__':
    app.run(debug=True)

```

```html
// index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Index</title>
    <script type="text/javascript" src="static/jquery-3.3.1.min.js"></script>
    <script type="text/javascript">
        $(function () {
            $("#btn").click(function () {
                var $username = $("#username").val();
                var $password = $("#password").val();

                var $data = {
                    "username": $username,
                    "password": $password
                };

                $.ajax({
                    url: "/login",
                    type: 'POST',
                    dataType: 'json',
                    data: $data,
                })
                    .done(function (data) {
                        if (data['code'] == 200) {
                            $("#div01").hide();
                            $(".div2").append(data['data']['username']);
                            $(".div2").removeClass("div2");
                        }
                    })
            });

        });

    </script>
    <style type="text/css">
        .div2{
            display: none;
        }
    </style>
</head>
<body>

    <h2>Index</h2>

    <div id="div01">
        <p>
            <span>用户名：</span>
            <input type="text" name="username" id="username">
        </p>
        <p>
            <span>密码：</span>
            <input type="password" name="pwd" id="password">
        </p>
        <button id="btn" value="submit">提交</button>
    </div>

    <div class="div2">
        <span>用户名：</span>
    </div>

</body>
</html>
```

## 18.2  **jsonp**

ajax只能请求同一个域下的数据或资源，有时候需要跨域请求数据，就需要用到jsonp技术，jsonp可以跨域请求数据，它的原理主要是利用了`<script>`标签可以跨域链接资源的特性。jsonp和ajax原理完全不一样，不过jquery将它们封装成同一个函数。

```js
$.ajax({
    url:'js/data.js',
    type:'get',
    dataType:'jsonp',
    jsonpCallback:'fnBack'
})
.done(function(data){
    alert(data.name);
})
.fail(function() {
    alert('服务器超时，请重试！');
});

// data.js里面的数据： fnBack({"name":"tom","age":18});
```

 **课堂实例** 
获取360搜索关键词联想数据

```
$(function(){
    $('#txt01').keyup(function(){
        var sVal = $(this).val();
        $.ajax({
            url:'https://sug.so.360.cn/suggest?',
            type:'get',
            dataType:'jsonp',
            data: {word: sVal}
        })
        .done(function(data){
            var aData = data.s;
            $('.list').empty();
            for(var i=0;i<aData.length;i++)
            {
                var $li = $('<li>'+ aData[i] +'</li>');
                $li.appendTo($('.list'));
            }
        })        
    })
})

//......

<input type="text" name="" id="txt01">
<ul class="list"></ul>
```
# 19. 本地存储

本地存储分为cookie，以及新增的localStorage和sessionStorage

1、cookie 存储在本地，容量最大4k，在同源的http请求时携带传递，损耗带宽，可设置访问路径，只有此路径及此路径的子路径才能访问此cookie，在设置的过期时间之前有效。

```js
// jquery 设置cookie
$.cookie('mycookie','123',{expires:7,path:'/'});
// jquery 获取cookie
$.cookie('mycookie');
```

```html
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Document</title>
	<script type="text/javascript" src="jquery-3.3.1.min.js"></script>
	<script type="text/javascript" src="js/jquery.cookie.js"></script>
	<script type="text/javascript">

		// 设置cookie 过期时间为7天，存在网站根目录下
		//$.cookie('mycookie','ok!',{expires:7,path:'/'});

		//读取cookie
		var mycookie = $.cookie('mycookie');
		alert(mycookie);
	</script>
</head>
<body>
	<h1>测试页面</h1>
</body>
</html>

```

 **课堂实例** 
只提示一次的弹框 
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Document</title>
    <script type="text/javascript" src="jquery-3.3.1.min.js"></script>
    <script type="text/javascript" src="js/jquery.cookie.js"></script>
    <script type="text/javascript">
        $(function () {
            var hasread = $.cookie('hasread');
            //alert(hasread);

            // 判断是否存了cookie，没有就弹出弹框
            if (hasread == undefined) {
                $('.pop_con').show();
            }

            //用户点击知道后，存cookie，把弹框关掉
            $('#user_read').click(function () {
                $.cookie('hasread', 'read', {expires: 7, path: '/'});
                $('.pop_con').hide();
            })
        })

    </script>

    <style type="text/css">
        .pop_con {
            display: none;
        }
        .pop {
            position: fixed;
            width: 500px;
            height: 300px;
            background-color: #fff;
            border: 3px solid #000;
            left: 50%;
            top: 50%;
            margin-left: -250px;
            margin-top: -150px;
            z-index: 9999;
        }
        .mask {
            position: fixed;
            width: 100%;
            height: 100%;
            background-color: #000;
            opacity: 0.3;
            filter: alpha(opacity=30);
            left: 0;
            top: 0;
            z-index: 9990;

        }
        .close {
            float: right;
            font-size: 30px;
        }
    </style>
</head>
<body>

<div class="pop_con">
    <div class="pop">
        亲！本网站最近有优惠活动！请强力关注！
        <a href="#" id="close" class="close">×</a>

        <a href="javascript:;" id="user_read">朕知道了！</a>
    </div>
    <div class="mask"></div>
</div>

<h1>网站内容</h1>
</body>
</html>
```


2、localStorage 存储在本地，容量为5M或者更大，不会在请求时候携带传递，在所有同源窗口中共享，数据一直有效，除非人为删除，可作为长期数据。

```
//设置：
localStorage.setItem("dat", "456");
localStorage.dat = '456';

//获取：
localStorage.getItem("dat");
localStorage.dat

//删除
localStorage.removeItem("dat");
```

3、sessionStorage 存储在本地，容量为5M或者更大，不会在请求时候携带传递，在同源的当前窗口关闭前有效。

localStorage 和 sessionStorage 合称为Web Storage , Web Storage支持事件通知机制，可以将数据更新的通知监听者，Web Storage的api接口使用更方便。

iPhone的无痕浏览不支持Web Storage，只能用cookie。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Document</title>
    <script type="text/javascript">
        // 不用加载jQuery文件

        //设置：
        localStorage.setItem("dat", "456");
        localStorage.dat = '456';

        //获取：
        localStorage.getItem("dat");
        localStorage.dat

        //删除
        localStorage.removeItem("dat");
    </script>
</head>
<body>
<h1>测试webstorage</h1>
</body>
</html>
```

# 20. jqueryUI

jQuery UI是以 jQuery 为基础的代码库。包含底层用户交互、动画、特效和可更换主题的可视控件。我们可以直接用它来构建具有很好交互性的web应用程序。

 **jqueryUI 网址** 
<http://jqueryui.com/>

 **课堂实例** 

## 1、设置数值的滑动条

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>drag</title>
    <script type="text/javascript" src="jquery-3.3.1.min.js"></script>
    <script type="text/javascript" src="js/jquery-ui.min.js"></script>
    <script type="text/javascript">
        $(function () {
            $('.dragbar').draggable({
                // 限制在X轴方向拖动
                axis: 'x',
                // 限定在父级的范围内拖动
                containment: 'parent',
                //containment:[0,0,600,0]

                //设置拖动时候的透明度
                opacity: 0.6,

                drag: function (ev, ui) {
                    //console.log(ui.position.left);
                    //获取拖动的距离
                    var nowleft = ui.position.left;
                    $('.progress').css({width: nowleft});
                    $('.slide_count').val(parseInt(nowleft * 100 / 570));
                }
            });
        })
    </script>
    <style type="text/css">
        .slidebar_con {
            width: 650px;
            height: 32px;
            margin: 50px auto 0;
        }
        .slidebar {
            width: 600px;
            height: 30px;
            border: 1px solid #ccc;
            float: left;
            position: relative;
        }
        .slidebar .dragbar {
            width: 30px;
            height: 30px;
            background-color: gold;
            cursor: pointer;
            position: absolute;
            left: 0;
            top: 0;
        }
        .slidebar .progress {
            width: 0px;
            height: 30px;
            background-color: #f0f0f0;
            position: absolute;
            left: 0;
            top: 0;
        }
        .slide_count {
            padding: 0;
            float: right;
            width: 40px;
            height: 30px;
            border: 1px solid #ccc;
            text-align: center;
            font-size: 16px;
        }
    </style>
</head>
<body>
<div class="slidebar_con">
    <div class="slidebar">
        <div class="progress"></div>
        <div class="dragbar"></div>
    </div>
    <input type="text" name="" value="0" class="slide_count">
</div>
</body>
</html>
```
## 2 、自定义滚动条

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>自定义滚动条</title>
    <script type="text/javascript" src="jquery-3.3.1.min.js"></script>
    <script type="text/javascript" src="js/jquery-ui.min.js"></script>
    <script type="text/javascript">
        $(function () {
            var h = $('.paragraph').outerHeight();
            //整体文本的高度减去外面容器的高度
            var hide = h - 500;
            $('.scroll_bar').draggable({
                axis: 'y',
                containment: 'parent',
                opacity: 0.6,
                drag: function (ev, ui) {
                    var nowtop = ui.position.top;
                    var nowscroll = parseInt(nowtop / 290 * hide);
                    $('.paragraph').css({top: -nowscroll});
                }
            });
        })

    </script>
    <style type="text/css">
        .scroll_con {
            width: 400px;
            height: 500px;
            border: 1px solid #ccc;
            margin: 50px auto 0;
            position: relative;
            overflow: hidden;
        }
        .paragraph {
            width: 360px;
            position: absolute;
            left: 0;
            top: 0;
            padding: 10px 20px;
            font-size: 14px;
            font-family: 'Microsoft Yahei';
            line-height: 32px;
            text-indent: 2em;
        }
        .scroll_bar_con {
            width: 10px;
            height: 490px;
            position: absolute;
            right: 5px;
            top: 5px;
        }
        .scroll_bar {
            width: 10px;
            height: 200px;
            background-color: #ccc;
            position: absolute;
            left: 0;
            top: 0;
            cursor: pointer;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <div class="scroll_con">
        <div class="paragraph">
            掌握HTML是网页的核心，是一种制作万维网页面的标准语言，是万维网浏览器使用的一种语言，它消除了不同计算机之间信息交流的障碍。因此，它是目前网络上应用最为广泛的语言，也是构成网页文档的主要语言，学好HTML是成为Web开发人员的基本条件。
            学好CSS是网页外观的重要一点，CSS可以帮助把网页外观做得更加美观。
            学习JavaScript的基本语法，以及如何使用JavaScript编程将会提高开发人员的个人技能。
            了解Unix和Linux的基本知识虽然这两点很基础，但是开发人员了解Unix和Linux的基本知识是有益无害的。
            了解Web服务器当你对Apache的基本配置，htaccess配置技巧有一些掌握的话，将来必定受益，而且这方面的知识学起来也相对容易。
        </div>
        <div class="scroll_bar_con">
            <div class="scroll_bar">
            </div>
        </div>
    </div>
</body>
</html>
```

## 3、 拖拽

```html
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Document</title>
	<script type="text/javascript" src="jquery-3.3.1.min.js"></script>
	<script type="text/javascript" src="js/jquery-ui.min.js"></script>
	<script type="text/javascript">
		$(function(){
			$('.box').draggable({
				// 限制在x轴向拖动
				//axis:'x',
				// 限定在父级的范围内拖动
				containment:'parent',
				drag:function(ev,ui){
					//console.log(ui);
					//document.title = ui.position.left;
					$('#shownumber').val(parseInt(100*(ui.position.left/600)))
				}
			});
		})
	</script>
	<style type="text/css">
		.con{
			width:800px;
			height:200px;
			border:1px solid #000;
			margin:50px auto 0;
		}
		.box{
			width:200px;
			height:200px;
			background-color: gold;
		}
	</style>
</head>
<body>
	<div class="con">
		<div class="box"></div>
	</div>
	<input type="text" name="" id="shownumber">
</body>
</html>
```

# 21. 移动端js事件

移动端的操作方式和PC端是不同的，移动端主要用手指操作，所以有特殊的touch事件，touch事件包括如下几个事件：

1、touchstart:     //手指放到屏幕上时触发
2、touchmove:      //手指在屏幕上滑动式触发
3、touchend:    //手指离开屏幕时触发
4、touchcancel:     //系统取消touch事件的时候触发，比较少用  

移动端一般有三种操作，点击、滑动、拖动，这三种操作一般是组合使用上面的几个事件来完成的，所有上面的4个事件一般很少单独使用，一般是封装使用来实现这三种操作，可以使用封装成熟的js库。


# 22. zeptojs

Zepto是一个轻量级的针对现代高级浏览器的JavaScript库， 它与jquery有着类似的api。 如果你会用jquery，那么你也会用zepto。Zepto的一些可选功能是专门针对移动端浏览器的；它的最初目标是在移动端提供一个精简的类似jquery的js库。

zepto官网：http://zeptojs.com/
zepto中文api：http://www.css88.com/doc/zeptojs_api/
zepto包含很多模块，默认下载版本包含的模块有Core, Ajax, Event, Form, IE模块，如果还需要其他的模块，可以自定义构建。
zepto自定义构建地址：http://github.e-sites.nl/zeptobuilder/

```html
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Document</title>
	<script type="text/javascript" src="js/zepto.min.js"></script>
	<script type="text/javascript">
		$(function(){
			alert( $('#div1').html() );
		})
	</script>
</head>
<body>
	<div id="div1">这是一个div元素</div>
</body>
</html>
```

# 23. swiper

swiper.js是一款成熟稳定的应用于PC端和移动端的滑动效果插件，一般用来触屏焦点图、触屏整屏滚动等效果。 swiper分为2.x版本和3.x版本，2.x版本支持低版本浏览器(IE7)，3.x放弃支持低版本浏览器，适合应用在移动端。

2.x版本中文网址：<http://2.swiper.com.cn/>
3.x版本中文网地址：<http://www.swiper.com.cn/>

## 1. swiper使用方法

```html
<script type="text/javascript" src="js/swiper.min.js"></script>

<!--
  如果页面引用了jquery或者zepto，就引用 swiper.jquery.min.js,它的容量比swiper.min.js

  <script src="path/to/swiper.jquery.min.js"></script>
-->

......

<link rel="stylesheet" type="text/css" href="css/swiper.min.css">
......

<div class="swiper-container">
  <div class="swiper-wrapper">
    <div class="swiper-slide">slider1</div>
    <div class="swiper-slide">slider2</div>
    <div class="swiper-slide">slider3</div>
  </div>
    <div class="swiper-pagination"></div>
    <div class="swiper-button-prev"></div>
    <div class="swiper-button-next"></div>
</div>

<script> 
var swiper = new Swiper('.swiper-container', {
    pagination: '.swiper-pagination',
  prevButton: '.swiper-button-prev',
  nextButton: '.swiper-button-next',
    initialSlide :1,
  paginationClickable: true,
  loop: true,
  autoplay:3000,
  autoplayDisableOnInteraction:false
});
</script>
```

## 2.  swiper使用参数

1、initialSlide：初始索引值，从0开始
2、direction：滑动方向 horizontal | vertical
3、speed：滑动速度，单位ms
4、autoplay：设置自动播放及播放时间
5、autoplayDisableOnInteraction：用户操作swipe后是否还自动播放，默认是true，不再自动播放
6、pagination：分页圆点
7、paginationClickable：分页圆点是否点击
8、prevButton：上一页箭头
9、nextButton：下一页箭头
10、loop：是否首尾衔接 

### swiper制作实例

swiper制作移动端焦点图实例
