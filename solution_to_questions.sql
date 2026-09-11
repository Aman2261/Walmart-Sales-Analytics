USE walmart_db;
-- Basic data analsis
-- SELECT * FROM walmart LIMIT 5;
-- SELECT COUNT(*) FROM walmart;

-- Business Problems

-- Q1. What are the different payment methods, and how many transactions and items were sold with each method?
SELECT payment_method, 
COUNT(*) as n0_of_payments,
SUM(quantity) as no_of_item_sold
FROM walmart
GROUP BY payment_method;

-- Q2.  Which category received the highest average rating in each branch?
SELECT * 
FROM 
(
	SELECT 
    branch, 
    category, 
    AVG(rating) as avg_rating,
    RANK() OVER (PARTITION BY BRANCH ORDER BY AVG(rating) DESC) as rank_num
    FROM walmart
    GROUP BY branch, category
) as ranked
WHERE rank_num = 1;

-- Q3.  What is the busiest day of the week for each branch based on transaction volume?
SELECT * 
FROM
(   
    SELECT
        branch, 
        DATE_FORMAT(STR_TO_DATE(`date`, '%d/%m/%y'), '%W') as day,
        COUNT(*) as total_transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank_num
    FROM walmart
    GROUP BY branch, day
) as ranked
WHERE rank_num = 1;

-- Q4. How many items were sold through each payment method?
SELECT 
payment_method, 
COUNT(*) as no_of_qty
FROM walmart
GROUP BY payment_method;

-- Q5. What are the average, minimum, and maximum ratings for each category in each city?

SELECT 
category,
AVG(rating) as avg_rating, 
MIN(rating) as min_rating,
MAX(rating) as max_rating
FROM walmart
GROUP BY category;

-- Q6.What is the total profit for each category, ranked from highest to lowest?
SELECT 
category,
SUM(total_amount) as total_revenue,
SUM(total_amount * profit_margin) as total_profit,
RANK() OVER(ORDER BY SUM(total_amount * profit_margin) DESC) as ranked_profit
FROM walmart
GROUP BY category;

-- Q7. What is the most frequently used payment method in each branch?
SELECT * 
FROM
(
SELECT 
branch,
payment_method,
COUNT(*) as total_payments,
RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as ranking
FROM walmart
GROUP BY branch, payment_method
) as ranked
WHERE ranking=1;

-- Q8. How many transactions occur in each shift (Morning, Afternoon, Evening)
-- across branches?
SELECT
	branch,
    CASE 
		WHEN HOUR(CAST(time as TIME)) < 12 THEN 'Morning'
        WHEN HOUR(CAST(time as TIME)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
	END day_time,
    COUNT(*)
FROM walmart
GROUP BY branch, day_time
ORDER BY branch ASC;

-- Q9.  Which branches experienced the largest decrease in revenue compared to
-- the previous year(2022)?
WITH revenue_2022
AS
(
	SELECT 
    branch,
    SUM(total_amount) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(`date`, '%d/%m/%y')) = 2022 
    GROUP BY branch    
),
revenue_2023
AS
(
	SELECT 
    branch,
    SUM(total_amount) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(`date`, '%d/%m/%y')) = 2023 
    GROUP BY branch    
)

SELECT 
ls.branch,
ls.revenue as last_year_revenue,
cs.revenue as current_year_revenue,
ROUND(
	CAST((ls.revenue-cs.revenue) as DECIMAL(10,2))/ 
	CAST(ls.revenue as DECIMAL(10,2))*100,
    2
    ) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN revenue_2023 as cs
on ls.branch = cs.branch
WHERE ls.revenue > cs.revenue
ORDER BY rev_dec_ratio DESC
LIMIT 5;

-- Q10. Which product category generated the highest total revenue in each branch?
SELECT *
FROM
(
    SELECT
        branch,
        category,
        SUM(total_amount) AS total_revenue,
        RANK() OVER (
            PARTITION BY branch
            ORDER BY SUM(total_amount) DESC
        ) AS rank_num
    FROM walmart
    GROUP BY branch, category
) AS ranked
WHERE rank_num = 1;

--Q11. What is the monthly revenue trend for each branch?
SELECT
    branch,
    YEAR(STR_TO_DATE(`date`, '%d/%m/%y')) AS year,
    MONTH(STR_TO_DATE(`date`, '%d/%m/%y')) AS month,
    SUM(total_amount) AS monthly_revenue
FROM walmart
GROUP BY
    branch,
    YEAR(STR_TO_DATE(`date`, '%d/%m/%y')),
    MONTH(STR_TO_DATE(`date`, '%d/%m/%y'))
ORDER BY
    branch,
    year,
    month;



