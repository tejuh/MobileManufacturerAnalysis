--1)ALL STATES WHERE CUSTOMERS HAVE BOUGHT CELLPHONES FROM 2005 

SELECT DISTINCT T1.STATE AS STATE1

FROM DIM_LOCATION AS T1

left JOIN FACT_TRANSACTIONS AS T2 ON T1.IDLocation = T2.IDLocation

WHERE 

year(date) >= 2005



-- 2) WHICH STATE IN US IS BUYING MORE SAMSUNG PHONES

SELECT top 1 
state from FACT_TRANSACTIONS as F
inner join DIM_LOCATION as L on f.IDLocation = l.IDLocation
inner join DIM_MODEL as m on f.IDModel = m.IDModel
inner join DIM_MANUFACTURER as D on m.IDManufacturer = d.IDManufacturer

WHERE 

d.Manufacturer_Name = 'Samsung'  AND l.COUNTRY = 'US'
group by
state
order by
count(quantity) desc



--3) SHOW THE NUMBER OF TRANSACTIONS FOR EACH MODEL PER ZIP CODE PER STATE 

SELECT F.IDCUSTOMER, M.Model_Name, D.ZipCode, D.STATE, COUNT(F.IDCustomer) 
AS  COUNT_ID FROM FACT_TRANSACTIONS AS F

LEFT JOIN DIM_LOCATION AS D ON F.IDLocation = D.IDLocation
LEFT JOIN DIM_MODEL AS M ON F.IDModel = M.IDModel

GROUP BY
F.IDCustomer, D.ZipCode, D.STATE, M.Model_Name



--4) SHOW THE CHEAPEST CELLPHONE

SELECT TOP 1 Unit_price, Model_Name FROM DIM_MODEL

ORDER BY Unit_price ASC;



--5) FIND OUT THE AVERAGE PRICE FOR EACH MODEL IN TOP 5 MANUFACTURERES IN TERMS OF SALES QUANTITY AND ORDER BY AVERAGE PRICE 

select top 5 manufacturer_name, d.Model_Name, abs(avg(totalPrice)) as averageP from fact_transactions as f

LEFT JOIN DIM_MODEL AS D ON F.IDModel = D.IDModel
INNER JOIN DIM_MANUFACTURER AS M ON D.IDManufacturer = M.IDManufacturer

where
manufacturer_name in

(
SELECT top 5 MANUFACTURER_NAME

FROM FACT_TRANSACTIONS AS F

LEFT JOIN DIM_MODEL AS D ON F.IDModel = D.IDModel
INNER JOIN DIM_MANUFACTURER AS M ON D.IDManufacturer = M.IDManufacturer

GROUP BY
Manufacturer_Name

order by 
abs(sum(Quantity)) desc
)

group by
d.Model_Name, Manufacturer_Name

order by
averageP desc



--6) LIST THE NAMES OF CUSTOMERS AND THE AVERAGE AMOUNT SPENT IN 2009 WHERE THE AVERAGE IS HIGHER THAN 500 
 
 SELECT C.Customer_Name, abs(AVG(TOTALPRICE)) AS AVERAGE_PRICE FROM FACT_TRANSACTIONS AS F

 LEFT JOIN DIM_CUSTOMER AS C ON F.IDCustomer = C.IDCustomer
 
 WHERE 
 YEAR(DATE) = 2009

 GROUP BY
 C.Customer_Name

 HAVING 
 abs(AVG(TOTALPRICE)) > 500



--7) LIST IF THERE IS ANY MODEL THAT WAS IN TOP 5 IN TERMS OF QUANTITY, SIMULTANEOUSLY IN 2008, 2009 AND 2010 

select * from 

(
SELECT TOP 5 MODEL_NAME FROM FACT_TRANSACTIONS AS F
INNER JOIN DIM_MODEL AS M ON F.IDModel = M.IDModel
WHERE 
datepart(year, date) = 2010 
GROUP BY
MODEL_NAME

ORDER BY 
abs(SUM(QUANTITY)) DESC

intersect 

SELECT TOP 5 MODEL_NAME FROM FACT_TRANSACTIONS AS F
INNER JOIN DIM_MODEL AS M ON F.IDModel = M.IDModel
WHERE 
datepart(year, date) = 2008 OR YEAR(DATE) = 2009 OR YEAR(DATE) = 2010 
GROUP BY
MODEL_NAME
ORDER BY 
abs(SUM(QUANTITY)) DESC 

INTERSECT 

SELECT TOP 5 MODEL_NAME FROM FACT_TRANSACTIONS AS F
INNER JOIN DIM_MODEL AS M ON F.IDModel = M.IDModel
WHERE 
datepart(year, date) = 2009 
GROUP BY
MODEL_NAME
ORDER BY 
abs(SUM(QUANTITY)) DESC

)
as A



--8) SHOW THE MANUFACTURERS WITH THE SECOND TOP SALES IN THE YEAR 2009 AND THE MANUFACTURER WITH THE SECOND TOP SALES IN THE YEAR OF 2010 

SELECT top 2 Manufacturer_Name, QTY, rank() over (partition by years order by qty desc) my_rank FROM 
(
SELECT TOP 2 d.Manufacturer_Name, m.IDManufacturer, abs(SUM(QUANTITY))  AS QTY, YEAR(DATE) as years FROM FACT_TRANSACTIONS 
AS F
LEFT JOIN DIM_MODEL AS M ON F.IDModel = M.IDModel
left join DIM_MANUFACTURER as D on m.IDManufacturer = d.IDManufacturer
WHERE
YEAR(DATE) = 2009  
GROUP BY 
M.IDManufacturer, d.Manufacturer_Name, YEAR(DATE)
ORDER BY 
QTY DESC

UNION   

SELECT TOP 2 d.Manufacturer_Name, M.IDManufacturer,  abs(SUM(QUANTITY)) AS QTY, YEAR(DATE) as years FROM FACT_TRANSACTIONS AS F
LEFT JOIN DIM_MODEL AS M ON F.IDModel = M.IDModel
left join DIM_MANUFACTURER as D on m.IDManufacturer = d.IDManufacturer
WHERE
YEAR(DATE) = 2010  
GROUP BY 
M.IDManufacturer, d.Manufacturer_Name, YEAR(DATE)
ORDER BY 
QTY DESC 
)
AS TAB1
order by 
my_rank desc



--9) SHOW THE MANUFACTURERS THAT SOLD CELLPHONE IN 2010 BUT DIDNT IN 2009 - correct

select * from 
(
SELECT  d.IDManufacturer, d.Manufacturer_Name FROM FACT_TRANSACTIONS AS F
INNER JOIN DIM_MODEL AS M ON F.IDModel = M.IDModel
left join DIM_MANUFACTURER as D on m.IDManufacturer = d.IDManufacturer
WHERE 
YEAR(DATE) = 2010 
GROUP BY
d.IDManufacturer, d.Manufacturer_Name

Except 

SELECT  d.IDManufacturer,  d.Manufacturer_Name FROM FACT_TRANSACTIONS AS F
INNER JOIN DIM_MODEL AS M ON F.IDModel = M.IDModel
left join DIM_MANUFACTURER as D on m.IDManufacturer = d.IDManufacturer
WHERE 
YEAR(DATE) = 2009 
GROUP BY
d.IDManufacturer,  d.Manufacturer_Name
)
as A



--10) FIND TOP 100 CUSTOMERS AND THEIR AVERAGE SPEND, AVERAGE QUANTITY BY EACH YEAR. ALSO FIND THE PERCENTAGE OF CHANGE IN THEIR SPENDING

select Customer,  averageP,  avgQ, years, ((averageP-per)/averageP) * 100 as percentage_change from

(
 select top 100 c.Customer_Name as customer, abs(avg(TotalPrice)) as averageP, avg(quantity) as avgQ, year(date) as years,
 lag(abs(avg(TotalPrice)),1) over (partition by customer_name order by year(date))  as per

 from FACT_TRANSACTIONS as F

 left join DIM_CUSTOMER as c on f.IDCustomer = c.IDCustomer

 group by
 c.Customer_Name, year(date)
 order by 
 c.Customer_Name, year(date) asc )

 as z

 
