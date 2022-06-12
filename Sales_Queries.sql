CREATE DATABASE Casestudy
USE Casestudy
GO
Select * From Orders
GO

--1. Total cost, revenue and profit by both region and item type?

CREATE VIEW Orders_Regions AS 
SELECT *,
CASE WHEN Country IN ('China', 'Mongolia', 'Uzbekistan', 'Laos', 'Maldives', 'Taiwan', 'Kazakhstan', 'Sri Lanka', 'South Korea', 'Cambodia', 'Brunei', 'Turkmenistan', 
					  'Thailand', 'Vietnam', 'Bangladesh', 'Philippines', 'Bhutan', 'Kyrgyzstan', 'Indonesia', 'India', 'North Korea', 'Singapore', 'Japan', 'Tajikistan', 
					  'Myanmar', 'Nepal', 'Malaysia')
	      THEN 'Asia'
	 WHEN Country IN ('Tonga','Kiribati','Solomon Islands', 'Palau', 'New Zealand', 'Federated States of Micronesia','East Timor', 'Samoa','Australia','Fiji','Marshall Islands',
	                  'Vanuatu', 'Tuvalu', 'Papua New Guinea','Nauru')
		  THEN 'Australia and Oceania'
	 WHEN Country IN ('Haiti', 'Dominica', 'Guatemala', 'The Bahamas', 'Grenada','Antigua and Barbuda' ,'Costa Rica','Dominican Republic', 'Saint Kitts and Nevis' , 'Jamaica',
	                  'Saint Lucia','Cuba','Nicaragua','El Salvador','Panama','Trinidad and Tobago','Honduras','Belize','Barbados','Saint Vincent and the Grenadines')
		  THEN 'Central America and the Caribbean'
	 WHEN Country IN ('Sweden','Kosovo','Iceland','France','Latvia','Russia','San Marino', 'Liechtenstein','Czech Republic','Lithuania','Italy','Bulgaria','Ukraine','Poland',
	                  'Slovenia','Netherlands','Romania','Estonia','Georgia','United Kingdom','Malta','Montenegro','Ireland','Hungary','Bosnia and Herzegovina','Albania','Serbia',
					  'Croatia','Luxembourg','Macedonia','Slovakia','Moldova','Belgium','Belarus','Andorra','Germany','Spain','Vatican City','Finland','Monaco','Portugal','Greece',
					  'Austria','Norway','Denmark','Switzerland','Armenia','Cyprus')
		  THEN 'Europe'
	 WHEN Country IN ('Oman','Morocco','Iraq','Egypt','Algeria','Saudi Arabia','Yemen','Pakistan','Lebanon','Bahrain','Jordan','Iran','Turkey','Tunisia','Azerbaijan','Kuwait',
	                  'Somalia','Israel','Libya','United Arab Emirates','Qatar','Syria','Afghanistan')
	      THEN 'Middle East and North Africa'
	 WHEN Country IN ('United States of America','Canada','Greenland','Mexico')
	      THEN 'North America'
	 WHEN Country IN ('Central African Republic','Equatorial Guinea','Sao Tome and Principe','Cote d''Ivoire', 'Senegal', 'South Africa','The Gambia','Burundi',
	                  'Republic of the Congo','Djibouti','Madagascar','Zimbabwe','Guinea','Uganda','Eritrea','Liberia','Namibia','Mauritius','Benin', 'Comoros', 'Swaziland',
					  'Burkina Faso','Kenya','Seychelles','Niger','Rwanda','Cape Verde','Tanzania','Ghana','Botswana','Guinea-Bissau','Gabon','Democratic Republic of the Congo',
					  'Togo','South Sudan','Chad','Angola','Cameroon','Ethiopia','Malawi','Nigeria','Zambia','Mozambique','Lesotho','Mali','Mauritania','Sudan','Sierra Leone')
	      THEN 'Sub-Saharan Africa'
END AS Region
From Orders

SELECT [Item Type],[Region], SUM(Cost) AS Total_Cost,  SUM ([Units Sold]*[Price]) AS Revenue, SUM ([Units Sold]*[Price]) - SUM(Cost) AS Profit
From Orders_Regions 
GROUP BY [Item Type],[Region]
ORDER BY  Profit DESC

--2. How many orders of Beverages are there in 2011?
SELECT COUNT([Order ID]) AS Total_Order_Beverages
FROM Orders
WHERE [Item Type] = 'Beverages'  AND YEAR([Order Date]) = 2011


--3. For each item type, what is the country which gains the max profit?

WITH temp1 AS (
SELECT [Item Type],[Country], SUM(Cost) AS Total_Cost,  
	   SUM ([Units Sold]*[Price]) AS Revenue, 
	   SUM ([Units Sold]*[Price]) - SUM(Cost) AS Profit
From Orders
GROUP BY [Item Type],[Country]),

temp2 AS (
SELECT *, RANK () OVER (PARTITION BY temp1.[Item Type] ORDER BY temp1.Profit DESC) AS rnk
FROM temp1)

SELECT temp2.[Item Type], temp2.[Country],temp2.[Profit]
FROM temp2
WHERE temp2.rnk = 1
ORDER BY temp2.[Profit] DESC
--4. Which region has longest average delivery time in 2016? How long?

Select * From Orders_Regions

SELECT [Region], AVG(DATEDIFF(D,[Order Date],[Ship Date])) AS Avg_Delivery_Time
FROM Orders_Regions
WHERE YEAR([Order Date]) = 2016
GROUP BY [Region]
ORDER BY Avg_Delivery_Time DESC

--5. Which item type contributes most profit in Jan? 
WITH t1 AS(
SELECT [Item Type], CONCAT(MONTH([Order Date]),'-',YEAR([Order Date])) AS Month_Year, 
	   SUM(Cost) AS Total_Cost,  SUM ([Units Sold]*[Price]) AS Revenue, 
	   SUM ([Units Sold]*[Price]) - SUM(Cost) AS Profit
FROM Orders
WHERE MONTH([Order Date]) = 1
GROUP BY [Item Type],CONCAT(MONTH([Order Date]),'-',YEAR([Order Date]))
),

t2 AS (
SELECT *, RANK() OVER (PARTITION BY t1.[Month_Year] ORDER BY t1.Profit DESC) AS rnk
FROM t1)

SELECT [Month_Year], [Item Type], [Profit]
FROM t2
WHERE rnk = 1

--6. What is total profit of top 5 countries which are sorted by Online channel orders?
SELECT TOP 5 [Country], SUM(Cost) AS Total_Cost,  
		   SUM ([Units Sold]*[Price]) AS Revenue, 
		   SUM ([Units Sold]*[Price]) - SUM(Cost) AS Profit
FROM Orders
WHERE [Sales Channel] = 'Online'
GROUP BY [Country]
ORDER BY Profit DESC

