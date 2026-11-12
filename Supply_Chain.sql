select * 
from cleaned_supply_chain_data

-- Change Datatypes

alter table [dbo].[cleaned_supply_chain_data]
alter column  [Days_for_shipping_real]  int;

alter table [dbo].[cleaned_supply_chain_data]
alter column [Days_for_shipment_scheduled] int

-- check is there any null after  changing datatype
select 
	Days_for_shipment_scheduled,
	Days_for_shipping_real
from cleaned_supply_chain_data
where 
	Days_for_shipment_scheduled is null 
	and Days_for_shipping_real is null


-- check how my days diff between Days_for_shipment_scheduled and Days_for_shipping_real

select 
	Days_for_shipment_scheduled,
	Days_for_shipping_real,
	(Days_for_shipping_real - Days_for_shipment_scheduled ) as Days_Diff
from cleaned_supply_chain_data
order by Days_Diff asc

/* Insignt : 
	1) We can see the most late delivery is 4 days.
	2) Fast delivery is 2 days before the due date of delivery
*/


-- Total Sales by Delivery Status

select 
	Delivery_Status,
	ROUND(sum(Sales),2)as Total_Sales
from cleaned_supply_chain_data
group by Delivery_Status


-- Total / Avg Profit by country

select top 5
	order_country,
	round(sum(Order_Profit_Per_Order),2) as Total_Profit,
	round(avg(Order_Profit_Per_Order),2) as Avg_Profit
from cleaned_supply_chain_data
group by Order_Country 
order by Total_Profit desc


-- Which countries generate the highest total sales and total profit?

select 
	Order_Country,
	round(sum(Sales),2) as Total_Sales,
	round(sum(Order_Profit_Per_Order),2) as Total_Profit
from cleaned_supply_chain_data
group by Order_Country
order by Total_Sales desc

-- Which product categories generate the highest sales and profit?

select 
	Category_Name,
	round(sum(Sales),2) as Total_Sales,
	round(sum(Order_Profit_Per_Order),2) as Total_Profit
from cleaned_supply_chain_data
group by Category_Name
order by Total_Sales desc,Total_Profit desc


-- Which products are generating the most profit and which are generating losses?


select 
	Product_Name,
	round(sum(Sales) , 2)as Total_Sales,
	round(sum(Order_Profit_Per_Order) , 2)as Total_Profit,
	ROW_NUMBER() over (order by sum(Sales) desc ,sum(Order_Profit_Per_Order) asc ) rnk
from cleaned_supply_chain_data
group by Product_Name
having round(sum(Order_Profit_Per_Order) , 2) < 0


-- Which regions have the highest number of orders ?

select 
	Order_Region,
	COUNT(Order_Id) as Total_Order
from cleaned_supply_chain_data
group by Order_Region
order by Total_Order desc

-- Which regions have the highest number of  sales?

select 
	Order_Region,
	round(sum(Sales),2) as Total_Sales
from cleaned_supply_chain_data
group by Order_Region
order by Total_Sales desc


-- Which shipping modes have the highest late-delivery risk?

select 
	Shipping_Mode,
	COUNT(Late_delivery_risk) as Late_Risk
from cleaned_supply_chain_data
group by Shipping_Mode
order by Late_Risk desc


-- Which countries or regions have the highest average actual shipping time?

select
	Order_Region,
	Customer_Country,
	AVG(Days_for_shipment_scheduled) as Avg_Shipping_day
from cleaned_supply_chain_data
group by Order_Region,Customer_Country
order by Avg_Shipping_day desc

-- How much does actual shipping time differ from scheduled shipping time?

select 
	Days_for_shipment_scheduled,
	Days_for_shipping_real,
	( Days_for_shipping_real - Days_for_shipment_scheduled) as Diff
from cleaned_supply_chain_data


-- Which customer segments generate the highest sales and profit?

select
	Customer_Segment,
	round(sum(Sales),2) as Highest_Sales,
	round(sum(Order_Profit_Per_Order),2) as Highest_Profit
from cleaned_supply_chain_data
group by Customer_Segment
order by Highest_Sales desc

-- Which months or years have the highest sales and profit?

select 
	Year(order_date_DateOrders) as Year,
	MONTH(order_date_DateOrders) as Month,
	round(sum(Sales),0) as Total_Sales,
	round(sum(Order_Profit_Per_Order),0) as Total_Profit
from cleaned_supply_chain_data
group by Year(order_date_DateOrders), MONTH(order_date_DateOrders)
order by Total_Sales desc, Total_Profit desc


-- Which products or categories have high sales but low/negative profit?

SELECT
    Product_Name,
    SUM(Sales) AS Total_Sales,
    SUM(Order_Profit_Per_Order) AS Total_Profit
FROM cleaned_supply_chain_data
GROUP BY Product_Name
HAVING SUM(Order_Profit_Per_Order) < 0
ORDER BY Total_Sales DESC;

-- Late Delivery risk % by Shipping Mode

select 
	Shipping_Mode,
	count(*) as Total,
	sum(case when Late_delivery_risk = 1 then 1 else 0 end ) as Risk,
	(100.0 * sum(case when Late_delivery_risk = 1 then 1 else 0 end ) / count(*)) as Risk_rate
from cleaned_supply_chain_data
group by Shipping_Mode 



