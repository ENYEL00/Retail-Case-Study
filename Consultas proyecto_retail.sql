USE Retail_case_study;

SELECT * FROM customer;
SELECT * FROM transactions;
SELECT * FROM prod_cat_info;

CREATE TABLE customer1 SELECT customer_Id,CONCAT(right(DOB,4),"-",substring(DOB,4,2),"-",LEFT(DOB,2)) as Date_birth,Gender,city_code
FROM customer;	--Cambio el orden del formato de la fecha para despues cambiar el tipo de dato a DATE. Al mismo tiempo en que creo una tabla con el nuevo orden

ALTER TABLE customer1 MODIFY Date_birth DATE;	--Cambio el tipo de dato de TEXT a DATE del campo Date_birth

DROP TABLE customer;	--Elimino la tabla vieja

RENAME TABLE customer1 to customer;	--Cambio el nombre de la tabla




--AHORA HARE LO MISMO CON LA TABLA TRANSACTIONS
select transaction_date FROM transactions;
SELECT REPLACE(transaction_date,"/","-") FROM transactions
WHERE substring(transaction_date,3,1) = 0; 

SELECT right(transaction_date,4) AS YEARS FROM transactions ;
SELECT transaction_date, CASE 
WHEN LEN(transaction_date) = '10 ' THEN substring(transaction_date,4,2)
WHEN LEN(transaction_date) = '9' AND substring(transaction_date,2,1) = "/" THEN substring(transaction_date,3,2)
WHEN LEN(transaction_date) = '9' THEN LPAD(substring(transaction_date,4,1),2,0)
WHEN LEN(transaction_date) = '8' THEN LPAD(substring(transaction_date,3,1),2,0)
end  AS MONTHS FROM transactions;
SELECT CASE
WHEN LEN(tran_date) = '8' THEN  LPAD(LEFT(tran_date,1),2,0)
WHEN LEN(tran_date) = '9' or LEN(tran_date) = '10' THEN LEFT(tran_date,2)
end AS days FROM transactions;


CREATE TABLE transactions1 SELECT transaction_id, cust_id,
CONCAT(right(transaction_date,4),'-',CASE 
WHEN LENGTH(transaction_date) = '10 ' THEN substring(transaction_date,4,2)
WHEN LENGTH(transaction_date) = '9' AND substring(transaction_date,2,1) = "/" THEN substring(transaction_date,3,2)
WHEN LENGTH(transaction_date) = '9' THEN LPAD(substring(transaction_date,4,1),2,0)
WHEN LENGTH(transaction_date) = '8' THEN LPAD(substring(transaction_date,3,1),2,0)
end,'-',CASE
WHEN LENGTH(transaction_date) = '8' THEN  LPAD(LEFT(transaction_date,1),2,0)
WHEN LENGTH(transaction_date) = '9' or LENGTH(transaction_date) = '10' THEN LEFT(transaction_date,2)
end) as transaction_date, prod_subcat_code, prod_cat_code,
Qty, Rate, Tax, total_amt, Store_type
FROM transactions;

SELECT tran_date FROM transactions;
SELECT transaction_date from transactions1
WHERE MONTH(transaction_date) = "00";

DROP TABLE transactions;
RENAME TABLE transactions1 to transactions;



--NOW CREATE THE PRIMARY KEIS
ALTER table customer ADD primary key (customer_Id);


/*NOW LETS STAR TO QUERY SOME INFORMATION OF INTEREST
#First I need to know my customers. How many men/women are there?
#I need to know the age or the ranges of age
#And I need to know where are they
*/

SELECT COUNT(*) FROM customer;

SELECT COUNT(*) as Customer_men FROM customer
where Gender = 'M';	
--How many men there are in customer table
SELECT CONCAT(
		ROUND(
			COUNT(CASE
				WHEN Gender = 'M' THEN 1 END)/COUNT(*)*100,2),'%') AS Customer_men FROM customer;	# % customer men

SELECT COUNT(*) as Customers_women FROM customer
WHERE Gender = 'F';	
--How many women there are in customer table
SELECT CONCAT(
		ROUND(
			COUNT(CASE
				WHEN Gender = 'F' THEN 1 END)/COUNT(*)*100,2),'%') AS Customer_women FROM customer;	# % customer women
                
                

SELECT city_code, COUNT(*) AS customer_per_city, 
COUNT(CASE WHEN Gender = 'F'THEN 1 END) as women, count(CASE WHEN Gender='M' THEN 1 END) as men FROM customer
GROUP BY city_code
ORDER BY customer_per_city DESC;	#How many customer there are per city



#Now that I know my customer information, I need to know how they make transactions in my business
SELECT COUNT(*), MONTH(transaction_date), YEAR(transaction_date), SUM(Qty) FROM transactions
WHERE Qty < '0'
GROUP BY MONTH(transaction_date), YEAR(transaction_date);	#Get now how many transactions and the quantity were about devolution per month and year

SELECT p.prod_cat, p.prod_subcat, MONTH(transaction_date), YEAR(transaction_date), SUM(Qty) FROM prod_cat_info p
JOIN transactions t ON t.prod_subcat_code = p.prod_sub_cat_code AND t.prod_cat_code = p.prod_cat_code
WHERE Qty < "0"
GROUP BY MONTH(transaction_date); 