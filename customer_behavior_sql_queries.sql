#1)total revenue of male and female 
select gender,sum(purchase_amount) 
from customer_analysis
group by gender;
#2) which customer used the discount but still spend more money than avg purchase amt
 select customer_id,purchase_amount
 from customer_analysis
 where discount_applied='Yes' and purchase_amount>=(select avg(purchase_amount) from customer_analysis);
#3)which are top 5 products which have highest rating
select round(avg(review_rating),2) as max_rating ,item_purchased 
from customer_analysis 
group by item_purchased 
order by max_rating desc limit 5;
#4)compare the avg purchase amt between standard and express shipping
select shipping_type,avg(purchase_amount) 
from customer_analysis 
where shipping_type in ('Express','Standard') 
group by shipping_type;
#5)compare subscriber and non subscriber avg spent and total revenue;
select subscription_status,count(customer_id) as total_customers,round(avg(purchase_amount),2) as avg_amount,round(sum(purchase_amount),2) as total_revenue
from customer_analysis 
group by subscription_status
order by avg_amount,total_revenue desc;
SELECT 
    item_purchased,
    ROUND(100*SUM(CASE WHEN discount_applied = 1 THEN 1 ELSE 0 END)/ COUNT(*),2) AS discount_percentage
FROM customer_analysis
GROUP BY item_purchased
ORDER BY discount_percentage DESC
LIMIT 5;
#6 segment customer into new returning and loyal according to their previous purchase
with customer_type as(
select customer_id,previous_purchases,
case when previous_purchases=1 then 'new'
when previous_purchases between 2 and 10 then 'returning'
else 'loyal'
end as customer_segment
from customer_analysis)
select customer_segment,count(*) as "total_customer"
 from customer_type 
 group by customer_segment ;
 
 
 #7 what are top3 produt purchased in each category
 
SELECT category, item_purchased, total
FROM (
    SELECT 
        category,
        item_purchased,
        COUNT(*) AS total,
        RANK() OVER (PARTITION BY category ORDER BY COUNT(*) DESC) AS rnk
    FROM customer_analysis
    GROUP BY category, item_purchased
) t
WHERE rnk = 1;
with item_count as (select item_purchased,category,count(*) as total_order,
row_number()over (partition by category order by count(*) desc)as item_rank
from customer_analysis
group by category,item_purchased)
select category,item_purchased,item_rank,total_order
from item_count
where item_rank<=3;

# are customer who repeat buyers more than 5 prvious purchase likely to subcriber
select subscription_status,count(customer_id)as repeat_customers
from customer_analysis
where previous_purchases>=5
group by subscription_status;

#revenue contribution by age group
select age_group,sum(purchase_amount) as total_revenue from customer_analysis group by age_group