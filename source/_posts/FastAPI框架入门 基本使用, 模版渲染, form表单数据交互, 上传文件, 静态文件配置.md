---
title: FastAPI框架入门 基本使用, 模版渲染, form表单数据交互, 上传文件, 静态文件配置
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
# 安装
```
pip install fastapi[all]
pip install unicorn
```

# 基本使用(不能同时支持，get, post方法等要分开写)
```
from fastapi import FastAPI

app = FastAPI()

@app.get('/')  # 点get就支持get请求
def read_root():
    return {"hello":'world'}

if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app,host='127.0.0.1',port=8080)
```

<escape><!-- more --></escape>

# 模版渲染
fastapi本身是没有模版渲染功能的，需要你借助于第三方的模版工具

该框架默认情况下也是借助于jinja2来做模版渲染(flask也是使用jinja2, 如果用过flask, 默认是装过jinja2)
```
# 安装
pip install jinja2

# 基本使用
from starlette.requests import Request
from fastapi import FastAPI
from starlette.templating import Jinja2Templates

app = FastAPI()
# 挂载模版文件夹
tmp = Jinja2Templates(directory='templates')

@app.get('/')
async def get_tmp(request:Request):  # async加了就支持异步  把Request赋值给request
    return tmp.TemplateResponse('index.html',
                                {'request':request,  # 一定要返回request
                                 'args':'hello world'  # 额外的参数可有可无
                                 }
                                )

@app.get('/{item_id}/')  # url后缀 
async def get_item(request:Request,item_id):
    return tmp.TemplateResponse('index.html',
                                {'request':request,
                                 'kw':item_id
                                 })

if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app,host='127.0.0.1',port=8080)

# index.html文件内容
{#  index.html  #}
<body>
<h1>index页面</h1>
<h1>{{ args }}</h1>
<h1>{{ kw }}</h1>
</body>
```

# form表单数据交互
注意： 如果要使用request.form（）支持表单“解析”，则为必需 python-multipart 。
```
# 安装
pip install python-multipart

from starlette.requests import Request
from fastapi import FastAPI,Form
from starlette.templating import Jinja2Templates


app = FastAPI()
tmp = Jinja2Templates(directory='templates')


@app.get('/')  # 接受get请求
async def get_user(request:Request):
    return tmp.TemplateResponse('form.html',{'request':request})


@app.post('/user/')  # 接受post请求
async def get_user(request:Request,
                   username:str=Form(...),  # 直接去请求体里面获取username键对应的值并自动转化成字符串类型
                   pwd:int=Form(...)  # 直接去请求体里面获取pwd键对应的值并自动转化成整型
                   ):
    print(username,type(username))
    print(pwd,type(pwd))
    return tmp.TemplateResponse('form.html',{
        'request':request,
        'username':username,
        'pwd':pwd
    })


if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app,host='127.0.0.1',port=8080)

# form.html文件内容
{#  form.html  #}
<body>
<form action="/user/" method="post">
    <p>username<input type="text" name="username"></p>
    <p>password<input type="password" name="pwd"></p>
    <input type="submit">
</form>
<h1>{{ username }}</h1>
<h1>{{ pwd }}</h1>
</body>
```

# 上传文件
```
from starlette.requests import Request
from fastapi import FastAPI, Form, File, UploadFile
from starlette.templating import Jinja2Templates
from typing import List

app = FastAPI()
# 挂载模板文件夹
tmp = Jinja2Templates(directory='templates')

@app.get('/')  # 接受get请求
async def get_file(request: Request):
    return tmp.TemplateResponse('file.html', {'request': request})

# 单个文件
@app.post('/file/')  # 接受post请求
async def get_user(request: Request,
                   file: bytes = File(...),       # # 把文件对象转为bytes类型,这种类型的文件无法保存
                   file_obj: UploadFile = File(...),    # UploadFile转为文件对象，可以保存文件到本地
                   info: str = Form(...)    # 获取普通键值对
                   ):

    # 保存上传的文件
    contents = await file_obj.read()
    with open("static/file/" + file_obj.filename, "wb") as f:
        f.write(contents)

    return tmp.TemplateResponse('index.html', {
        'request': request,
        'file_size': len(file),
        'file_name': file_obj.filename,
        'info':info,
        'file_content_type':file_obj.content_type
    })

# 多个文件
@app.post('/files/')
async def get_files(request:Request,    
                    files_list:List[bytes] = File(...),  # [文件1的二进制数据,文件2的二进制数据]
                    files_obj_list:List[UploadFile]=File(...)  # [file_obj1,file_obj2,....] # 文件框里可以同时上传多个文件
                    ):

    # 保存上传的多个文件
    for file in files_obj_list:
        contents = await file.read()
        filename = file.filename
        with open("static/file/" + filename, "wb") as f:
            f.write(contents)

    return tmp.TemplateResponse('index.html',
                                {'request':request,
                                 'file_sizes':[len(file) for file in files_list],
                                 'file_names':[file_obj.filename for file_obj in files_obj_list]
                                 }
                                )

if __name__ == '__main__':
    import uvicorn

    uvicorn.run(app, host='127.0.0.1', port=8080)

# html页面文件内容，有俩html文件
{#  file.html  #}
<body>
<h1>单个文件</h1>
<form action="/file/" method="post" enctype="multipart/form-data">
    <input type="file" name="file">
    <input type="file" name="file_obj">
    <input type="text" name="info">
    <input type="submit">
</form>

<h1>多份个文件</h1>
<form action="/files/" method="post" enctype="multipart/form-data">
    <input type="file" name="files_list" multiple>   {# multiple参数支持一次性传多个文件 #}
    <input type="file" name="files_obj_list" multiple>
    <input type="submit">
</form>
</body>

{#  index.html  #}
<body>
<h2>单个文件</h2>
<h1>{{ file_size }}</h1>
<h1>{{ file_name }}</h1>
<h1>{{ info }}</h1>
<h1>{{ file_content_type }}</h1>

<h2>多个文件</h2>
<h1>{{ file_sizes }}</h1>
<h1>{{ file_names }}</h1>
</body>
</html>
```

# 静态文件配置
需要安装aiofiles模块
```
# 安装
pip install aiofiles

from starlette.staticfiles import StaticFiles
# 挂载静态文件夹
app.mount('/static',StaticFiles(directory='static'),name='static')    # mount挂载 第一个参数为应用的前缀，第二个为路径，第三个为别名


# 前端
<link rel="stylesheet" href="{{ url_for('static',path='/css/111.css') }}">    {# url_for后的第一个参数为别名 #}
<script src="{{ url_for('static',path='/js/111.js') }}"></script>
```

示例文件下载：https://files.cnblogs.com/files/sanduzxcvbnm/project_statis_html_2.7z