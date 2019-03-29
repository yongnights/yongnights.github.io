---
title: 使用Python的camelot识别pdf文件中的表格数据
date: 2019-03-25 15:31:41
tags:
- Pyhton
- pdf
categories: 
- pdf
password: 
typora-root-url: ..\..\themes\next\source
---
Camelot 是 一个python库，它使任何人都可以轻松地从pdf文件中提取表个数据.
Note :  您也可以使用 Excalibur, 它是一个图形化界面的工具,依赖于Camelot ! 

### 官方文档地址
	官方文档地址: https://camelot-py.readthedocs.io/en/latest/
	GitHub地址: https://github.com/socialcopsdev/camelot
### 用法示例
如下是一个示例, 从PDF文件中解析出表格数据, [示例文件](https://camelot-py.readthedocs.io/en/latest/_static/pdf/foo.pdf).

```python
>>> import camelot
>>> tables = camelot.read_pdf('foo.pdf')
>>> tables
<TableList n=1>
>>> tables.export('foo.csv', f='csv', compress=True) # json, excel, html
>>> tables[0]
<Table shape=(7, 7)>
>>> tables[0].parsing_report
{
    'accuracy': 99.02,
    'whitespace': 12.24,
    'order': 1,
    'page': 1
}
>>> tables[0].to_csv('foo.csv') # to_json, to_excel, to_html
>>> tables[0].df # get a pandas DataFrame!
>>> tables[0].data # 以列表的形式获取表格数据
```
```
[
    ['', '2017 年', '2016 年', '', '本年比上年\n增减', '2015 年', ''],
    ['', '', '调整前', '调整后', '调整后', '调整前', '调整后'],
    ['营业收入', '1,193,226,06\n2.36', '906,122,990.\n80', '1,071,240,37\n1.27', '11.39%', '982,793,002.\n23',
     '1,145,518,27\n0.78'],
    ['归属于上市公司股东的净\n利润', '70,933,068.0\n9', '32,767,864.6\n5', '47,832,706.4\n2', '48.29%', '18,617,579.8\n2',
     '22,222,610.2\n9'],
    ['归属于上市公司股东的扣\n除非经常性损益的净利润', '42,889,116.5\n4', '20,805,256.6\n9', '22,714,450.2\n9', '88.82%', '2,936,489.29',
     '-1,318,104.2\n0'],
    ['经营活动产生的现金流量\n净额', '129,194,493.\n34', '1,033,605,92\n6.50', '417,168,711.\n36', '-69.03%', '336,741,518.\n42',
     '336,741,518.\n42'],
    ['基本每股收益（元/股）', '0.27', '0.13', '0.23', '17.39%', '0.07', '0.14'],
    ['稀释每股收益（元/股）', '0.27', '0.13', '0.23', '17.39%', '0.07', '0.14'],
    ['加权平均净资产收益率', '2.83%', '2.16%', '3.62%', '-0.79%', '1.83%', '1.98%'],
    ['', '2017 年末', '2016 年末', '', '本年末比上\n年末增减', '2015 年末', ''],
    ['', '', '调整前', '调整后', '调整后', '调整前', '调整后'],
    ['资产总额', '4,584,871,87\n8.81', '4,424,575,99\n3.01', '4,615,713,51\n4.63', '-0.67%', '3,215,996,96\n2.67',
     '3,533,474,80\n2.10'],
    ['归属于上市公司股东的净\n资产', '2,532,952,52\n3.50', '2,484,273,56\n7.08', '2,467,102,37\n1.21', '2.67%',
     '1,026,408,12\n9.95', '1,110,355,83\n3.68']
]
```

![1](/camleot/1.png)

<escape><!-- more --></escape>

### 安装
以Windows系统为例,其他系统的安装可以参考官方文档地址
#### 1. 安装依赖
	根据系统版本的不同以及使用的Python版本,下载相应的依赖包并安装
	Tkinter下载地址: https://www.activestate.com/products/activetcl/downloads/
	ghostscript下载地址: https://www.ghostscript.com/download.html
#### 2. 校验依赖包
```python
打开python命令行窗口,输入下方代码,若无报错,则tkinter依赖包安装成功
>>> import tkinter
打开cmd命令行窗口,输入下方代码,若无报错,正常显示出ghostscript的版本信息,则ghostscript依赖包安装成功
C:\> gswin64c.exe -version
注意:若提示找不到命令,可把该软件的执行文件所在路径添加到环境变量中
```
#### 3.安装Camelot
camelot支持以下Python版本:  2.7, 3.5 and 3.6
1. 使用Anaconda进行安装
```python
$ conda install -c conda-forge camelot-py
```
2. 使用pip进行安装
```python
$ pip install camelot-py[cv]
```
3. 源码安装
```python
$ git clone https://www.github.com/socialcopsdev/camelot
$ cd camelot
$ pip install ".[cv]"
```

### 使用
#### 1. 导入模块
```python
>>> import camelot
```
#### 2. 读取PDF文件
```python
>>> tables = camelot.read_pdf('foo.pdf')
>>> tables
<TableList n=1>
```
解析表格数据有两种方式,Lattice和stream,默认是Lattice方式,用flavor='stream'可以修改解析方式.
```python
>>> tables = camelot.read_pdf('foo.pdf',flavor='stream')
>>> tables
<TableList n=1>
```
默认读取第一页的表格.若是有表格,会把该页的表格数据存储到TableList对象中,然后可以使用索引的方式逐个获取表格数据.索引从0开始.
#### 3. 查看表格样式
```python
>>> tables[0]
<Table shape=(7, 7)>
```
#### 4. 查看表格信息
```python
>>> print tables[0].parsing_report
{
    'accuracy': 99.02,
    'whitespace': 12.24,
    'order': 1,
    'page': 1
}
```
#### 5. 以DataFrame形式获取表格数据
```python
>>> tables[0].df
```
![2](/images/2.png)

#### 6. 导出表格数据
```python
>>> tables[0].to_csv('foo.csv') # to_json(), to_excel() to_html() or to_sqlite()
或
>>> tables.export('foo.csv', f='csv')
```
#### 7. 分页数据
```python
>>> camelot.read_pdf('your.pdf', pages='1,2,3') # pages=1,4-10,20-30 or pages=1,4-10,20-end
```
#### 8. 读取有密码的文件
```python
>>> tables = camelot.read_pdf('foo.pdf', password='userpass')
```
#### 9. 读取有背景颜色的文件
```python
>>> tables = camelot.read_pdf('background_lines.pdf', process_background=True)
```
#### 10. 获取表格样式
先安装依赖: $ pip install camelot-py[plot]
样式总共有以下几种: 
    ‘text’
    ‘grid’
    ‘contour’
    ‘line’
    ‘joint’
    ‘textedge’
其中:     ‘line’和 ‘joint’ 仅适用于Lattice, ‘textedge’仅适用于Stream.
```python
>>> camelot.plot(tables[0], kind='text')
>>> plt.show()
```
#### 11.  Specify table areas
```python
>>> tables = camelot.read_pdf('table_areas.pdf', flavor='stream', table_areas=['316,499,566,337'])
```
#### 12. Specify table regions
```python
>>> tables = camelot.read_pdf('table_regions.pdf', table_regions=['170,370,560,270'])
```
#### 13. Split text along separators
```python
>>> tables = camelot.read_pdf('column_separators.pdf', flavor='stream', columns=['72,95,209,327,442,529,566,606,683'], split_text=True)
```
#### 14. Strip characters from text
```python
>>> tables = camelot.read_pdf('12s0324.pdf', flavor='stream', strip_text=' .\n')
```
#### 15. 其他功能
详细请参考官方文档

### API Reference
#### 1. Main Interface
```
camelot.read_pdf(filepath, pages='1', password=None, flavor='lattice', suppress_stdout=False, layout_kwargs={}, **kwargs)

Read PDF and return extracted tables.

Note: kwargs annotated with ^ can only be used with flavor=’stream’ and kwargs annotated with * can only be used with flavor=’lattice’.

Parameters:	
    filepath (str) – Filepath or URL of the PDF file.
    pages (str, optional (default: '1')) – Comma-separated page numbers. Example: ‘1,3,4’ or ‘1,4-end’ or ‘all’.
    password (str, optional (default: None)) – Password for decryption.
    flavor (str (default: 'lattice')) – The parsing method to use (‘lattice’ or ‘stream’). Lattice is used by default.
    suppress_stdout (bool, optional (default: True)) – Print all logs and warnings.
    layout_kwargs (dict, optional (default: {})) – A dict of pdfminer.layout.LAParams kwargs.
    table_areas (list, optional (default: None)) – List of table area strings of the form x1,y1,x2,y2 where (x1, y1) -> left-top and (x2, y2) -> right-bottom in PDF coordinate space.
    columns^ (list, optional (default: None)) – List of column x-coordinates strings where the coordinates are comma-separated.
    split_text (bool, optional (default: False)) – Split text that spans across multiple cells.
    flag_size (bool, optional (default: False)) – Flag text based on font size. Useful to detect super/subscripts. Adds <s></s> around flagged text.
    strip_text (str, optional (default: '')) – Characters that should be stripped from a string before assigning it to a cell.
    row_tol^ (int, optional (default: 2)) – Tolerance parameter used to combine text vertically, to generate rows.
    column_tol^ (int, optional (default: 0)) – Tolerance parameter used to combine text horizontally, to generate columns.
    process_background* (bool, optional (default: False)) – Process background lines.
    line_scale* (int, optional (default: 15)) – Line size scaling factor. The larger the value the smaller the detected lines. Making it very large will lead to text being detected as lines.
    copy_text* (list, optional (default: None)) – {‘h’, ‘v’} Direction in which text in a spanning cell will be copied over.
    shift_text* (list, optional (default: ['l', 't'])) – {‘l’, ‘r’, ‘t’, ‘b’} Direction in which text in a spanning cell will flow.
    line_tol* (int, optional (default: 2)) – Tolerance parameter used to merge close vertical and horizontal lines.
    joint_tol* (int, optional (default: 2)) – Tolerance parameter used to decide whether the detected lines and points lie close to each other.
    threshold_blocksize* (int, optional (default: 15)) –

    Size of a pixel neighborhood that is used to calculate a threshold value for the pixel: 3, 5, 7, and so on.
    
    For more information, refer OpenCV’s adaptiveThreshold.
    threshold_constant* (int, optional (default: -2)) –
    
    Constant subtracted from the mean or weighted mean. Normally, it is positive but may be zero or negative as well.
    
    For more information, refer OpenCV’s adaptiveThreshold.
    iterations* (int, optional (default: 0)) –
    
    Number of times for erosion/dilation is applied.
    
    For more information, refer OpenCV’s dilate.
    resolution* (int, optional (default: 300)) – Resolution used for PDF to PNG conversion.
Returns: tables
Return type: camelot.core.TableList
```
#### 2. Lower-Level Classes
```
class camelot.handlers.PDFHandler(filepath, pages='1', password=None)
    Handles all operations like temp directory creation, splitting file into single page PDFs, parsing each PDF and then removing the temp directory.
    Parameters:	
        filepath (str) – Filepath or URL of the PDF file.
        pages (str, optional (default: '1')) – Comma-separated page numbers. Example: ‘1,3,4’ or ‘1,4-end’ or ‘all’.
        password (str, optional (default: None)) – Password for decryption.
    parse(flavor='lattice', suppress_stdout=False, layout_kwargs={}, **kwargs)
        Extracts tables by calling parser.get_tables on all single page PDFs.
        Parameters:	
            flavor (str (default: 'lattice')) – The parsing method to use (‘lattice’ or ‘stream’). Lattice is used by default.
            suppress_stdout (str (default: False)) – Suppress logs and warnings.
            layout_kwargs (dict, optional (default: {})) – A dict of pdfminer.layout.LAParams kwargs.
            kwargs (dict) – See camelot.read_pdf kwargs.
        Returns:tables – List of tables found in PDF.
        Return type: camelot.core.TableList
```
```
class camelot.parsers.Stream(table_regions=None, table_areas=None, columns=None, split_text=False, flag_size=False, strip_text='', edge_tol=50, row_tol=2, column_tol=0, **kwargs)
    Stream method of parsing looks for spaces between text to parse the table.
    If you want to specify columns when specifying multiple table areas, make sure that the length of both lists are equal.
    Parameters:	
        table_regions (list, optional (default: None)) – List of page regions that may contain tables of the form x1,y1,x2,y2 where (x1, y1) -> left-top and (x2, y2) -> right-bottom in PDF coordinate space.
        table_areas (list, optional (default: None)) – List of table area strings of the form x1,y1,x2,y2 where (x1, y1) -> left-top and (x2, y2) -> right-bottom in PDF coordinate space.
        columns (list, optional (default: None)) – List of column x-coordinates strings where the coordinates are comma-separated.
        split_text (bool, optional (default: False)) – Split text that spans across multiple cells.
        flag_size (bool, optional (default: False)) – Flag text based on font size. Useful to detect super/subscripts. Adds <s></s> around flagged text.
        strip_text (str, optional (default: '')) – Characters that should be stripped from a string before assigning it to a cell.
        edge_tol (int, optional (default: 50)) – Tolerance parameter for extending textedges vertically.
        row_tol (int, optional (default: 2)) – Tolerance parameter used to combine text vertically, to generate rows.
        column_tol (int, optional (default: 0)) – Tolerance parameter used to combine text horizontally, to generate columns.
```
```
class camelot.parsers.Lattice(table_regions=None, table_areas=None, process_background=False, line_scale=15, copy_text=None, shift_text=['l', 't'], split_text=False, flag_size=False, strip_text='', line_tol=2, joint_tol=2, threshold_blocksize=15, threshold_constant=-2, iterations=0, resolution=300, **kwargs)
    Lattice method of parsing looks for lines between text to parse the table.
    Parameters:	
        table_regions (list, optional (default: None)) – List of page regions that may contain tables of the form x1,y1,x2,y2 where (x1, y1) -> left-top and (x2, y2) -> right-bottom in PDF coordinate space.
        table_areas (list, optional (default: None)) – List of table area strings of the form x1,y1,x2,y2 where (x1, y1) -> left-top and (x2, y2) -> right-bottom in PDF coordinate space.
        process_background (bool, optional (default: False)) – Process background lines.
        line_scale (int, optional (default: 15)) – Line size scaling factor. The larger the value the smaller the detected lines. Making it very large will lead to text being detected as lines.
        copy_text (list, optional (default: None)) – {‘h’, ‘v’} Direction in which text in a spanning cell will be copied over.
        shift_text (list, optional (default: ['l', 't'])) – {‘l’, ‘r’, ‘t’, ‘b’} Direction in which text in a spanning cell will flow.
        split_text (bool, optional (default: False)) – Split text that spans across multiple cells.
        flag_size (bool, optional (default: False)) – Flag text based on font size. Useful to detect super/subscripts. Adds <s></s> around flagged text.
        strip_text (str, optional (default: '')) – Characters that should be stripped from a string before assigning it to a cell.
        line_tol (int, optional (default: 2)) – Tolerance parameter used to merge close vertical and horizontal lines.
        joint_tol (int, optional (default: 2)) – Tolerance parameter used to decide whether the detected lines and points lie close to each other.
        threshold_blocksize (int, optional (default: 15)) – Size of a pixel neighborhood that is used to calculate a threshold value for the pixel: 3, 5, 7, and so on.

        For more information, refer OpenCV’s adaptiveThreshold.
        threshold_constant (int, optional (default: -2)) –

        Constant subtracted from the mean or weighted mean. Normally, it is positive but may be zero or negative as well.

        For more information, refer OpenCV’s adaptiveThreshold.
        iterations (int, optional (default: 0)) –

        Number of times for erosion/dilation is applied.

        For more information, refer OpenCV’s dilate.
        resolution (int, optional (default: 300)) – Resolution used for PDF to PNG conversion.

```
#### 3. Lower-Lower-Level Classes
```
class camelot.core.TableList(tables)[source]
    Defines a list of camelot.core.Table objects. Each table can be accessed using its index.
    n
        int – Number of tables in the list.
    export(path, f='csv', compress=False)[source]
        Exports the list of tables to specified file format.
        Parameters:	
            path (str) – Output filepath.
            f (str) – File format. Can be csv, json, excel, html and sqlite.
            compress (bool) – Whether or not to add files to a ZIP archive.

class camelot.core.Table(cols, rows)[source]
    Defines a table with coordinates relative to a left-bottom origin. (PDF coordinate space)
    Parameters:	
        cols (list) – List of tuples representing column x-coordinates in increasing order.
        rows (list) – List of tuples representing row y-coordinates in decreasing order.
    df
       pandas.DataFrame
    shape
        tuple – Shape of the table.
    accuracy
        float – Accuracy with which text was assigned to the cell.
    whitespace
        float – Percentage of whitespace in the table.
    order
        int – Table number on PDF page.
    page
        int – PDF page number.
    data
        Returns two-dimensional list of strings in table.
    parsing_report
        Returns a parsing report with %accuracy, %whitespace, table number on page and page number.
    set_all_edges()[source]
        Sets all table edges to True.
    set_border()[source]
        Sets table border edges to True.
    set_edges(vertical, horizontal, joint_tol=2)[source]
        Sets a cell’s edges to True depending on whether the cell’s coordinates overlap with the line’s coordinates within a tolerance.
        Parameters:	
            vertical (list) – List of detected vertical lines.
            horizontal (list) – List of detected horizontal lines.
    set_span()[source]
        Sets a cell’s hspan or vspan attribute to True depending on whether the cell spans horizontally or vertically.
    to_csv(path, **kwargs)[source]
        Writes Table to a comma-separated values (csv) file.
        For kwargs, check pandas.DataFrame.to_csv().
        Parameters:	path (str) – Output filepath.
    to_excel(path, **kwargs)[source]
        Writes Table to an Excel file.
        For kwargs, check pandas.DataFrame.to_excel().
        Parameters:	path (str) – Output filepath.
    to_html(path, **kwargs)[source]
        Writes Table to an HTML file.
        For kwargs, check pandas.DataFrame.to_html().
        Parameters:	path (str) – Output filepath.
    to_json(path, **kwargs)[source]
        Writes Table to a JSON file.
        For kwargs, check pandas.DataFrame.to_json().
        Parameters:	path (str) – Output filepath.
    to_sqlite(path, **kwargs)[source]
        Writes Table to sqlite database.
        For kwargs, check pandas.DataFrame.to_sql().
        Parameters:	path (str) – Output filepath.
        
class camelot.core.Cell(x1, y1, x2, y2)[source]
    Defines a cell in a table with coordinates relative to a left-bottom origin. (PDF coordinate space)
    Parameters:	
        x1 (float) – x-coordinate of left-bottom point.
        y1 (float) – y-coordinate of left-bottom point.
        x2 (float) – x-coordinate of right-top point.
        y2 (float) – y-coordinate of right-top point.
    lb
        tuple – Tuple representing left-bottom coordinates.
    lt
        tuple – Tuple representing left-top coordinates.
    rb
        tuple – Tuple representing right-bottom coordinates.
    rt
        tuple – Tuple representing right-top coordinates.
    left
        bool – Whether or not cell is bounded on the left.
    right
        bool – Whether or not cell is bounded on the right.
    top
        bool – Whether or not cell is bounded on the top.
    bottom
        bool – Whether or not cell is bounded on the bottom.
    hspan
        bool – Whether or not cell spans horizontally.
    vspan
        bool – Whether or not cell spans vertically.
    text
        string – Text assigned to cell.


```