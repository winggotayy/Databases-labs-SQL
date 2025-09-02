-- 姓名：郑凯琳
-- 学号：205220025
-- 提交前请确保本次实验独立完成，若有参考请注明并致谢。

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q1.1

DROP PROCEDURE IF EXISTS product_info;
delimiter // -- 修改结束符
CREATE PROCEDURE product_info(IN productName VARCHAR(40))
BEGIN
	SELECT OM.customerNo, C.customerName, OM.orderNo, OD.quantity, OD.quantity * OD.price AS totalPrice
    FROM ordermaster OM, orderdetail OD, customer C, product P
    WHERE 
		OM.orderNo = OD.orderNo AND OM.customerNo = C.customerNo AND OD.productNo = P.productNo
        AND P.productName = productName
	ORDER BY totalPrice DESC;
END //
delimiter ; -- 恢复默认结束符
CALL product_info('32M DRAM'); 

-- END Q1.1

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q1.2

DROP PROCEDURE IF EXISTS earlier_employee;
delimiter //
CREATE PROCEDURE earlier_employee(IN employeeNo CHAR(8))
BEGIN
    SELECT e1.employeeNo, e1.employeeName, e1.gender, e1.hireDate, e1.department
    FROM Employee e1
    JOIN Employee e2 
	ON 
		e1.department = e2.department  -- 同一部门
    WHERE 
        e2.employeeNo = employeeNo     -- 匹配输入员工编号 
        AND e1.hireDate < e2.hireDate; -- 雇佣日期更早
END //
delimiter ;
CALL earlier_employee("E2008005");

-- END Q1.2

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q2.1

DROP FUNCTION IF EXISTS product_avgprice;
delimiter // 
CREATE FUNCTION product_avgprice(productName VARCHAR(40))
RETURNS FLOAT	-- 返回类型
DETERMINISTIC	-- 说明函数是确定性的（相同输入总是返回相同输出）
BEGIN
	DECLARE avgprice FLOAT;	-- 声明变量
		SELECT AVG(OD.price) INTO avgprice
		FROM ordermaster OM, orderdetail OD, product P
		where OD.productNo = P.productNo AND OD.orderNo = OM.orderNo AND P.productName = productName
		GROUP BY P.productNo;
    RETURN avgprice;
END //
delimiter ;

SELECT productName, product_avgprice(productName) AS avgPrice
FROM product;

-- END Q2.1

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q2.2

DROP FUNCTION IF EXISTS product_totalsales;
delimiter // 
CREATE FUNCTION product_totalsales(productNo CHAR(9)) 
RETURNS INTEGER
DETERMINISTIC
BEGIN
	DECLARE totalsales INTEGER;
		SELECT SUM(OD.quantity) INTO totalsales
        FROM orderdetail OD
        WHERE OD.productNo = productNo;
	RETURN totalsales;
END //
delimiter ;

SELECT productNo, productName, product_totalsales(productNo)
FROM Product
WHERE product_totalsales(productNo) > 4;

-- END Q2.2

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q3.1

DROP TRIGGER IF EXISTS insert_product;
delimiter // 
CREATE TRIGGER insert_product
BEFORE INSERT ON product	-- 在向product表插入数据之前触发
FOR EACH ROW 				-- 表示对于每个插入的新行都执行触发器逻辑
BEGIN
	IF (NEW.productPrice > 1000)
	THEN SET NEW.productPrice = 1000;
	END IF;
END //
delimiter ;

-- 测试
INSERT INTO product VALUES('Ptest1','test1','test1',200.00);	-- 插入价格不大于1000的商品，价格不变
INSERT INTO product VALUES('Ptest2','test2','test2',2000.00);	-- 插入价格大于1000的商品，价格变成1000
SELECT * FROM product;
-- 恢复原本
DELETE FROM product WHERE productNo = 'Ptest1';
DELETE FROM product WHERE productNo = 'Ptest2';
-- END Q3.1

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q3.2

DROP TRIGGER IF EXISTS insert_order;
delimiter // 
CREATE TRIGGER insert_order
BEFORE INSERT ON ordermaster
FOR EACH ROW 				
BEGIN
	IF (NEW.employeeNo IN (SELECT employeeNo FROM employee E
    WHERE YEAR(hireDate) < 1992))
    THEN UPDATE employee E
		SET E.salary = salary * (1.05) * (1.03) WHERE E.employeeNo = NEW.employeeNo;
	ELSE UPDATE employee E
		SET E.salary = salary * (1.05) WHERE E.employeeNo = NEW.employeeNo;
	END IF;
END //
delimiter ;

-- 测试
# 输出插入订单前的员工表
SELECT Employee.employeeNo, Employee.salary AS oldSalary
FROM Employee
WHERE Employee.employeeNo='E2005003' OR Employee.employeeNo='E2005004';
# 插入订单，该业务员在1992年后入职
INSERT OrderMaster
VALUES('200812080001','C20080001','E2005003','20080717',0.00,'I000000011');
# 插入订单，该业务员在1992年前入职
INSERT OrderMaster
VALUES('200812080002','C20050002','E2005004','20080816',0.00,'I000000012');
# 输出插入订单后的员工表
SELECT Employee.employeeNo, Employee.salary AS newSalary
FROM Employee
WHERE Employee.employeeNo='E2005003' OR Employee.employeeNo='E2005004';
-- 恢复原本
-- 删除插入的订单记录
DELETE FROM OrderMaster 
WHERE orderNo IN ('200812080001', '200812080002');
-- 恢复 E2005003（1992年后入职）的薪资
UPDATE Employee 
SET salary = salary / 1.05
WHERE employeeNo = 'E2005003';
-- 恢复 E2005004（1992年前入职）的薪资
UPDATE Employee 
SET salary = salary / (1.05 * 1.03)
WHERE employeeNo = 'E2005004';

-- END Q3.2

