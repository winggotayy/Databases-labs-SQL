#!/usr/bin/python3
import pymysql

db = pymysql.connect(host='localhost', user='root', passwd='1234', database='OrderDB')
cursor = db.cursor()

sql = """
    SELECT C.customerName, C.address, C.telephone
    FROM Customer C
    """
cursor.execute(sql)
result = cursor.fetchall()
for row in result:
    print(row)
 
db.close()


