-- Q1 Total content items

SELECT
		COUNT(DISTINCT content_id) AS total_content_items
FROM
		jotstar_db..contents

-- Q2 Total users

SELECT
		COUNT(DISTINCT user_id) AS total_users
FROM
		jotstar_db..subscribers

-- Q3 Paid users

SELECT
		COUNT(DISTINCT user_id) AS paid_users
FROM
		jotstar_db..subscribers
WHERE
		subscription_plan IN ('VIP','Premium')

-- Q4 Paid users %

SELECT
		ROUND(CAST(COUNT(CASE WHEN subscription_plan IN ('VIP','Premium')THEN 1 ELSE NULL END)*1.0/COUNT(user_id)AS FLOAT)*100,2) AS 'Paid User %'
FROM
		jotstar_db..subscribers

-- Q5 Active users

SELECT
		COUNT(DISTINCT user_id) AS active_users
FROM
		jotstar_db..subscribers
WHERE 
		new_subscription_plan IS NOT NULL

-- Q6 Inactive users

SELECT
		COUNT(DISTINCT user_id) AS active_users
FROM
		jotstar_db..subscribers
WHERE 
		new_subscription_plan IS NULL

-- Q7 Inactive Rate (%)

SELECT
		ROUND(CAST(COUNT(CASE WHEN new_subscription_plan IS NULL THEN 1 ELSE NULL END)*1.0/COUNT(DISTINCT user_id)AS FLOAT)*100,2) AS 'Inactive Rate %'
FROM
		jotstar_db..subscribers

-- Q8 Active Rate (%)

SELECT 
		ROUND(CAST(COUNT(CASE WHEN new_subscription_plan IS NOT NULL THEN 1 ELSE NULL END)*1.0/COUNT(DISTINCT user_id) AS FLOAT) * 100,2) AS 'Active Rate %'
FROM
		jotstar_db..subscribers

-- Q9 Upgraded users

SELECT
		COUNT(CASE WHEN (subscription_plan ='Free' AND new_subscription_plan IN ('VIP','Premium')) OR
				(subscription_plan = 'Premium' AND new_subscription_plan = 'VIP') THEN 1 ELSE NULL END) AS 'upgrade users',
		COUNT(DISTINCT user_id) AS 'total users'
FROM
		jotstar_db..subscribers

-- Q10 Upgrade Rate (%)

SELECT
		COUNT(CASE WHEN (subscription_plan ='Free' AND new_subscription_plan IN ('VIP','Premium')) OR
				(subscription_plan = 'Premium' AND new_subscription_plan = 'VIP') THEN 1 ELSE NULL END) AS 'upgrade users',
		COUNT(DISTINCT user_id) AS 'total users',
		ROUND(CAST(COUNT(CASE WHEN (subscription_plan ='Free' AND new_subscription_plan IN ('VIP','Premium')) OR
				(subscription_plan = 'Premium' AND new_subscription_plan = 'VIP') THEN 1 ELSE NULL END)AS FLOAT)*1.0/COUNT(DISTINCT user_id)*100,2) AS 'Upgrade %'
FROM
		jotstar_db..subscribers

-- Q11 Downgraded users

SELECT 
		COUNT(CASE WHEN (subscription_plan ='VIP' AND new_subscription_plan IN ('Free','Premium')) OR
				(subscription_plan = 'Premium' AND new_subscription_plan = 'Free') THEN 1 ELSE NULL END) AS 'downgrade users',
		COUNT(DISTINCT user_id) AS 'total users'
FROM
		jotstar_db..subscribers

-- Q12 Downgrade Rate (%)

SELECT
		COUNT(CASE WHEN (subscription_plan ='VIP' AND new_subscription_plan IN ('Free','Premium')) OR
				(subscription_plan = 'Premium' AND new_subscription_plan = 'Free') THEN 1 ELSE NULL END) AS 'upgrade users',
		COUNT(DISTINCT user_id) AS 'total users',
		ROUND(CAST(COUNT(CASE WHEN (subscription_plan ='VIP' AND new_subscription_plan IN ('Free','Premium')) OR
				(subscription_plan = 'Premium' AND new_subscription_plan = 'Free') THEN 1 ELSE NULL END)AS FLOAT)*1.0/COUNT(DISTINCT user_id)*100,2) AS 'Upgrade %'
FROM
		jotstar_db..subscribers

-- Q13 Total watch time (hrs)

SELECT
		SUM(total_watch_time_mins)/60 AS 'Total watch time (hrs)'
FROM
		jotstar_db..content_consumption

-- Q14 Average watch time (hrs)

SELECT
		AVG(total_watch_time_mins)/60 AS 'Average watch time (hrs)'
FROM
		jotstar_db..content_consumption

-- Q15 Monthly users Growth Rate (%)

SELECT
		 MONTH(subscription_date) AS months,
		 COUNT(user_id) AS current_month_users,
		 LAG(COUNT(user_id)) OVER (ORDER BY MONTH(subscription_date)) AS previous_month_users,
		 ROUND(CAST((COUNT(user_id) - LAG(COUNT(user_id)) OVER (ORDER BY MONTH(subscription_date))) * 1.0 
			/ LAG(COUNT(user_id)) OVER (ORDER BY MONTH(subscription_date)) AS FLOAT) * 100,2) AS Growth

FROM
		jotstar_db..subscribers
GROUP BY
		MONTH(subscription_date)
ORDER BY
		Growth DESC;

--Q16 Upgrade / Downgrade Rate (%)

WITH SubscriptionChanges AS 
(
    SELECT 
			user_id,
			subscription_plan AS previous_plan,
			new_subscription_plan AS current_plan
    FROM 
        jotstar_db..subscribers
)

SELECT 
		COUNT(CASE WHEN (previous_plan = 'Free' AND current_plan IN ('Basic','Premium')) OR
				(previous_plan = 'Basic' AND current_plan IN('Premium'))THEN 1 END) AS upgrade_count,
		COUNT(CASE WHEN (previous_plan = 'Premium' AND current_plan IN ('Free','Basic')) OR
				(previous_plan = 'Basic' AND current_plan IN('Free')) THEN 1 ELSE NULL END )AS downgrade_count,
		COUNT(user_id) AS total_changes,
		ROUND(CAST(COUNT(CASE WHEN (previous_plan = 'Free' AND current_plan IN ('Basic','Premium')) OR
				(previous_plan = 'Basic' AND current_plan IN('Premium'))THEN 1 END)*1.0/ COUNT(user_id)AS FLOAT) * 100,2) AS upgrade_rate,
		ROUND(CAST(COUNT(CASE WHEN (previous_plan = 'Premium' AND current_plan IN ('Free','Basic')) OR
				(previous_plan = 'Basic' AND current_plan IN('Free')) THEN 1 ELSE NULL END )*1.0/ COUNT(user_id)AS FLOAT) * 100,2) AS downgrade_rate
FROM 
		SubscriptionChanges
ORDER BY 
		upgrade_rate DESC
