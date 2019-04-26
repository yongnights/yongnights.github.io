---
title: 在pandas.DataFrame.to_sql时指定数据库表的列类型
date: {{date}}
tags: 
- pandas
- Python
categories: 
- Python
password: 
---

该文章转载自以下链接：https://www.jianshu.com/p/4c5e1ebe8470?utm_source=oschina-app

# 问题
在数据分析并存储到数据库时，Python的Pandas包提供了to_sql 方法使存储的过程更为便捷，但如果在使用to_sql方法前不在数据库建好相对应的表，to_sql则会默认为你创建一个新表，这时新表的列类型可能并不是你期望的。例如我们通过下段代码往数据库中插入一部分数据：
```python
import pandas as pd
from datetime import datetime

df = pd.DataFrame([['a', 1, 1, 2.0, datetime.now(), True]], 
                  columns=['str', 'int', 'float', 'datetime', 'boolean'])
print(df.dtypes)
```

<escape><!-- more --></escape>

通过dtypes可知数据类型为object, int64, float64, datetime64[ns], bool 如果把数据通过to_sql方法插入到数据库中：
```python
from sqlalchemy import create_engine
engine = create_engine("mysql+mysqldb://{}:{}@{}/{}".format('username', 'password', 'host:port', 'database'))
con = engine.connect()

df.to_sql(name='test', con=con, if_exists='append', index=False)
```

用MySQL的desc可以发现数据库自动创建了表并默认指定了列的格式：
```bash
# 在MySQL中查看表的列类型
desc test;
```

| Filed    | Type       | Null | Key  | Default | Extra |
| -------- | ---------- | ---- | ---- | ------- | ----- |
| str      | text       | YES  |      | NULL    |       |
| int      | bigint(20) | YES  |      | NULL    |       |
| float    | double     | YES  |      | NULL    |       |
| datetime | datetime   | YES  |      | NULL    |       |
| boolean  | tinyint(1) | YES  |      | NULL    |       |

其中str类型的数据在数据库表中被映射成text，int类型被映射成bigint(20)， float类型被映射成double类型。数据库中的列类型可能并非是我们所期望的格式，但我们又不想在数据插入前手动的创建数据库的表，而更希望根据DataFrame中数据的格式动态地改变数据库中表格式。

# 分析
通过查阅pandas.DataFrame.to_sql的api文档[^footnote]，可以通过指定dtype 参数值来改变数据库中创建表的列类型。
> dtype : dict of column name to SQL type, default None
Optional specifying the datatype for columns. The SQL type should be a SQLAlchemy type, or a string for sqlite3 fallback connection.

根据描述，可以在执行to_sql方法时，将映射好列名和指定类型的dict赋值给dtype参数即可上，其中对于MySQL表的列类型可以使用SQLAlchemy包中封装好的类型。
```bash
# 执行前先在MySQL中删除表
drop table test;
```
```python
from sqlalchemy.types import NVARCHAR, Float, Integer

dtypedict = {
  'str': NVARCHAR(length=255),
  'int': Integer(),
  'float' Float()
}

df.to_sql(name='test', con=con, if_exists='append', index=False, dtype=dtypedict)
```

更新代码后，再查看数据库，可以看到数据库在建表时会根据dtypedict中的列名来指定相应的类型。

```bash
# 在MySQL中查看表的列类型
desc test;
```

| Filed    | Type       | Null | Key  | Default | Extra |
| -------- | ---------- | ---- | ---- | ------- | ----- |
| str      | varchar(255)  | YES  | | NULL    |       |
| int      | int(11) | YES  |      | NULL    |       |
| float    | float     | YES  |      | NULL    |       |
| datetime | datetime   | YES  |      | NULL    |       |
| boolean  | tinyint(1) | YES  |      | NULL    |       |

# 答案
通过分析，我们已经知道在执行to_sql的方法时，可以通过创建一个类似“{"column_name"：sqlalchemy_type}”的映射结构来控制数据库中表的列类型。但在实际使用时，我们更希望能通过pandas.DataFrame中的column的数据类型来映射数据库中的列类型，而不是每此都要列出pandas.DataFrame的column名字。
写一个简单的def将pandas.DataFrame中列名和预指定的类型映射起来即可：

```python
def mapping_df_types(df):
    dtypedict = {}
    for i, j in zip(df.columns, df.dtypes):
        if "object" in str(j):
            dtypedict.update({i: NVARCHAR(length=255)})
        if "float" in str(j):
            dtypedict.update({i: Float(precision=2, asdecimal=True)})
        if "int" in str(j):
            dtypedict.update({i: Integer()})
    return dtypedict
```

只要在执行to_sql前使用此方法获得一个映射dict再赋值给to_sql的dtype参数即可，执行的结果与上一节相同，不再累述。
```python
df = pd.DataFrame([['a', 1, 1, 2.0, datetime.now(), True]], 
                  columns=['str', 'int', 'float', 'datetime', 'boolean'])
dtypedict = mapping_df_types(df)
df.to_sql(name='test', con=con, if_exists='append', index=False, dtype=dtypedict)
```

# 参考
1. [^footnote][pandas官方文档](https://link.jianshu.com/?t=https%3A%2F%2Fpandas.pydata.org%2Fpandas-docs%2Fstable%2Findex.html) 


