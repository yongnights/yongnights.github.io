---
title: Flask-RESTPlus官方文档翻译
date: {{ data }}
tags: 
- Python
- Flask
- Flask-RESTPlus
categories: 
- Python
password: 
---

欢迎文档
Flask-RESTPlus 是对 Flask 的扩展，它增加了对快速开发 REST API 的支持。Flask-RESTPlus 鼓励以最小的设置来实现功能的开发。如果你熟悉 Flask，那么会很容易就能上手 Flask-RESTPlus。Flask-RESTPlus 中提供了大量的装饰器和工具来描述你的 API，并以文档化的形式将这些接口展现出来(通过Swagger来实现)。

# 1. 版本兼容性

支持 2.7+以上版本的python

# 2. 安装

<escape><!-- more --></escape>

## 1. 使用pip方式进行安装
```bash
$ pip install flask-restplus
```
## 2. 使用easy_install方式进行安装

```bash
$ easy_install flask-restplus
```

# 3. 教程文档
## 3.1 安装
使用pip方式进行安装
```bash
pip install flask-restplus
```
开发版本可以通过GitHub的方式进行下载安装
```bash
git clone https://github.com/noirbizarre/flask-restplus.git
cd flask-restplus
pip install -e .[dev,test]
```
Flask-RESTPlus支持Python版本是2.7，3.3，3.4，3.5.同样也支持 PyPy and PyPy3.

## 3.2 快速开始
前提条件:了解Flask，已经安装好Flask和Flask-RESTPlus。

### 3.2.1 初始化
```python
from flask import Flask
from flask_restplus import Api

app = Flask(__name__)
api = Api(app)
```
或者使用工厂模式进行初始化：
```python
from flask import Flask
from flask_restplus import Api

api = Api()
app = Flask(__name__)
api.init_app(app)
```

### 3.2.2 最简单的API
```python
from flask import Flask
from flask_restplus import Resource, Api

app = Flask(__name__)
api = Api(app)

@api.route('/hello')
class HelloWorld(Resource):
	def get(self):
		return {'hello': 'world'}

if __name__ == '__main__':
	app.run(debug=True)
```
保存该文件为api.py.使用python解释器运行该文件，并且开启debug模式方便调试。
```bash
$ python api.py
* Running on http://127.0.0.1:5000/
* Restarting with reloader
```
<table><tr><td bgcolor=red>警告:不要在生产环境开启debug模式</td></tr></table> 

使用curl命令访问该接口:
```bash
$ curl http://127.0.0.1:5000/hello
{"hello": "world"}
```
或者使用浏览器,输入地址:<http://127.0.0.1:5000/hello>进行访问

### 3.2.3 资源路由

```python
from flask import Flask, request
from flask_restplus import Resource, Api

app = Flask(__name__)
api = Api(app)

todos = {}

@api.route('/<string:todo_id>')
class TodoSimple(Resource):
    def get(self, todo_id):
        return {todo_id: todos[todo_id]}

    def put(self, todo_id):
        todos[todo_id] = request.form['data']
        return {todo_id: todos[todo_id]}

if __name__ == '__main__':
    app.run(debug=True)
```
使用curl命令访问:
```bash
$ curl http://localhost:5000/todo1 -d "data=Remember the milk" -X PUT
{"todo1": "Remember the milk"}
$ curl http://localhost:5000/todo1
{"todo1": "Remember the milk"}
$ curl http://localhost:5000/todo2 -d "data=Change my brakepads" -X PUT
{"todo2": "Change my brakepads"}
$ curl http://localhost:5000/todo2
{"todo2": "Change my brakepads"}
```
或者使用python的Requests模块进行访问
```bash
>>> from requests import put, get
>>> put('http://localhost:5000/todo1', data={'data': 'Remember the milk'}).json()
{u'todo1': u'Remember the milk'}
>>> get('http://localhost:5000/todo1').json()
{u'todo1': u'Remember the milk'}
>>> put('http://localhost:5000/todo2', data={'data': 'Change my brakepads'}).json()
{u'todo2': u'Change my brakepads'}
>>> get('http://localhost:5000/todo2').json()
{u'todo2': u'Change my brakepads'}
```
Flask-RESTPlus返回任何可迭代的类型，它会将该返回值转换成响应对象（response），包括
原始的 Flask 响应对象。Flask-RESTPlus 还提供了设置响应码和响应头的功能.
```python
class Todo1(Resource):
    def get(self):
        # Default to 200 OK
        return {'task': 'Hello world'}

class Todo2(Resource):
    def get(self):
        # Set the response code to 201
        return {'task': 'Hello world'}, 201

class Todo3(Resource):
    def get(self):
        # Set the response code to 201 and return custom headers
        return {'task': 'Hello world'}, 201, {'Etag': 'some-opaque-string'}
```

### 3.2.4 端点

可以向 Api 对象的add_resource()方法或 route()装饰器中传入多个 URL，这样每个 URL 都将会路由到该资源上：
```python
api.add_resource(HelloWorld, '/hello', '/world') # HelloWorld为下方的class类名
# 或者下面装饰器方式，二者等价
@api.route('/hello', '/world')
class HelloWorld(Resource):
	pass
```

也可以将 URL 中的部分内容设置成变量，以此来匹配资源方法
```python
api.add_resource(HelloWorld, '/todo/<int:todo_id>', endpoint='todo_ep')
# 或者下面装饰器方式，二者等价
@api.route('/todo/<int:todo_id>', endpoint='todo_ep')
class HelloWorld(Resource):
    pass
```

注意:如果一个请求（request）与应用的任何端点都不匹配，那么 Flask-RESTPlus 将会返回一个 404 错误信息，并给出其他与所请求端点最匹配的建议信息。不过，我们可以通过在程序配置中设置 ERROR_404_HELP 为 False 来关闭该功能。
```python
app.config['ERROR_404_HELP'] = False
```

### 3.2.5 参数解析
Flask-RESTPlus 内置支持对请求数据的验证，这一功能是通过使用一个类似于 argparse 的库来实现的
```python
from flask_restplus import reqparse

parser = reqparse.RequestParser()
parser.add_argument('rate', type=int, help='Rate to charge for this resource')

args = parser.parse_args() # 放到需要验证用户提交的数据的函数方法中
```
注意：parse_args()返回的是一个 Python 字典，而不是自定义数据结构。

使用 RequestParser 类还能获取完整的错误信息。如果一个参数未验证通过，Flask-RESTPlus 将响应一个 400 错误请求，以及一个高亮错误信息的响应。示例程序如下：
```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-

from flask import Flask, request
from flask_restplus import Api, Resource, reqparse, fields

app = Flask(__name__)
# app.config['ERROR_404_HELP'] = False
api = Api(app)

parser = reqparse.RequestParser()
parser.add_argument('rate', type=int, required=True,help='Rate to charge for this resource')
# parser.add_argument('data', required=True,help='data to charge for this resource')


todos = {
    '1':'eat',
    '2':'sleep'
}

@api.route('/<string:todo_id>')
class TodoSimple(Resource):
    def get(self, todo_id):
        return {todo_id: todos[todo_id]}

    def put(self, todo_id):
        args = parser.parse_args()
        # print(args)
        todos[todo_id] = request.form['data']
        return {todo_id: todos[todo_id]}
        # return args
```

其中，parser.add_argument('rate', type=int,required=True,help='Rate to charge for this resource')表示，参数名为 rate，数据类型为 int，请求时必须发送此参数，如果验证不通过时将会返回 help 指定的信息。
运行程序并使用 curl 进行访问，几种情况的验证结果如下：
      提供 rate 值，但不是 int 型（验证不通过）
      提供 rate 值，且是 int 型（验证通过）
      不提供 rate 值（验证不通过）

注:使用curl访问的时候,除了需要传递data参数值外,还需要传递rate参数值才行.当然data参数值也可以进行验证.

参数 strict=True 的含义:若传递了未定义的参数则报错.
```python
args = parser.parse_args(strict=True)
```

### 3.2.6 数据格式化
默认情况下，在返回的可迭代对象中的所有字段都会原样返回,但是当涉及到对象时将会变得非常棘
手.Flask-RESTPlus 提供了 fields 模块和marshal_with()装饰器来解决返回的是对象的问题.
```python
from collections import OrderedDict

from flask import Flask
from flask_restplus import fields, Api, Resource

app = Flask(__name__)
api = Api(app)

# 格式化返回的是对象的值.也就是说返回的是对象中的如下格式化的值
model = api.model('Model', { 
    'task': fields.String,
    'uri': fields.Url('todo_ep',absolute=True) # absolute表示返回绝对路径
})

class TodoDao(object):
    def __init__(self, todo_id, task):
        self.todo_id = todo_id
        self.task = task

        # This field will not be sent in the response
        self.status = 'active'

@api.route('/todo',endpoint='todo_ep') # 不指定端点默认是视图函数名
class Todo(Resource):
    @api.marshal_with(model) # 返回对象格式化引用的装饰器
    def get(self, **kwargs):
        return TodoDao(todo_id='my_todo', task='Remember the milk') # 返回的是一个对象
```
此功能的作用如下:若返回的是一个对象,可以通话该装饰器,格式化该对象要返回的数据,数据表查询比较常用

顺序保留
默认情况下，字段顺序并未得到保留，因为它会损耗性能。不过，如果你确实需要保留字段顺序，那么可以向类或函数传入一个 ordered=True 的参数项，以此强制进行顺序保留：
      Api 全局保留：api = Api(ordered = True)
      Namespace 全局保留：ns = Namespace(ordered=True)
      marshal()局部保留：return marshal(data, fields, ordered=True)

marshal()局部保留的例子如下:
```python
from collections import OrderedDict

from flask import Flask
from flask_restplus import fields, Api, Resource

app = Flask(__name__)
api = Api(app)

# 格式化返回的是对象的值.也就是说返回的是对象中的如下格式化的值
model = api.model('Model', { 
    'task': fields.String,
    'uri': fields.Url('todo_ep',absolute=True) # absolute表示返回绝对路径
})

class TodoDao(object):
    def __init__(self, todo_id, task):
        self.todo_id = todo_id
        self.task = task

        # This field will not be sent in the response
        self.status = 'active'

@api.route('/todo',endpoint='todo_ep') # 不指定端点默认是视图函数名
class Todo(Resource):
    @api.marshal_with(model) # 返回对象格式化引用的装饰器
    def get(self, **kwargs):
        # return TodoDao(todo_id='my_todo', task='Remember the milk') # 返回的是一个对象
        return api.marshal(TodoDao(todo_id='my_todo', task='Remember the milk'), model, ordered=True)
```

### 3.2.7 完整例子
```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-

from flask import Flask
from flask_restplus import Api, Resource, fields
from werkzeug.contrib.fixers import ProxyFix

app = Flask(__name__)
app.wsgi_app = ProxyFix(app.wsgi_app)
api = Api(app, version='1.0', title='TodoMVC API',
          description='A simple TodoMVC API',
          )

ns = api.namespace('todos', description='TODO operations')

todo = api.model('Todo', {
    'id': fields.Integer(readOnly=True, description='The task unique identifier'),
    'task': fields.String(required=True, description='The task details')
})


class TodoDAO(object):
    def __init__(self):
        self.counter = 0
        self.todos = []

    def get(self, id):
        for todo in self.todos:
            if todo['id'] == id:
                return todo
        api.abort(404, "Todo {} doesn't exist".format(id))

    def create(self, data):
        todo = data
        todo['id'] = self.counter = self.counter + 1
        self.todos.append(todo)
        return todo

    def update(self, id, data):
        todo = self.get(id)
        todo.update(data)
        return todo

    def delete(self, id):
        todo = self.get(id)
        self.todos.remove(todo)


DAO = TodoDAO()
DAO.create({'task': 'Build an API'})
DAO.create({'task': '?????'})
DAO.create({'task': 'profit!'})


@ns.route('/')
class TodoList(Resource):
    '''Shows a list of all todos, and lets you POST to add new tasks'''

    @ns.doc('list_todos')
    @ns.marshal_list_with(todo)
    def get(self):
        '''List all tasks'''
        return DAO.todos

    @ns.doc('create_todo')
    @ns.expect(todo)
    @ns.marshal_with(todo, code=201)
    def post(self):
        '''Create a new task'''
        return DAO.create(api.payload), 201


@ns.route('/<int:id>')
@ns.response(404, 'Todo not found')
@ns.param('id', 'The task identifier')
class Todo(Resource):
    '''Show a single todo item and lets you delete them'''

    @ns.doc('get_todo')
    @ns.marshal_with(todo)
    def get(self, id):
        '''Fetch a given resource'''
        return DAO.get(id)

    @ns.doc('delete_todo')
    @ns.response(204, 'Todo deleted')
    def delete(self, id):
        '''Delete a task given its identifier'''
        DAO.delete(id)
        return '', 204

    @ns.expect(todo)
    @ns.marshal_with(todo)
    def put(self, id):
        '''Update a task given its identifier'''
        return DAO.update(id, api.payload)


if __name__ == '__main__':
    app.run(port=8000,debug=True)
```

# 4.响应编组
## 4.1 基本使用
```python
from flask_restplus import Resource, fields

model = api.model('Model', {
    'name': fields.String,
    'address': fields.String,
    'date_updated': fields.DateTime(dt_format='rfc822'), # 对返回响应的数据做进一步的处理
})

@api.route('/todo')
class Todo(Resource):
    @api.marshal_with(model, envelope='resource') # envelope的作用是做返回值字典的键
    def get(self, **kwargs):
        return db_get_todo()  # Some function that queries the db
```
下方结果对上述代码稍作修改,主要是为了体现@api.marshal_with(model, envelope='resource')中envelope的作用
```bash
C:\Users\Administrator>curl http://127.0.0.1:5000/todo
{
    "resource": {
        "name": "sandu",
        "priority": "Normal",
        "status": "Read"
    }
}
```
注:@api.marshal_with()装饰器的作用等价于如下:
```python
returtn api.marshal(被装饰对象,model,envelope='resource'),200
```

## 4.2 重命名属性
该功能主要作用是同一个变量,在代码内部使用一个同一个变量名,提供给用户时显示的是另一个变量名
```python
model = {
    'name': fields.String(attribute='private_name'),
    'address': fields.String,
}
```
完整示例如下:
```python
from flask import Flask, request
from flask_restplus import Api, Resource, reqparse, fields

app = Flask(__name__)
# app.config['ERROR_404_HELP'] = False
api = Api(app)

class TodoDao(object):
    def __init__(self, private_name, address,flags):
        self.private_name = private_name
        self.address = address
        self.flags = flags

        # This field will not be sent in the response
        self.priority = None
        self.status = None


class UrgentItem(fields.Raw):
    def format(self, value):
        return "Urgent" if value == 1 else "Normal"


class UnreadItem(fields.Raw):
    def format(self, value):
        return "Unread" if value ==2 else "Read"


model = {
    'name': fields.String(attribute='private_name'),
    'priority': UrgentItem(attribute='flags'),
    'status': UnreadItem(attribute='flags'),
    'age':fields.Integer(default=20)
}

@api.route('/todo')
class Todo(Resource):
    # @api.marshal_with(model, envelope='resource')
    def get(self, **kwargs):
        return api.marshal(TodoDao(private_name='sandu', address='beijing',flags=1), model,                       envelope='resource')  # Some function that queries the db


if __name__ == '__main__':
    app.run(debug=True)
```
注意看上述代码的示例:代码中使用的变量名是private_name,返回给用户的结果中显示的变量名是name,具体如下:
```python
C:\Users\Administrator>curl http://127.0.0.1:5000/todo
{
    "resource": {
        "name": "sandu",
        "priority": "Urgent",
        "status": "Read",
        "age": 20
    }
}
```
也可以指定为 lambda 表达式或者其他可调用的语句
```python
model = {
    'name': fields.String(attribute=lambda x: x._private_name),
    'address': fields.String,
}
```
还可以利用 attribute 来访问嵌套的属性
```python
model = {
    'name': fields.String(attribute='people_list.0.person_dictionary.name'),
    'address': fields.String,
}
```
## 4.3 默认值
为对象中不存在但是返回值存在的指定默认值,重命名例子中的age就是,如下所示:
```python
model = {
    'name': fields.String(attribute='private_name'),
    'priority': UrgentItem(attribute='flags'),
    'status': UnreadItem(attribute='flags'),
    'age':fields.Integer(default=20)
}
```

## 4.4 自定义字段及多值情况
该功能通俗点来说是根据值得不同返回对应的不同的结果
如上述的部分代码:
```python
class UrgentItem(fields.Raw):
    def format(self, value):
        return "Urgent" if value == 1 else "Normal"


class UnreadItem(fields.Raw):
    def format(self, value):
        return "Unread" if value ==2 else "Read"


model = {
    'name': fields.String(attribute='private_name'),
    'priority': UrgentItem(attribute='flags'),
    'status': UnreadItem(attribute='flags'),
    'age':fields.Integer(default=20)
}

@api.route('/todo')
class Todo(Resource):
    # @api.marshal_with(model, envelope='resource')
    def get(self, **kwargs):
        return api.marshal(TodoDao(private_name='sandu', address='beijing',flags=1), model,
                           envelope='resource')  # Some function that queries the db
```
当返回的TodoDao对象中,flags的值不同,返回的参数priority和status值也会根据上述两个class的返回结果而不同.
当flags=1时,返回的结果是:
```python
C:\Users\Administrator>curl http://127.0.0.1:5000/todo
{
    "resource": {
        "name": "sandu",
        "priority": "Urgent",
        "status": "Read",
        "age": 20
    }
}
```
当flags=2时,返回的结果是:
```python
C:\Users\Administrator>curl http://127.0.0.1:5000/todo
{
    "resource": {
        "name": "sandu",
        "priority": "Normal",
        "status": "Unread",
        "age": 20
    }
}
```

## 4.5 URL和其他字段
该返回对象值增加额外的字段
```python
class RandomNumber(fields.Raw):
    def output(self,key,obj,ordered=None):
        return random.random()


model = {
    'name': fields.String(attribute='private_name'),
    'priority': UrgentItem(attribute='flags'),
    'status': UnreadItem(attribute='flags'),
    'age': fields.Integer(default=20),
    'random': RandomNumber(),
}
```
> 注意:以上代码经过修改,跟官网文档不一样,主要是output()中多了一个ordered=None,不然不加这个会报错:TypeError: output() got an unexpected keyword argument 'ordered'
> 可以把def output(self,key,obj,ordered=None)看成是一个固定写法,只修改其返回值即可.

返回结果是:
```bash
C:\Users\Administrator>curl http://127.0.0.1:5000/todo
{
    "resource": {
        "name": "sandu",
        "priority": "Normal",
        "status": "Unread",
        "age": 20,
        "random": 0.12434240543068387
    }
}
```
默认情况下，fields.Url 返回的是一个相对于根路径的相对 URI,不过也可以返回绝对路径,以及地址的schema(协议)等.
```python
model = {
    'uri': fields.Url('todo_resource', absolute=True)
    'https_uri': fields.Url('todo_resource', absolute=True, scheme='https')
}
```

## 4.6 复杂结构
提供一个扁平的结构，而 marshal()则会按照定义的规则将其转换成一个嵌套结构
```bash
>>> from flask_restplus import fields, marshal
>>> import json
>>>
>>> resource_fields = {'name': fields.String}
>>> resource_fields['address'] = {}
>>> resource_fields['address']['line 1'] = fields.String(attribute='addr1')
>>> resource_fields['address']['line 2'] = fields.String(attribute='addr2')
>>> resource_fields['address']['city'] = fields.String
>>> resource_fields['address']['state'] = fields.String
>>> resource_fields['address']['zip'] = fields.String
>>> data = {'name': 'bob', 'addr1': '123 fake street', 'addr2': '', 'city': 'New York', 'state': 'NY', 'zip': '10468'}
>>> json.dumps(marshal(data, resource_fields))
'{"name": "bob", "address": {"line 1": "123 fake street", "line 2": "", "state": "NY", "zip": "10468", "city": "New York"}}'
```

注意：上述示例中的 address 字段其实并不存在于数据对象中，但是任何子字段都能够直接从对象中访问该属性，就像它们并不是嵌套关系一样。

## 4.7 列表字段
将字段解组成列表
```python
>>> from flask_restplus import fields, marshal
>>> import json
>>>
>>> resource_fields = {'name': fields.String, 'first_names': fields.List(fields.String)}
>>> data = {'name': 'Bougnazal', 'first_names' : ['Emile', 'Raoul']}
>>> json.dumps(marshal(data, resource_fields))
>>> '{"first_names": ["Emile", "Raoul"], "name": "Bougnazal"}'
```

## 4.8 嵌套字段
使用 Nested 来将嵌套的数据结构解组，并对其进行适当的渲染
```python
>>> from flask_restplus import fields, marshal
>>> import json
>>>
>>> address_fields = {}
>>> address_fields['line 1'] = fields.String(attribute='addr1')
>>> address_fields['line 2'] = fields.String(attribute='addr2')
>>> address_fields['city'] = fields.String(attribute='city')
>>> address_fields['state'] = fields.String(attribute='state')
>>> address_fields['zip'] = fields.String(attribute='zip')
>>>
>>> resource_fields = {}
>>> resource_fields['name'] = fields.String
>>> resource_fields['billing_address'] = fields.Nested(address_fields)
>>> resource_fields['shipping_address'] = fields.Nested(address_fields)
>>> address1 = {'addr1': '123 fake street', 'city': 'New York', 'state': 'NY', 'zip': '10468'}
>>> address2 = {'addr1': '555 nowhere', 'city': 'New York', 'state': 'NY', 'zip': '10468'}
>>> data = {'name': 'bob', 'billing_address': address1, 'shipping_address': address2}
>>>
>>> json.dumps(marshal(data, resource_fields))
'{"billing_address": {"line 1": "123 fake street", "line 2": null, "state": "NY", "zip": "10468", "city": "New York"}, "name": "bob", "shipping_address": {"line 1": "555 nowhere", "line 2": null, "state": "NY", "zip": "10468", "city": "New York"}}'
```
<font face="微软雅黑" color="red" size="3">
该示例使用两个 Nested 字段。Nested 构造函数接受一个字段组成的字典，然后将其渲染成一个子 fields.input 对象。Nested 构造函数和嵌套字典（上个例子）之间的重要不同点是：属性的上下文环境。在本例中，billing_address是一个复杂的对象，它拥有自己的字段，而传入到嵌套字段中的上下文环境是子对象，而不是原始的 data 对象。也就是说：data.billing_address.addr1处于该范围，而在前一示例中，data.addr1 则是位置属性。记住：Nested 和List 对象为属性创建了一个新的作用范围。
</font>
默认情况下，当子对象为 None 时，将会为嵌套字段生成一个包含默认值的对象，而不是 null 值。可以通过传入 allow_null 参数来修改这一点

使用 Nested 和 List 来编组更复杂对象的列表
```python
user_fields = api.model('User', {
    'id': fields.Integer,
    'name': fields.String,
})

user_list_fields = api.model('UserList', {
    'users': fields.List(fields.Nested(user_fields)),
})
```

## 4.9 api.model()工厂
model()工厂允许我们实例化并注册模型到我们的 API 和命名空间（Namespace）中
```python
my_fields = api.model('MyModel', {
    'name': fields.String,
    'age': fields.Integer(min=0)
})

# Equivalent to
from flask_restplus import Model

my_fields = Model('MyModel', {
    'name': fields.String,
    'age': fields.Integer(min=0)
})
api.models[my_fields.name] = my_fields
```

### 4.9.1 clone实现复制
Model.clone()方法使得我们可以实例化一个增强模型，它能够省去我们复制所有字段的麻烦
跟python的类继承有点类似，注意以下两种不同方式的写法。
如下面的例子,child除了有其自身的age之外,还有克隆parent过来的name
```python
parent = Model('Parent', {
    'name': fields.String
})

child = parent.clone('Child', {
    'age': fields.Integer
})
```

示例代码如下：
```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-

from flask import Flask
from flask_restplus import Resource, Api, fields,Model

app = Flask(__name__)
api = Api(app)

parent = Model('Parent', {
    'name': fields.String
})

child = parent.clone('Child', {
    'age': fields.Integer
})

api.models[parent.name] = parent
api.models[child.name] = child

class Todo(object):
    def __init__(self, name, age):
        self.name = name
        self.age = age


@api.route('/hello')
class HelloWorld(Resource):
    @api.marshal_with(child)
    def get(self):
        # return Model(Todo('haha', 24),child)
        return Todo('haha', 24)

if __name__ == '__main__':
    app.run(debug=True)
```
结果如下：
```python
C:\Users\sandu>curl http://127.0.0.1:5000/hello
{
    "name": "haha",
    "age": 24
}
```

Api/Namespace.clone 也会将其注册到 API
```python
parent = api.model('Parent', {
    'name': fields.String
})

child = api.clone('Child', parent, {
    'age': fields.Integer
})
```

示例代码：
```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-

from flask import Flask
from flask_restplus import Resource, Api, fields,Model

app = Flask(__name__)
api = Api(app)

parent = api.model('Parent', {
    'name': fields.String
})

child = api.clone('Child', parent,{
    'age': fields.Integer
})

class Todo(object):
    def __init__(self, name, age):
        self.name = name
        self.age = age


@api.route('/hello')
class HelloWorld(Resource):
    @api.marshal_with(child)
    def get(self):
        # return Model(Todo('haha', 24),child)
        return Todo('haha', 24)
```

结果如下：
```python
C:\Users\sandu>curl http://127.0.0.1:5000/hello
{
    "name": "haha",
    "age": 24
}
```

### 4.9.2 api.inherit  实现多态
Model.inherit()方法允许我们以“Swagger”方式扩展模型，并开始解决多态问题
```python
parent = api.model('Parent', {
    'name': fields.String,
    'class': fields.String(discriminator=True)
})

child = api.inherit('Child', parent, {
    'extra': fields.String
})
```
示例代码：
```python
from flask import Flask
from flask_restplus import Resource, Api, fields,Model

app = Flask(__name__)
api = Api(app)

parent = api.model('Parent', {
    'name': fields.String,
    'class': fields.String(discriminator=True) # 根据运行结果识别其作用
})

child = api.inherit('Child', parent,{
    'extra': fields.String
})

class Todo(object):
    def __init__(self, name, age):
        self.name = name
        self.age = age


@api.route('/hello')
class HelloWorld(Resource):
    @api.marshal_with(child)
    def get(self):
        # return Model(Todo('haha', 24),child)
        return Todo('haha', 24)

if __name__ == '__main__':
    app.run(debug=True)
```
运行结果：
```python
C:\Users\sandu>curl http://127.0.0.1:5000/hello
{
    "extra": null,
    "name": "haha",
    "class": "Child"
}
```
使用浏览器访问(<http://127.0.0.1:5000/>)的话会看到Models中有两个

Api/Namespace.clone 会将 parent 和 child 都注册到 Swagger 模型定义中
```python
parent = Model('Parent', {
    'name': fields.String,
    'class': fields.String(discriminator=True)
})

child = parent.inherit('Child', {
    'extra': fields.String
})
```

示例代码：
```python
from flask import Flask
from flask_restplus import Resource, Api, fields,Model

app = Flask(__name__)
api = Api(app)

parent = Model('Parent', {
    'name': fields.String,
    'class': fields.String() # 此时没有discriminator=True，注意运行结果
})

child = parent.inherit('Child', {
    'extra': fields.String
})

api.models[parent.name] = parent
api.models[child.name] = child

class Todo(object):
    def __init__(self, name, age):
        self.name = name
        self.age = age


@api.route('/hello')
class HelloWorld(Resource):
    @api.marshal_with(child)
    def get(self):
        # return Model(Todo('haha', 24),child)
        return Todo('haha', 24)

if __name__ == '__main__':
    app.run(debug=True)
```
运行结果：
```python
C:\Users\sandu>curl http://127.0.0.1:5000/hello
{
    "extra": null,
    "name": "haha",
    "class": null
}
```
本例中的class字段只有在其不存在于序列化对象中时，才会以序列化的模型名称进行填充。

Polymorph字段允许你指定Python类和字段规范的映射关系：
```python
mapping = {
    Child1: child1_fields,
    Child2: child2_fields,
}

fields = api.model('Thing', {
    owner: fields.Polymorph(mapping)
})
```
注：这段还未看明白啥意思，具体咋操作的，结果如何，留待以后研究。

## 4.10 自定义字段
自定义输出字段使得我们可以在无需直接修改内部对象的情况下，进行自定义的输出结果格式化操作。我们只需让类继承Raw，并实现format()方法：
```python
class AllCapsString(fields.Raw):
    def format(self, value):
        return value.upper()

# example usage
fields = {
    'name': fields.String,
    'all_caps_name': AllCapsString(attribute='name'),
}
```
示例代码：
```python
from flask import Flask
from flask_restplus import Resource, Api, fields,Model

app = Flask(__name__)
api = Api(app)

class AllCapsString(fields.Raw):
    def format(self, value):
        return value.upper()


fields = {
    'name': fields.String,
    'all_caps_name': AllCapsString(attribute='age'), # 其值是根据attribute指定的而定，不如attribute='age'，则输出的结果是‘24’，若是attribute='name'，则输出结果是“HAHA”,具体详看下方的运行结果
}

class Todo(object):
    def __init__(self, name, age):
        self.name = name
        self.age = age

@api.route('/hello')
class HelloWorld(Resource):
    @api.marshal_with(fields)
    def get(self):
        # return Model(Todo('haha', 24),child)
        return Todo('haha', '24')

if __name__ == '__main__':
    app.run(debug=True)
```
运行结果如下:
```bash
C:\Users\sandu>curl http://127.0.0.1:5000/hello
{
    "name": "haha",
    "all_caps_name": "24"
}

C:\Users\sandu>curl http://127.0.0.1:5000/hello
{
    "name": "haha",
    "all_caps_name": "HAHA"
}
```
也可以使用__schema_format__、__schema_type__和__schema_example__来指定生成的类型和例子：
```python
class MyIntField(fields.Integer):
    __schema_format__ = 'int64'

class MySpecialField(fields.Raw):
    __schema_type__ = 'some-type'
    __schema_format__ = 'some-format'

class MyVerySpecialField(fields.Raw):
    __schema_example__ = 'hello, world'
```
实际代码：
```python
from flask import Flask
from flask_restplus import Resource, Api, fields,Model

app = Flask(__name__)
api = Api(app)

class AllCapsString(fields.Raw):
    def format(self, value):
        return value.upper()

class MyIntField(fields.Integer):
    __schema_format__ = 'int64'

class MySpecialField(fields.Raw): # 具体作用还有待研究
    __schema_type__ = 'string'
    __schema_format__ = 'string'
    __schema_example__ = 'hello, world'

fields = {
    'name': fields.String,
    'all_caps_name': AllCapsString(attribute='name'),
    'age':MyIntField(), # 有转换数据类型的功能，输入的是字符串'22',运行结果显示的是数字22
    'class':MySpecialField(attribute='banji')
}

class Todo(object):
    def __init__(self, name, age, banji):
        self.name = name
        self.age = age
        self.banji = banji

@api.route('/hello')
class HelloWorld(Resource):
    @api.marshal_with(fields)
    def get(self):
        # return Model(Todo('haha', 24),child)
        return Todo('haha','22','erjini')

if __name__ == '__main__':
    app.run(debug=True)
```

## 4.11 跳过值为None的字段
将可选参数skip_none设置为True
```bash
>>> from flask_restplus import Model, fields, marshal_with
>>> import json
>>> model = Model('Model', {
...     'name': fields.String,
...     'address_1': fields.String,
...     'address_2': fields.String
... })
>>> @marshal_with(model, skip_none=True)
... def get():
...     return {'name': 'John', 'address_1': None}
...
>>> get()
OrderedDict([('name', 'John')])
```
可以看到，address_1和address_2被marshal_with()跳过了。address_1被跳过是因为它的值为None，而address_2被跳过是因为get()返回的字典中并不包含address_2这个key。

## 4.12跳过嵌套字段中的None字段
```bash
>>> from flask_restplus import Model, fields, marshal_with
>>> import json
>>> model = Model('Model', {
...     'name': fields.String,
...     'location': fields.Nested(location_model, skip_none=True)
... })
```

## 4.13 使用JSON Schema定义模型
注：这个还不知道具体咋使用的
```python
address = api.schema_model('Address', {
    'properties': {
        'road': {
            'type': 'string'
        },
    },
    'type': 'object'
})

person = address = api.schema_model('Person', {
    'required': ['address'],
    'properties': {
        'name': {
            'type': 'string'
        },
        'age': {
            'type': 'integer'
        },
        'birthdate': {
            'type': 'string',
            'format': 'date-time'
        },
        'address': {
            '$ref': '#/definitions/Address',
        }
    },
    'type': 'object'
})
```

# 5.请求解析
Flask-RESTPlus的请求解析接口reqparse是模仿argparse接口实现的。它的设计目的是对Flask中flask.request对象上的任何变量提供简单和统一的访问方式。

## 5.1 基本参数
如下是一个简单示例，在flask.Request.values字典中查找两个参数：一个整数和一个字符串：
```python
from flask_restplus import reqparse

parser = reqparse.RequestParser()
parser.add_argument('rate', type=int, help='Rate cannot be converted')
parser.add_argument('name')

args = parser.parse_args()
```
> 默认参数类型是unicode字符串。在Python3中为str类型，而在Python2中为unicode。

如果指定了help变量的值，那么在解析请求时，如果出现了类型错误，那么会将它渲染为错误信息。如果未指定help信息，那么默认的行为是返回类型错误信息本身。

> 默认情况下，参数不是必需的。并且，如果请求中提供的某些参数不是RequestParser的部分内容，那么这些参数将会被忽略。
> 请求解析器中声明的参数，如果在请求中并未设置这些参数值，那么它们将会默认设置为None。

## 5.2 必须参数
如果需要确保某个参数必须提供，那么可以在调用add_argument()时传入required=True的参数项：
```python
parser.add_argument('name', required=True, help="Name cannot be blank!")
```
> 如果请求中未提供该参数，那么将会返回错误信息

## 5.3 多值和列表
为某个key接受多个值以构成列表，那么可以传入action='append'：
```python
parser.add_argument('name', action='append')
```
此时的查询格式如下所示：
```bash
curl http://api.example.com -d "name=bob" -d "name=sue" -d "name=joe"
```
而程序中获取到的参数如下所示：
```python
args = parser.parse_args()
args['name'] # ['bob', 'sue', 'joe']
```

如果期望一个逗号分隔的列表，那么可以使用action='split'：
```python
parser.add_argument('fruits', action='split')
```
此时的查询格式如下所示：
```bash
curl http://api.example.com -d "fruits=apple,lemon,cherry"
```
而程序中获取到的参数如下所示：
```python
args = parser.parse_args()
args['fruits'] # ['apple', 'lemon', 'cherry']
```

## 5.4 其他目标
如果期望参数一旦被解析，就将其存储为其他名字，那么可以使用dest参数：
```python
parser.add_argument('name', dest='public_name')

args = parser.parse_args()
args['public_name']
```

## 5.5 参数位置
默认情况下，RequestParser尝试从flask.Request.values和flask.Request.json中解析值。

在add_argument()中使用location参数来指定获取值的其他位置。可以使用flask.Request上的任何变量，例如：

```python
# 仅仅在POST body中查找
parser.add_argument('name', type=int, location='form')

# 仅仅在querystring中查找
parser.add_argument('PageSize', type=int, location='args')

# 从请求头中查找
parser.add_argument('User-Agent', location='headers')

# 从http cookies中查找
parser.add_argument('session_id', location='cookies')

# 从上传文件中查找
parser.add_argument('picture', type=werkzeug.datastructures.FileStorage, location='files')
```
> 当location='json'时只能使用type=list
> 使用location='form'既能验证表单数据，又能为表单字段文档化

## 5.6 参数多位置
为location参数赋一个列表就能为参数指定多个位置：
```python
parser.add_argument('text', location=['headers', 'values'])
```

当指定多个参数位置时，那么所有指定位置的参数将会组成一个MultiDict。其中，列表中最后位置处的参数将会优先存储在结果集中。

如果参数位置列表中包含headers位置，那么参数名将变成对大小写敏感，并且必须匹配它们的标题大小写名称（见str.title()）。

指定location='headers'（而不是作为列表的某个元素）将保留大小写不敏感的特性。

## 5.7 高级类型处理
inputs模块中提供了一些常用的类型处理方法，如下：
	- boolean()用于广泛的布尔值处理
	- ipv4()和ipv6()用于IP地址
	- date_from_iso8601()和datetime_from_iso8601()用于ISO8601 date和datetime处理
只需要使用它们作为type参数的值即可：
```python
parser.add_argument('flag', type=inputs.boolean)
```
我们也可以编写自己的输入类型：
```python
def my_type(value):
    '''Parse my type'''
    if not condition:
        raise ValueError('This is not my type')
    return parse(value)

# Swagger documntation
my_type.__schema__ = {'type': 'string', 'format': 'my-custom-format'}
```

## 5.8 解析器继承
可以编写一个父解析器，父解析器中包含所有共同的参数，然后利用copy()方法来扩展解析器。另外，也可以利用replace_argument()来覆写父解析器中的任何参数，或者利用remove_argument()完全移除父解析器中的某个参数。例如：
```python
from flask_restplus import reqparse

parser = reqparse.RequestParser()
parser.add_argument('foo', type=int)

parser_copy = parser.copy()
parser_copy.add_argument('bar', type=int)

# parser_copy has both 'foo' and 'bar'

parser_copy.replace_argument('foo', required=True, location='json')
# 'foo' is now a required str located in json, not an int as defined
#  by original parser

parser_copy.remove_argument('foo')
# parser_copy no longer has 'foo' argument
```

## 5.9 文件上传
为了利用RequestParser处理文件上传问题，我们需要将location变量值设置为files，并设置type值为FileStorage。如下所示：
```python
from werkzeug.datastructures import FileStorage
import tempfile

upload_parser = api.parser()
upload_parser.add_argument('file', location='files',
                           type=FileStorage, required=True)


@api.route('/upload/')
@api.expect(upload_parser)
class Upload(Resource):
    def post(self):
        args = upload_parser.parse_args()
        file_ = args['file']
        file_descriptor, filename = tempfile.mkstemp(suffix='.xlsx')
        file_.save(filename) # 保存文件
        # print(filename) # 获取文件的绝对路径
        return 'success'
```

## 5.10 错误处理
RequestParser处理错误的默认方式是在第一个错误产生时中断。当我们拥有需要花费一定时间来处理的参数时，这种方式是有好处的。然而，通常来说，将所有产生的错误都绑定在一起，然后同时一次性返回给客户端，这种方式则更加友好。这种方式既可以在Flask应用级别指定，也可以在特定的RequestParser实例级别指定。为了调用一个包含错误绑定选项的RequestParser，需要传入参数bundle_errors。例如：
```python
from flask_restplus import reqparse

parser = reqparse.RequestParser(bundle_errors=True)
parser.add_argument('foo', type=int, required=True)
parser.add_argument('bar', type=int, required=True)

# # 如果某个请求中同时不包含'foo'和'bar'，那么返回的错误将看起来如下所示：
{
    "message":  {
        "foo": "foo error message",
        "bar": "bar error message"
    }
}

# 默认操作将仅仅返回第一个错误
parser = RequestParser()
parser.add_argument('foo', type=int, required=True)
parser.add_argument('bar', type=int, required=True)

{
    "message":  {
        "foo": "foo error message"
    }
}
```
示例代码：
```python
from flask import Flask
from flask_restplus import Resource, Api, reqparse

app = Flask(__name__)
api = Api(app)

parser = reqparse.RequestParser(bundle_errors=True)
parser.add_argument('foo', type=int, required=True)
parser.add_argument('bar', type=int, required=True)

@api.route('/hello')
class HelloWorld(Resource):
    def get(self):
        return '111'

    def put(self):
        args = parser.parse_args()
        print(args)
        return '222'

if __name__ == '__main__':
    app.run(debug=True)
```
```bash
# 设置bundle_errors=True的情况
C:\Users\sandu>curl http://127.0.0.1:5000/hello  -X PUT
{
    "errors": {
        "foo": "Missing required parameter in the JSON body or the post body or
the query string",
        "bar": "Missing required parameter in the JSON body or the post body or
the query string"
    },
    "message": "Input payload validation failed"
}

# 未设置bundle_errors=True的情况
C:\Users\sandu>curl http://127.0.0.1:5000/hello  -X PUT
{
    "errors": {
        "foo": "Missing required parameter in the JSON body or the post body or
the query string"
    },
    "message": "Input payload validation failed"
}
```

应用级别的配置key为“BUNDLE_ERRORS”。例如：
```python
from flask import Flask

app = Flask(__name__)
app.config['BUNDLE_ERRORS'] = True
```
> BUNDLE_ERRORS是一个全局设置，它将覆盖每个RequestParser实例中的bundle_errors选项值

## 4.11 错误消息
每个字段的错误消息都可以通过在Argument（也包括RequestParser.add_argument）中使用help参数来自定义。

如果没有提供help参数，那么该字段的错误消息将会是类型错误本身的字符串表示。如果提供了help参数，那么错误消息将会是help参数的值。

help可能包含一个插入的符号{error_msg}，它将会替换成类型错误的字符串表示。这种方式能够实现自定义错误消息，同时保留原始的错误消息。如下所示：

```python
from flask_restplus import reqparse

parser = reqparse.RequestParser()
parser.add_argument(
    'foo',
    choices=('one', 'two'),
    help='Bad choice: {error_msg}'
)

# 如果请求中的'foo'参数值为'three'，那么错误信息将会如下所示：
{
    "message":  {
        "foo": "Bad choice: three is not a valid choice",
    }
}
```
实际代码：
```python
from flask import Flask
from flask_restplus import Resource, Api, reqparse

app = Flask(__name__)
api = Api(app)

# choices参数表示变量的值是从这中间的值
parser = reqparse.RequestParser()
parser.add_argument('foo', choices=('one', 'two'), help='Bad choice: {error_msg}',required=True)

@api.route('/hello')
class HelloWorld(Resource):
    def get(self):
        return '111'

    def put(self):
        args = parser.parse_args()
        print(args)
        return '222'

if __name__ == '__main__':
    app.run(debug=True)
```
```bash
# 生成的错误信息跟官方提供的有点不一样，具体如下：
C:\Users\sandu>curl http://127.0.0.1:5000/hello -d "foo=three" -X PUT
{
    "errors": {
        "foo": "Bad choice: {error_msg} The value 'three' is not a valid choice
for 'foo'."
    },
    "message": "Input payload validation failed"
}
```

# 6.错误处理
## 6.1  http异常处理 
Werkzeug httpException将自动正确序列化，并重用description属性。 
```python
from werkzeug.exceptions import BadRequest
raise BadRequest()
```
返回如下的400错误代码和信息：
```bash
{
    "message": "The browser (or proxy) sent a request that this server could not understand."
}
```
若是设置的有自定义的错误信息，比如这样的：
```python
from werkzeug.exceptions import BadRequest
raise BadRequest('My custom message')
```
错误显示信息将会是这样的：
```bash
{
    "message": "My custom message"
}
```
还可以 通过向异常提供数据属性，可以将附加属性附加到输出。 
```python
from werkzeug.exceptions import BadRequest
e = BadRequest('My custom message')
e.data = {'custom': 'value'}
raise e
```
错误显示信息将会是这样的：
```bash
{
    "message": "My custom message",
    "custom": "value"
}
```

## 6.2 Flask错误助手
abort帮助程序将错误正确包装到httpexception中，以便具有相同的行为。 
```python
from flask import abort
abort(400)
```
返回如下的400错误代码和信息：
```bash
{
    "message": "The browser (or proxy) sent a request that this server could not understand."
}
```
如果在abort中指定错误代码和错误信息，比如：
```python
from flask import abort
abort(400, 'My custom message')
```
错误显示信息将会是这样的：
```bash
{
    "message": "My custom message"
}
```

## 6.3 Flask-RESTPlus错误助手
errors.abort()和namespace.abort()的工作方式与原始flask.abort()类似，但它还将向响应添加关键字参数。 
```python
from flask_restplus import abort
abort(400, custom='value')
```
返回如下的400错误代码和信息：
```bash
{
    "message": "The browser (or proxy) sent a request that this server could not understand.",
    "custom": "value"
}
```
如果在abort中指定错误代码和错误信息，比如：
```python
from flask import abort
abort(400, 'My custom message', custom='value')
```
错误显示信息将会是这样的：
```bash
{
    "message": "My custom message",
    "custom": "value"
}
```

## 6.4 @api.errorhandler装饰器
@api.errorhandler 装饰器允许您以与flask/blueprint@errorhandler decorator相同的方式为给定的异常（或从中继承的任何异常）注册特定的处理程序。
```python
@api.errorhandler(RootException)
def handle_root_exception(error):
    '''Return a custom message and 400 status code'''
    return {'message': 'What you want'}, 400


@api.errorhandler(CustomException)
def handle_custom_exception(error):
    '''Return a custom message and 400 status code'''
    return {'message': 'What you want'}, 400


@api.errorhandler(AnotherException)
def handle_another_exception(error):
    '''Return a custom message and 500 status code'''
    return {'message': error.specific}


@api.errorhandler(FakeException)
def handle_fake_exception_with_header(error):
    '''Return a custom message and 400 status code'''
    return {'message': error.message}, 400, {'My-Header': 'Value'}


@api.errorhandler(NoResultFound)
def handle_no_result_exception(error):
    '''Return a custom not found error message and 404 status code'''
    return {'message': error.specific}, 404
```
>  OpenAPI 2.0规范要求“noresultfound”错误（带说明）。错误句柄函数中的docstring将作为说明输出到swagger.json中。 

或者使用如下的这种方式：
```python
@api.errorhandler(FakeException)
@api.marshal_with(error_fields, code=400)
@api.header('My-Header',  'Some description')
def handle_fake_exception_with_header(error):
    '''This is a custom error'''
    return {'message': error.message}, 400, {'My-Header': 'Value'}


@api.route('/test/')
class TestResource(Resource):
    def get(self):
        '''
        Do something

        :raises CustomException: In case of something
        '''
        pass
```
在这个例子中，函数文档中的:raise:的信息将会自动提取出来，并且响应400将正确记录

它还允许在不使用参数的情况下重写默认错误处理程序
```python
@api.errorhandler
def default_error_handler(error):
    '''Default error handler'''
    return {'message': str(error)}, getattr(error, 'code', 500)
```
> 默认情况下，flask restplus将在错误响应中返回一条消息。如果需要自定义响应作为错误，而不需要消息字段，则可以通过在应用程序配置中将error_include_message设置为false来禁用该响应。 

也可以在命名空间上注册错误处理程序。在命名空间上注册的错误处理程序将重写在API上注册的错误处理程序。
```python
ns = Namespace('cats', description='Cats related operations')

@ns.errorhandler
def specific_namespace_error_handler(error):
    '''Namespace error handler'''
    return {'message': str(error)}, getattr(error, 'code', 500)
```

# 7.字段掩码
flask restplus支持部分对象获取（aka.字段屏蔽）通过在请求中提供自定义头。
默认情况下，请求头是X-Fields字段，但可以使用restplus_mask_header参数进行更改。

## 7.1 语法
只需提供一个由逗号分隔的字段名列表，可以选择用括号括起来。
```python
# 以下两种写法作用相等
mask = '{name,age}'
# 或者
mask = 'name,age'
data = requests.get('/some/url/', headers={'X-Fields': mask})
assert len(data) == 2
assert 'name' in data
assert 'age' in data
```
要指定嵌套字段掩码，只需在字段名后面的括号中提供它： 
```python
mask = '{name, age, pet{name}}'
```
嵌套规范适用于嵌套对象或对象列表：
```python
# Will apply the mask {name} to each pet in the pets list.
mask = '{name, age, pets{name}}'
```
有一个特殊的星形标记，意思是“所有剩余字段”。它只允许指定嵌套筛选：
```python
# Will apply the mask {name} to each pet in the pets list and take all other root fields without filtering.
mask = '{pets{name},*}'

# Will not filter anything
mask = '*'
```

## 7.2 用法
默认情况下，每次使用api.marshal或@api.marshal_with时，如果存在头，则会自动应用掩码。
每次将@api.marshal_与decorator一起使用时，头都将作为一个swager参数公开。
因为一旦全局头可以使您的Swagger规范更加冗长，它就不允许公开它。您可以通过将restplus_mask_swagger设置为false来禁用此行为。
还可以指定一个默认掩码，如果找不到头掩码，则将应用该默认掩码。 
```python
class MyResource(Resource):
    @api.marshal_with(my_model, mask='name,age')
    def get(self):
        pass
```
默认掩码也可以在模型级别处理：
```python
model = api.model('Person', {
    'name': fields.String,
    'age': fields.Integer,
    'boolean': fields.Boolean,
}, mask='{name,age}')
```
要覆盖默认掩码，您需要提供另一个掩码或将*作为掩码传递。

# 8. Swagger文档
Swagger API文档是自动生成的，可以从API的根URL获得。您可以使用@api.doc()装饰器配置文档。

## 8.1 @api.doc()装饰器文档
@api.doc()装饰器允许您在文档中包含其他信息。 
可以在class类中或者method中
```python
@api.route('/my-resource/<id>', endpoint='my-resource')
@api.doc(params={'id': 'An ID'})
class MyResource(Resource):
    def get(self, id):
        return {}

    @api.doc(responses={403: 'Not Authorized'})
    def post(self, id):
        api.abort(403)
```

## 8.2  自动文件模型 
使用model（）、clone（）和inherit（）实例化的所有模型都将自动记录在您的swager规范中。 
inherit()方法将在swager模型定义中同时注册父级和子级： 
```python
parent = api.model('Parent', {
    'name': fields.String,
    'class': fields.String(discriminator=True)
})

child = api.inherit('Child', parent, {
    'extra': fields.String
})
```
 上述配置将产生以下Swagger 定义：
```python
"Parent": {
    "properties": {
        "name": {"type": "string"},
        "class": {"type": "string"}
    },
    "discriminator": "class",
    "required": ["class"]
},
"Child": {
    "allOf": [{
            "$ref": "#/definitions/Parent"
        }, {
            "properties": {
                "extra": {"type": "string"}
            }
        }
    ]
}
```

## 8.3@api.marshal_with()装饰器
此装饰器的工作方式与原始marshal_with（）装饰器类似，不同之处在于它记录了这些方法。可选参数代码允许您指定预期的HTTP状态代码（默认为200）。可选参数as_list允许您指定对象是否作为列表返回。
```python
resource_fields = api.model('Resource', {
    'name': fields.String,
})

@api.route('/my-resource/<id>', endpoint='my-resource')
class MyResource(Resource):
    @api.marshal_with(resource_fields, as_list=True)
    def get(self):
        return get_objects()

    @api.marshal_with(resource_fields, code=201)
    def post(self):
        return create_object(), 201
```
Api.marshal_list_with()装饰器严格相等于Api.marshal_with(fields, as_list=True)()。
```python
resource_fields = api.model('Resource', {
    'name': fields.String,
})

@api.route('/my-resource/<id>', endpoint='my-resource')
class MyResource(Resource):
    @api.marshal_list_with(resource_fields)
    def get(self):
        return get_objects()

    @api.marshal_with(resource_fields)
    def post(self):
        return create_object()
```
## 8.4 @api.expect()装饰器
@api.expect（）装饰器允许您指定预期的输入字段。它接受一个可选的布尔参数validate，指示是否应验证有效负载。通过将restplus_validate配置设置为true或将validate=true传递给API构造函数，可以全局自定义验证行为。
如下两个例子的作用是相等的：
1. 使用@api.expect()装饰器
```python
resource_fields = api.model('Resource', {
    'name': fields.String,
})

@api.route('/my-resource/<id>')
class MyResource(Resource):
    @api.expect(resource_fields)
    def get(self):
        pass
```
2. 使用api.doc()装饰器
```python
resource_fields = api.model('Resource', {
    'name': fields.String,
})

@api.route('/my-resource/<id>')
class MyResource(Resource):
    @api.doc(body=resource_fields)
    def get(self):
        pass
```
可以将列表指定为预期输入：
```python
resource_fields = api.model('Resource', {
    'name': fields.String,
})

@api.route('/my-resource/<id>')
class MyResource(Resource):
    @api.expect([resource_fields])
    def get(self):
        pass
```
可以使用RequestParser定义预期的输入： 
```python
parser = api.parser()
parser.add_argument('param', type=int, help='Some param', location='form')
parser.add_argument('in_files', type=FileStorage, location='files')

@api.route('/with-parser/', endpoint='with-parser')
class WithParserResource(restplus.Resource):
    @api.expect(parser)
    def get(self):
        return {}
```
可以在特定终结点上启用或禁用验证： 
```python
resource_fields = api.model('Resource', {
    'name': fields.String,
})

@api.route('/my-resource/<id>')
class MyResource(Resource):
    # Payload validation disabled
    @api.expect(resource_fields)
    def post(self):
        pass

    # Payload validation enabled
    @api.expect(resource_fields, validate=True)
    def post(self):
        pass
```
通过配置进行的应用程序范围验证示例： 
```python
app.config['RESTPLUS_VALIDATE'] = True

api = Api(app)

resource_fields = api.model('Resource', {
    'name': fields.String,
})

@api.route('/my-resource/<id>')
class MyResource(Resource):
    # Payload validation enabled
    @api.expect(resource_fields)
    def post(self):
        pass

    # Payload validation disabled
    @api.expect(resource_fields, validate=False)
    def post(self):
        pass
```
构造函数在应用程序范围内验证的示例： 
```python
api = Api(app, validate=True)

resource_fields = api.model('Resource', {
    'name': fields.String,
})

@api.route('/my-resource/<id>')
class MyResource(Resource):
    # Payload validation enabled
    @api.expect(resource_fields)
    def post(self):
        pass

    # Payload validation disabled
    @api.expect(resource_fields, validate=False)
    def post(self):
        pass
```

## 8.5 @api.response()装饰器文档
@api.response()装饰器允许您记录已知的响应，它是@api.doc(responses=''的快捷方式)
如下两个示例是相等的：
```python
@api.route('/my-resource/')
class MyResource(Resource):
    @api.response(200, 'Success')
    @api.response(400, 'Validation Error')
    def get(self):
        pass


@api.route('/my-resource/')
class MyResource(Resource):
    @api.doc(responses={
        200: 'Success',
        400: 'Validation Error'
    })
    def get(self):
        pass
```
您可以选择指定响应模型作为第三个参数： 
```python
model = api.model('Model', {
    'name': fields.String,
})

@api.route('/my-resource/')
class MyResource(Resource):
    @api.response(200, 'Success', model)
    def get(self):
        pass
```
@api.marshal_with()装饰器自动记录响应：
```python
model = api.model('Model', {
    'name': fields.String,
})

@api.route('/my-resource/')
class MyResource(Resource):
    @api.response(400, 'Validation error')
    @api.marshal_with(model, code=201, description='Object created')
    def post(self):
        pass
```
您可以指定在不知道响应代码的情况下发送的默认响应： 
```python
@api.route('/my-resource/')
class MyResource(Resource):
    @api.response('default', 'Error')
    def get(self):
        pass
```

## 8.6 @api.route()装饰器
您可以使用api.route()的doc参数提供类范围的文档。此参数接受与api.doc()装饰器相同的值。
以下两种装饰器例子作用相同：
1. 使用@api.doc()
```python
@api.route('/my-resource/<id>', endpoint='my-resource')
@api.doc(params={'id': 'An ID'})
class MyResource(Resource):
    def get(self, id):
        return {}
```
2. 使用@api.route()
```python
@api.route('/my-resource/<id>', endpoint='my-resource', doc={'params':{'id': 'An ID'}})
class MyResource(Resource):
    def get(self, id):
        return {}
```

## 8.7 fields参数

......未完待续......