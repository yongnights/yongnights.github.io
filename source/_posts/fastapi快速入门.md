---
title: FastAPI快速入门
top: 
date: 
tags: 
- Python
- FastAPI
categories: 
- Python
- FastAPI
password: 
---
fastapi是高性能的web框架。他的主要特点是：
- 快速编码
- 减少人为bug
- 直观
- 简易
- 具有交互式文档
- 基于API的开放标准（并与之完全兼容）：OpenAPI（以前称为Swagger）和JSON Schema。

技术背景：python3.6+、Starlette、Pydantic

官方文档地址：https://fastapi.tiangolo.com/

# 安装
```
pip install fastapi
pip install uvicorn
```

<escape><!-- more --></escape>

# quick start
```
# main.py

from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World"}

@app.get("/items/{item_id}")
def read_item(item_id: int, q: str = None):
    return {"item_id": item_id, "q": q}
```

或者
```
# If your code uses async / await, use async def:
from fastapi import FastAPI

app = FastAPI()


@app.get("/")
async def read_root():
    return {"Hello": "World"}


@app.get("/items/{item_id}")
async def read_item(item_id: int, q: str = None):
    return {"item_id": item_id, "q": q}
```

# 运行
```
uvicorn main:app --reload
```
看到如下提示，证明运行成功

![](/fastapi快速入门.assets/1.png)

    main: 表示app所在文件名, the file main.py (the Python "module").
    app：FastAPI实例, the object created inside of main.py with the line app = FastAPI().
    reload：debug模式，可以自动重启,make the server restart after code changes. Only do this for development.

试着请求http://127.0.0.1:8000/items/5?q=somequery，会看到如下返回
```
{"item_id": 5, "q": "somequery"}
```

# 交互文档

试着打开http://127.0.0.1:8000/docs
![](/fastapi快速入门.assets/2.png)

# API文档

试着打开http://127.0.0.1:8000/redoc
![](/fastapi快速入门.assets/3.png)

# update

通过上面的例子，我们已经用fastapi完成了第一个web服务，现在我们再添加一个接口

```

from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()


class Item(BaseModel):
    name: str
    price: float
    is_offer: bool = None


@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.get("/items/{item_id}")
def read_item(item_id: int, q: str = None):
    return {"item_id": item_id, "q": q}


@app.put("/items/{item_id}")
def update_item(item_id: int, item: Item):
    return {"item_name": item.name, "item_id": item_id}
```

此时会发现，服务自动重启了，这是因为我们在启动命令后添加了--reload。再次查看文档，发现同样发生了改变。
到此，你已经可以快速的用fastapi搭建起服务了～
