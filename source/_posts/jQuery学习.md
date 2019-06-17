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
