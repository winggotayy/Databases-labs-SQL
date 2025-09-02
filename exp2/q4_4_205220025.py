#!/usr/bin/python3
import pymysql
# 打开数据库连接
db = pymysql.connect(host='localhost', 
    user='root',
    passwd='1234',
    database='OrderDB')
# 使用cursor()方法获取操作游标
cursor = db.cursor()
# SQL更新语句
sql = """
    UPDATE Product 
    SET productPrice = productPrice * 0.5 
    WHERE productPrice > 1000;
    """
# 执行SQL语句
cursor.execute(sql)
# 提交到数据库执行
db.commit()
# SQL查询语句
sql = """
    SELECT *
    FROM Product
    """
# 执行SQL语句
cursor.execute(sql)
# 获取所有记录列表
result = cursor.fetchall()
# 打印结果
for row in result:
    print(row)
# 关闭数据库连接
db.close()

