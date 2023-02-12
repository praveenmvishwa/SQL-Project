


      SELECT distinct(market) 
      FROM gdb023.dim_customer 
      where 
      customer="Atliq Exclusive" 
      and region="APAC";



-- 2. What is the percentage of unique product increase in 2021 vs. 2020? The final --
   -- output contains these fields,
                    --  unique_products_2020
                      -- unique_products_2021
                    --  percentage_chg


      with CTE1 as 
      (SELECT 
      count(distinct case when a.fiscal_year=2020 then a.product_code end) 
      as unique_products_2020,
      count(distinct case when a.fiscal_year=2021 then a.product_code end) 
      as unique_products_2021
      from gdb023.fact_sales_monthly a)
      SELECT unique_products_2020, unique_products_2021,
      round((unique_products_2021 - unique_products_2020) / unique_products_2020*100,2) 
      as prcntChange
      FROM CTE1;
      SELECT prcntChange FROM CTE1;



3. Provide a report with all the unique product counts for each segment and sort 
   them in descending order of product counts. The final output contains two 
   fields,
            segment
            product_count


      SELECT segment, count(distinct(product)) as product_count 
      FROM gdb023.dim_product 
      group by segment
      order by product_count DESC;
   


4. Follow-up: Which segment had the most increase in unique products in 2021 vs 
   2020? The final output contains these fields,
                      segment
                      product_count_2020
                      product_count_2021
                      difference


      with cte1 as
      (select
      a.segment, b.product_code, b.fiscal_year,a.product 
      from gdb023.dim_product a join gdb023.fact_sales_monthly b
      on a.product_code = b.product_code),
      cte2 as
      (select segment,
      count(distinct case when cte1.fiscal_year = 2020 then cte1.product end) as 
      product_count_2020,
      count(distinct case when cte1.fiscal_year = 2021 then cte1.product end) as 
      product_count_2021
      from cte1 
      group by segment
      order by product_count_2020 desc)
      select segment, product_count_2020, product_count_2021,
      (product_count_2021 - product_count_2020) as difference
      from cte2 order by difference desc;



5. Get the products that have the highest and lowest manufacturing costs.The final 
   output should contain these fields,
                                   product_code
                                   product
                                   manufacturing_cost


      select 
      a.product_code, b.product, 
      a.manufacturing_cost
      from gdb023.fact_manufacturing_cost a join gdb023.dim_product b
      on a.product_code = b.product_code
      where 
      manufacturing_cost = (select min(manufacturing_cost) from fact_manufacturing_cost)
      or
      manufacturing_cost = (select max(manufacturing_cost) from fact_manufacturing_cost)



6. Generate a report which contains the top 5 customers who received an average 
   high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market. 
   The final output contains these fields,
                                   customer_code
                                   customer
                                   average_discount_percentage


      with CTE1 as
      (select 
      a.customer_code, b.customer, 
      a.pre_invoice_discount_pct,
      b.market, a.fiscal_year
      from gdb023.fact_pre_invoice_deductions a join gdb023.dim_customer b
      on a.customer_code = b.customer_code )

      select customer_code, customer, 
      round(avg(pre_invoice_discount_pct),4) as avg_invoice_discount
      from CTE1
      where market = "India" and fiscal_year=2021
      group by customer_code, customer
      order by avg_invoice_discount desc
      limit 5;



7. Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” 
   for each month. This analysis helps to get an idea of low and high-performing 
   months and take strategic decisions.
   The final report contains these columns:
                          Month
                          Year
                          Gross sales Amount


      select 
      month(a.date) as month, 
      year(a.date) as year, b.customer,
      sum(a.sold_quantity*c.gross_price) as gross_sales_amount
      from gdb023.fact_sales_monthly a join gdb023.dim_customer b
      on a.customer_code = b.customer_code
      join gdb023.fact_gross_price c
      on a.product_code = c.product_code
      where b.customer="Atliq Exclusive"
      group by month, year;



8. In which quarter of 2020, got the maximum total_sold_quantity? The final output 
   contains these fields sorted by the total_sold_quantity,
                              Quarter
                              total_sold_quantity


      select 
      case 
      when month(a.date) in (9,10,11) then '1st Quarter'
      when month(a.date) in (12,1,2) then '2nd Quarter'
      when month(a.date) in (3,4,5) then '3rd Quarter'
      when month(a.date) in (6,7,8) then '4th Quarter' end
      as Quarter,
      sum(a.sold_quantity) as Total_Sold_Quantity 
      FROM gdb023.fact_sales_monthly a
      where a.fiscal_year = 2020
      group by Quarter
      order by Total_Sold_Quantity DESC;



9. Which channel helped to bring more gross sales in the fiscal year 2021 and the 
   percentage of contribution? The final output contains these fields,
                                channel
                                gross_sales_mln
                                percentage


      with CTE1 as
      (select 
      channel as Channel, 
      round(sum(b.gross_price*c.sold_quantity)/1000000,2) as Gross_Sales_mln
      from gdb023.dim_customer a join gdb023.fact_sales_monthly c
      on a.customer_code = c.customer_code
      join gdb023.fact_gross_price b
      on b.product_code = c.product_code
      where c.fiscal_year = 2021
      group by channel
      Order by Gross_Sales_mln DESC)

      select *,(Gross_Sales_mln*100)/sum(Gross_Sales_mln) over()
      as Percentage
      from CTE1



10. Get the Top 3 products in each division that have a high total_sold_quantity 
    in the fiscal_year 2021? The final output contains these fields,
                                  division
                                  product_code
                                  product
                                  total_sold_quantity
                                  rank_order


      with CTE1 as
      (select 
      a.division, a.product_code, a.product, 
      sum(b.sold_quantity) as Total_Sold_Quantity
      from gdb023.dim_product a join gdb023.fact_sales_monthly b
      on a.product_code = b.product_code
      where b.fiscal_year = 2021
      group by division, a.product_code, a.product),

      CTE2 as
      (select *, rank()
      over(partition by division order by Total_Sold_Quantity desc) as Rank_Order
      from CTE1)
      select * from CTE2
      where Rank_Order < 4

   

   
   
