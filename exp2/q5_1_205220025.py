#!/usr/bin/python3
import pymysql

department = '业务科' # 外部输出参数

db = pymysql.connect(host='localhost', user='root', passwd='1234', database='OrderDB')
cursor = db.cursor()

# SQL更新语句
sql = """
    UPDATE Employee
    SET salary = salary + 200
    WHERE department = %s
    """
cursor.execute(sql)
result = cursor.fetchall()
for row in result:
    print(row)
 
db.close()


