---
title: Python小知识
date: {{date}}
tags:
- Python
categories:
- Python
password: 
---

# 查看 Python 中的关键字
```python
import keyword
print(keyword.kwlist)
```

# 驼峰命名法
1. 小驼峰式命名法
第一个单词以小写字母开始，后续单词的首字母大写
2. 大驼峰式命名法
每一个单词的首字母都采用大写字母

<escape><!-- more --></escape>

# break 和 continue
> break 和  continue 是专门在循环中使用的关键字,只针对当前所在循环有效

- break 某一条件满足时，退出循环，不再执行后续重复的代码
- continue 某一条件满足时，不执行后续重复的代码

1. break
在循环过程中，如果某一个条件满足后，不再希望循环继续执行，可以使用  break 退出循环
```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-

i = 0
while i < 10:
    # break 某一条件满足时，退出循环，不再执行后续重复的代码
    if i == 3:
        break
    print(i)

    i += 1

print("over")
```

2. 如果某一个条件满足后，不希望执行循环代码，但是又不希望退出循环，可以使用  continue
```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-

i = 0
while i < 10:
    # 当 i == 7 时，不希望执行需要重复执行的代码
    if i == 7:
        i += 1
        continue

    # 重复执行的代码
    print(i)

    i += 1

print("over")
```
> 使用  continue 时，条件处理部分的代码，需要特别注意，不小心会出现 死循环

# print函数
- 在默认情况下， print 函数输出内容之后，会自动在内容末尾增加换行
- 如果不希望末尾增加换行，可以在  print 函数输出内容的后面增加  , end=""
- 其中  "" 中间可以指定  print 函数输出内容之后，继续希望显示的内容
```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-

# 向控制台输出内容结束之后，不会换行
print("*", end="")

# 单纯的换行
print("")
```
> end="" 表示向控制台输出内容结束之后，不会换行

# 九九乘法表
```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-

# 定义起始行
row = 1

# 最大打印 9 行
while row <= 9:
    # 定义起始列
    col = 1
    # 最大打印 row 列
    while col <= row:
        # end = ""，表示输出结束后，不换行
        # "\t" 可以在控制台输出一个制表符，协助在输出文本时对齐
        print("%d * %d = %d" % (col,row,col*row),end='\t')
        # 列数 + 1
        col += 1
    # 一行打印完成的换行
    print('')
    # 行数 + 1
    row += 1
```
- \t 在控制台输出一个 制表符，协助在输出文本时 垂直方向 保持对齐
- \n 在控制台输出一个 换行符
> 制表符 的功能是在不使用表格的情况下在 垂直方向 按列对齐文本

# PyCharm 的调试工具
- F8 Step Over 可以单步执行代码，会把函数调用看作是一行代码直接执行
- F7 Step Into 可以单步执行代码，如果是函数，会进入函数内部
1. 先在该行打断点，也就是在该行行号后面点击一下，如下图所示:
![](https://i.imgur.com/Dm0tutK.png)

2. 然后使用debug模式运行代码，快捷键是`Shift+F9`
3. 最下方控制台出现Debug窗口，切换到`Console`
![](https://i.imgur.com/P2hZJPL.png)

4. 最后根据情况使用`F7`或`F8`
![](https://i.imgur.com/G9EDyzx.png)

# pyc字节码文件
> c 是  compiled 编译过 的意思

操作步骤
1. 浏览程序目录会发现一个 `__pycache__` 的目录
2. 该目录下会有好多.pyc文件，比如：ajax_demo.cpython-36.pyc。cpython-36表示  Python 解释器的版本
3. 这个  pyc 文件是由 Python 解释器将 模块的源码 转换为 字节码
- Python 这样保存 字节码 是作为一种启动 速度的优化

字节码
- Python 在解释源程序时是分成两个步骤的
	1. 首先处理源代码，编译 生成一个二进制 字节码
	2. 再对 字节码 进行处理，才会生成 CPU 能够识别的 机器码
- 有了模块的字节码文件之后，下一次运行程序时，如果在 上次保存字节码之后 没有修改过源代码，Python 将会加载 .pyc 文件并跳过编译这个步骤
- 当  Python 重编译时，它会自动检查源文件和字节码文件的时间戳
- 如果你又修改了源代码，下次程序运行时，字节码将自动重新创建

# list列表
![](https://i.imgur.com/vT4jVZg.png)

![](https://i.imgur.com/jqMfvQF.png)

# 元祖
> 元组中 只包含一个元素 时，需要 在元素后面添加逗号

![](https://i.imgur.com/yXgdtCQ.png)

# 字典
![](https://i.imgur.com/YJGiiTP.png)






