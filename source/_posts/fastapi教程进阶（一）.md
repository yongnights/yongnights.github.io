---
title: FastAPI教程进阶(一)
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
# 一个简单的栗子
```
from fastapi import FastAPI

app = FastAPI()


@app.get("/")
async def root():
    return {"message": "Hello World"}
```

> FASTAPI继承Starlette，因此在Starlette中的所有可调用的对象在FASTAPI中可以直接引用

<escape><!-- more --></escape>

# 编写步骤

## 步骤一：导入FastAPI
```
from fastapi import FastAPI
```

## 步骤二：创建FastAPI实例
```
app = FastAPI()
```

## 步骤三：创建访问路径
```
@app.get("/")
```

这个路径告诉FastAPI，该装饰器下的方法是用来处理路径是“/”的GET请求
## 步骤四：定义方法，处理请求
```
async def root():
```

## 步骤五：返回响应信息
```
return {"message": "Hello World"}
```

## 步骤六：运行
```
uvicorn main:app --reload
```

# 获取路径参数
```
from fastapi import FastAPI

app = FastAPI()


@app.get("/items/{item_id}")
async def read_item(item_id):
    return {"item_id": item_id}
```

路径中的item_id将会被解析，传递给方法中的item_id。请求http://127.0.0.1:8000/items/foo会返回如下结果：
```
{"item_id":"foo"}
```

也可以在方法中定义参数类型：
```
from fastapi import FastAPI

app = FastAPI()


@app.get("/items/{item_id}")
async def read_item(item_id: int):
    return {"item_id": item_id}
```

继续请求http://127.0.0.1:8000/items/3，会返回
```
{"item_id":3}
```

此时的item_id是int类型的3，而不是string类型，这是因为FastAPI在解析请求时，自动根据声明的类型进行了解析
如果请求http://127.0.0.1:8000/items/foo，此时会返回：
```
{
    "detail": [
        {
            "loc": [
                "path",
                "item_id"
            ],
            "msg": "value is not a valid integer",
            "type": "type_error.integer"
        }
    ]
}
```

这是因为foo并不能转换成int类型。请求http://127.0.0.1:8000/items/4.2也会出现上述错误

> 所有的数据类型验证，都是通过Pydantic完成的

如果想对路径参数做一个预定义，可以使用Enum：
```
from enum import Enum

from fastapi import FastAPI


class ModelName(str, Enum):
    alexnet = "alexnet"
    resnet = "resnet"
    lenet = "lenet"


app = FastAPI()


@app.get("/model/{model_name}")
async def get_model(model_name: ModelName):
    if model_name == ModelName.alexnet:
        return {"model_name": model_name, "message": "Deep Learning FTW!"}
    if model_name.value == "lenet":
        return {"model_name": model_name, "message": "LeCNN all the images"}
    return {"model_name": model_name, "message": "Have some residuals"}
```

打开http://127.0.0.1:8000/docs:
![](/fastapi教程进阶（一）.assets/1.png)
除此之外，假如想接收一个路径参数，它本身就是一个路径，就像/files/{file_path}，而这个file_path是home/johndoe/myfile.txt时，可以写成/files/{file_path:path}：

```
from fastapi import FastAPI

app = FastAPI()


@app.get("/files/{file_path:path}")
async def read_user_me(file_path: str):
    return {"file_path": file_path}
```

    OpenAPI本身不支持在路径参数包含路径，但是可以当作Starlette内部的一个使用方法

此时访问http://127.0.0.1:8000/files/home/johndoe/myfile.txt，返回：
```
{"file_path":"home/johndoe/myfile.txt"}
```

如果将路径改为/files/{file_path}，会返回：
```
{"detail":"Not Found"}
```

# 获取查询参数

这里依旧是一个例子：
```
from fastapi import FastAPI

app = FastAPI()

fake_items_db = [{"item_name": "Foo"}, {"item_name": "Bar"}, {"item_name": "Baz"}]


@app.get("/items/")
async def read_item(skip: int = 0, limit: int = 10):
    return fake_items_db[skip : skip + limit]
```

尝试访问http://127.0.0.1:8000/items/?skip=0&limit=2，返回：
```
[{"item_name":"Foo"},{"item_name":"Bar"}]
```


尝试访问http://127.0.0.1:8000/items/，返回：
```
[{"item_name":"Foo"},{"item_name":"Bar"},{"item_name":"Baz"}]
```


由于我们在定义方法的时候，分别赋予skip和limit默认值，当不添加querystring时，会使用默认值。当然，我们也可以将默认值赋值为None：
```
from fastapi import FastAPI

app = FastAPI()


@app.get("/items/{item_id}")
async def read_item(item_id: str, q: str = None):
    if q:
        return {"item_id": item_id, "q": q}
    return {"item_id": item_id}

```
此时，我们请求http://127.0.0.1:8000/items/1?q=qqq:
```
{"item_id":"1","q":"qqq"}
```

> 值得放心的一点是，FastAPI很聪明，他知道参数来自哪里～

假如，我们不给参数默认值会发生什么情况呢？这里还是一个例子：
```
from fastapi import FastAPI

app = FastAPI()


@app.get("/items/{item_id}")
async def read_user_item(item_id: str, needy: str):
    item = {"item_id": item_id, "needy": needy}
    return item
```

继续请求http://127.0.0.1:8000/items/1，会发现，返回报错：
```
{
  "detail": [
    {
      "loc": [
        "query",
        "needy"
      ],
      "msg": "field required",
      "type": "value_error.missing"
    }
  ]
}
```