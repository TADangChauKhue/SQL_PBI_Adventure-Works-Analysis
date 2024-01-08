# SQL_PBI_Adventure-Works-Analysis
Utilize  BigQuery SQL to explore, data wrangling techniques to analyze datasets, connect data to Power Bi, build model and dashboard.

## Introduction

Adventure Works Cycles, a large, multinational manufacturing company, produces and distributes metal and composite bicycles to North American, European, and Asian commercial markets. While its base operation is located in Bothell,  Washington, and employs 500 people, several regional sales teams are located throughout the company’s market region. 

After a successful fiscal year, Adventure Works Cycles is looking to broaden its market share by focusing its sales efforts on the company’s best customers.

In this project, I use BigQuery SQL to explore, data wrangling techniques to analyze datasets. I analyze and visualize data on Power BI, using design thinking framework to determine the best customers across all product lines, and clarify problems of each customer segment.

**1.Business question**

The sales teams have identified the following requirements that will enable them to perform their jobs better: 
•	Customer segmentation and profiling:
○	Who are the best customers across all product lines? With whom should the sales team focus its efforts for building long-term relationships? 
○	What products are the customers buying and at what rate? 
•	Sales performance:
○	When analyzing the insights of Sales Performance, the manager will comprehend the trend of the performance of each region through time series analysis and recognize the region as either the potential one or not. Then, they will be supported to make good decisions for business strategies.


**2.Dataset**

Dataset is around 50 tables grouped into 6 categories of: Human Resources, Person, Production, Manufacturing, Purchasing, Inventory and Sales. 

![image](https://github.com/TADangChauKhue/SQL_PBI_Adventure-Works-Analysis/assets/151337392/18e51f39-f50d-489a-8069-71b289590af1)



## Data explore

Based on Data Dictionary, I use the Google Big Query SQL to explore the dataset focusing Sales and Product tables. 

The SQLrequests respond to these following questions:

-Calc Quantity of items, Sales value & Order quantity by each Subcategory in L12M

-Calc % YoY growth rate by SubCategory & release top 3 cat with highest grow rate. Can use metric: quantity_item. Round results to 2 decimal

-Ranking Top 3 TeritoryID with biggest Order quantity of every year. If there's TerritoryID with same quantity in a year, do not skip the rank number

-Calc Total Discount Cost belongs to Seasonal Discount for each SubCategory

-Retention rate of Customer in 2014 with status of Successfully Shipped (Cohort Analysis)

-Trend of Stock level & MoM diff % by all product in 2011. If %gr rate is null then 0. Round to 1 decimal

-Calc MoM Ratio of Stock / Sales in 2011 by product name

-No of order and value at Pending status in 2014


## Data modelling

After analyzing dataset, I use data wrangling techniques (clean, transform , merge tables…) to validate and import data for modelling.

![image](https://github.com/TADangChauKhue/SQL_PBI_Adventure-Works-Analysis/assets/151337392/98a2160c-e7fa-4489-9d8e-452e327d0b79)


## Data vizualisation

**Sales dashboard**

![image](https://github.com/TADangChauKhue/SQL_PBI_Adventure-Works-Analysis/assets/151337392/5b4baeda-ca28-45fe-9aee-877fa39bf693)


**Customer profiling** 


![image](https://github.com/TADangChauKhue/SQL_PBI_Adventure-Works-Analysis/assets/151337392/0c4c3ecd-9bdb-4a73-8d12-a2f344309b86)




## Insights

![image](https://github.com/TADangChauKhue/SQL_PBI_Adventure-Works-Analysis/assets/151337392/f43f8b56-9940-4456-979a-8fb0579b7ac7)


![image](https://github.com/TADangChauKhue/SQL_PBI_Adventure-Works-Analysis/assets/151337392/ac293869-c43d-4fce-91bb-cbdf13783ebc)

