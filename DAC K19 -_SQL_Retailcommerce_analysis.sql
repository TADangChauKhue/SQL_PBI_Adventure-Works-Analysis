--Q1 :Calc Quantity of items, Sales value & Order quantity by each Subcategory in L12M

declare date_max date;
set date_max=(SELECT  max(date(ModifiedDate)) FROM `adventureworks2019.Sales.SalesOrderDetail` );


select 
    FORMAT_DATE('%Y-%m ',PARSE_DATE('%Y-%m-%d',  cast(date(s.ModifiedDate) as string) )) period
    ,sp.Name 
    ,sum(OrderQty) qty_item
    ,sum(LineTotal) total_sales
    ,count(distinct(SalesOrderID)) order_cnt
from `adventureworks2019.Sales.SalesOrderDetail` s
left join `adventureworks2019.Production.Product` p 
      on s.ProductID = p.ProductID
left join `adventureworks2019.Production.ProductSubcategory`   sp 
      on p.ProductSubcategoryID = cast(sp.ProductSubcategoryID AS String)
where date(s.ModifiedDate) between date_sub(date_max,interval 12 month) and date_max
group by sp.Name,period
order by  period,sp.Name asc;

--Q2:Calc % YoY growth rate by SubCategory & release top 3 cat with highest grow rate. Can use metric: quantity_item. Round results to 2 decimal

with 
sale_info as (
  SELECT 
      FORMAT_TIMESTAMP("%Y", a.ModifiedDate) as yr
      , c.Name
      , sum(a.OrderQty) as qty_item

  FROM `adventureworks2019.Sales.SalesOrderDetail` a 
  LEFT JOIN `adventureworks2019.Production.Product` b on a.ProductID = b.ProductID
  LEFT JOIN `adventureworks2019.Production.ProductSubcategory` c on cast(b.ProductSubcategoryID as int) = c.ProductSubcategoryID

  GROUP BY 1,2
  ORDER BY 2 asc , 1 desc
),
sale_diff as (
  select *
  , lead (qty_item) over (partition by Name order by yr desc) as prv_qty
  , round(qty_item / (lead (qty_item) over (partition by Name order by yr desc)) -1,2) as qty_diff
  from sale_info
  order by 5 desc 
)
select distinct Name
      , qty_item
      , prv_qty
      , qty_diff
from sale_diff 
where qty_diff > 0
order by qty_diff desc 
limit 3
;

--Q3: Ranking Top 3 TeritoryID with biggest Order quantity of every year. If there's TerritoryID with same quantity in a year, do not skip the rank number

with data_raw as(
      select 
            FORMAT_TIMESTAMP("%Y", a.ModifiedDate) as yr
          ,h.TerritoryID
          ,sum(OrderQty) order_cnt
      from `adventureworks2019.Sales.SalesOrderDetail` s
      left join `adventureworks2019.Sales.SalesOrderHeader` h on s.SalesOrderID = h.SalesOrderID
      left join `adventureworks2019.Sales.SalesTerritory` t on t.TerritoryID=h.TerritoryID
      group by h.TerritoryID,yr)
    ,rank_table as(
        select *
        ,dense_rank() over (partition by yr order by data_raw.order_cnt desc) rk
        from data_raw)

select* from
rank_table 
where rk<=3;
-

--Q4 : Calc Total Discount Cost belongs to Seasonal Discount for each SubCategory

with total_cost_per_day as
  (SELECT a.ModifiedDate
          ,d.Name
          ,DiscountPct*UnitPrice*OrderQty as total_cost
  FROM adventureworks2019.Sales.SalesOrderDetail a
  inner join adventureworks2019.Sales.SpecialOffer b 
    on a.SpecialOfferID = b.SpecialOfferID
  inner join adventureworks2019.Production.Product c 
    on a.ProductID = c.ProductID
  inner join adventureworks2019.Production.ProductSubcategory d 
    on cast(c.ProductSubcategoryID as int) = d.ProductSubcategoryID
  where lower(Type) like '%seasonal discount%')

select format_datetime("%Y", ModifiedDate) as Time
       ,Name
       ,sum(total_cost) as total_cost
from total_cost_per_day
group by 1,2;


--Q5 : Retention rate of Customer in 2014 with status of Successfully Shipped (Cohort Analysis)

with info as (
          select 
          extract(month from ModifiedDate) as mth_order
          ,extract(year from ModifiedDate)  as yr
          ,CustomerID
          ,count(distinct SalesOrderID) as sales_cnt
          from `adventureworks2019.Sales.SalesOrderHeader` 
          where Status =5 and  extract(year from ModifiedDate) = 2014
          group by 1,2,3
            )
      ,row_num as(
        select *, row_number() over (partition by CustomerID order by mth_order) row_nb
        from info
         )
        ,first_order as(
        select distinct mth_order mth_join, yr, CustomerID
        from row_num 
        where row_nb = 1
        )
        ,all_join as (
        select distinct mth_order
                      , a.yr
                      , a.CustomerID
                      , b.mth_join
                      , concat ('M',a.mth_order - b.mth_join) as mth_diff
        from info a
        left join first_order b on a.CustomerID=b.CustomerID
        order by 3)
select distinct mth_join
              ,all_join.mth_diff
              ,count(distinct CustomerID) as customer_cnt
from all_join
group by 1,2
order by 1;


--Q6 : Trend of Stock level & MoM diff % by all product in 2011. If %gr rate is null then 0. Round to 1 decimal

with data_row as(
      SELECT name    
            ,extract(month from w.ModifiedDate) as mth
            ,extract(year from w.ModifiedDate)  as yr
            ,sum(stockedQty) stock_qty
      FROM `adventureworks2019.Production.WorkOrder`w
      left join `adventureworks2019.Production.Product` p on w.ProductID =p.ProductID
      group by name, yr, mth
       order by name,yr,mth desc )
 select *
,lead (stock_qty)  over (partition by  name,yr order by mth desc) stock_prv
,round((stock_qty -lead (stock_qty)  over (partition by  name,yr order by mth desc))/lead (stock_qty)  over (partition by  name,yr order by mth desc)*100.0,2) diff
from data_row
order by name,yr,mth desc ;

--Q7 :  Calc MoM Ratio of Stock / Sales in 2011 by product name Order results by month desc, ratio desc. Round Ratio to 1 decimal

with 
stock_info as (
      SELECT extract(month from w.ModifiedDate) as mth
            ,extract(year from w.ModifiedDate)  as yr
            ,w.productID
            ,sum(stockedQty) stock_cnt
      FROM `adventureworks2019.Production.WorkOrder`w
      left join `adventureworks2019.Production.Product` p on w.ProductID =p.ProductID
      group by  yr, mth, productID)

,sale_info as(
      select extract(month from s.ModifiedDate) as mth
            ,extract(year from s.ModifiedDate)  as yr
            ,s.productID
            ,p.Name
            ,sum(OrderQty) sales_cnt
      from `adventureworks2019.Sales.SalesOrderDetail` s
      left join `adventureworks2019.Production.Product` p on s.ProductID = p.ProductID
      group by Name,yr, mth, productID)

select sa.mth
      ,sa.yr
      ,sa.productID
      ,sa.Name
      ,stock_cnt
      ,sales_cnt
      ,round(stock_cnt/sales_cnt,1) ratio
from sale_info sa
left join stock_info so on so.productID=sa.productID
where so.yr=sa.yr and so.mth=sa.mth 
and sa.yr=2011 
order by ratio desc, mth desc;


--Q8: No of order and value at Pending status in 2014

SELECT extract(year from ModifiedDate) yr
      ,count(distinct PurchaseOrderID) order_cnt
      ,sum(totaldue) value
      
FROM `adventureworks2019.Purchasing.PurchaseOrderHeader`
where extract(year from ModifiedDate) = 2014 and Status =1
group by extract(year from ModifiedDate);

-->
select 
    extract (year from ModifiedDate) as yr
    , Status
    , count(distinct PurchaseOrderID) as order_Cnt 
    , sum(TotalDue) as value
from `adventureworks2019.Purchasing.PurchaseOrderHeader`
where Status = 1
and extract(year from ModifiedDate) = 2014
group by 1,2
;

                                                         