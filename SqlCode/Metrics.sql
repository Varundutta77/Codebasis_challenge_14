-- Q1 Total Content Items

SELECT 
		COUNT(DISTINCT(content_id)) AS total_contents
FROM
		liocinema_db..contents

-- Q2 Total Users

SELECT
		COUNT(DISTINCT(user_id)) AS total_users
FROM
		liocinema_db..content_consumption

-- Q3 Paid Users

SELECT
		COUNT(DISTINCT(user_id)) AS paid_users
FROM
		liocinema_db..subscribers

-- Q4 Paid Users %

WITH Paidusers AS (
		SELECT
				COUNT(DISTINCT(s.user_id)) AS paid_users
		FROM
				liocinema_db..subscribers s
),
Totalusers AS (
		SELECT
				COUNT(DISTINCT(c.user_id)) AS total_users
		FROM
				liocinema_db..content_consumption c
)

SELECT 
		p.paid_users,
		t.total_users,
		ROUND(CAST((p.paid_users *1.0 / t.total_users)AS FLOAT)*100,2) AS "Paid User %"
FROM
		Paidusers p,
		Totalusers t

-- Q5 Active Users

SELECT
		COUNT(user_id) AS Active_users
FROM		
		liocinema_db..subscribers 
WHERE
		new_subscription_plan IS NOT NULL

-- Q6 Inactive Users

SELECT
		COUNT(user_id) AS Inactive_users
FROM		
		liocinema_db..subscribers 
WHERE
		new_subscription_plan IS NULL
-- Q7 Inactive Rate %

WITH Activeusers AS (
    SELECT
        COUNT(user_id) AS Active_users
    FROM
        liocinema_db..subscribers 
    WHERE
        new_subscription_plan IS NOT NULL
),
Inactiveusers AS (
    SELECT
        COUNT(user_id) AS Inactive_users
    FROM
        liocinema_db..subscribers 
    WHERE
        new_subscription_plan IS NULL
)

SELECT 
    Active_users,
    Inactive_users,
    (Inactive_users * 1.0 / (Active_users + Inactive_users)) * 100 AS "Active Rate %"
FROM
    Activeusers ,
    Inactiveusers

-- Q8 Active Rate %

WITH Activeusers AS (
    SELECT
        COUNT(user_id) AS Active_users
    FROM
		liocinema_db..subscribers 
    WHERE
		 new_subscription_plan IS NOT NULL
),
Inactiveusers AS (
    SELECT
			COUNT(user_id) AS Inactive_users
    FROM
			liocinema_db..subscribers 
    WHERE
		 new_subscription_plan IS NULL
)

SELECT 
		Active_users,
		Inactive_users,
		(Active_users * 1.0 / (Active_users + Inactive_users)) * 100 AS "Active Rate %"
FROM
		Activeusers ,
		Inactiveusers

-- Q9 Upgraded users

SELECT 
		subscription_plan AS previous_plan,
		new_subscription_plan AS current_plan,
		COUNT(user_id) AS upgrade
FROM 
		liocinema_db..subscribers
WHERE
		new_subscription_plan IS NOT NULL
		AND (
			(subscription_plan = 'Free' AND new_subscription_plan IN ('Basic','Premium')) OR
			(subscription_plan = 'Basic' AND new_subscription_plan IN ('Premium'))
		)
GROUP BY 
		subscription_plan, new_subscription_plan
ORDER BY 
		upgrade DESC;

-- Q10 Upgrade Rate (%)

SELECT 
			COUNT(CASE WHEN (subscription_plan = 'Free' AND new_subscription_plan IN ('Basic','Premium')) OR
				(subscription_plan = 'Basic' AND new_subscription_plan IN ('Premium')) THEN 1 ELSE NULL END) AS upgrade_users,
			COUNT(user_id) AS total_users,
			ROUND(CAST(COUNT(CASE WHEN (subscription_plan = 'Free' AND new_subscription_plan IN ('Basic','Premium')) OR
				 (subscription_plan = 'Basic' AND new_subscription_plan IN ('Premium')) THEN 1 ELSE NULL END) AS FLOAT) / COUNT(user_id) * 100,2) AS 'upgrade_rate_%'
FROM 
		liocinema_db..subscribers
WHERE
		new_subscription_plan IS NOT NULL;

-- Q11 Downgraded users

SELECT 
		subscription_plan AS previous_plan,
		new_subscription_plan AS current_plan,
		COUNT(user_id) AS downgrade
FROM 
		liocinema_db..subscribers
WHERE
		new_subscription_plan IS NOT NULL
		AND (
			(subscription_plan = 'Premium' AND new_subscription_plan IN ('Free','Basic')) OR
			(subscription_plan = 'Basic' AND new_subscription_plan IN ('Free'))
		)
GROUP BY 
		subscription_plan, new_subscription_plan
ORDER BY 
		downgrade DESC;

-- Q12 Downgrade Rate (%)

SELECT 
		COUNT(CASE WHEN (subscription_plan = 'Premium' AND new_subscription_plan IN ('Free','Basic')) OR
             (subscription_plan = 'Basic' AND new_subscription_plan IN ('Free')) THEN 1 ELSE NULL END) AS downgrade_users,
		COUNT(user_id) AS total_users,
		ROUND(CAST(COUNT(CASE WHEN (subscription_plan = 'Premium' AND new_subscription_plan IN ('Free','Basic')) OR
             (subscription_plan = 'Basic' AND new_subscription_plan IN ('Free')) THEN 1 ELSE NULL END) AS FLOAT) / COUNT(user_id) * 100,2) AS 'downgrade_rate_%'
FROM 
		liocinema_db..subscribers
WHERE
		new_subscription_plan IS NOT NULL;

-- Q13 Total watch time (hrs)

SELECT
		SUM(total_watch_time_mins)/60 AS total_watch_time_hrs
FROM
		liocinema_db..content_consumption

-- Q14 Average watch time (hrs)

SELECT
		ROUND(CAST(AVG(total_watch_time_mins)AS FLOAT) / 60,2) AS average_watch_time_hrs
FROM
		liocinema_db..content_consumption ;

-- Q15 Monthly users Growth Rate (%)

SELECT
		MONTH(subscription_date) AS months,
		COUNT(user_id) AS current_month_users,
		LAG(COUNT(user_id)) OVER (ORDER BY MONTH(subscription_date)) AS previous_month_users,
		ROUND(CAST((COUNT(user_id) - LAG(COUNT(user_id)) OVER (ORDER BY MONTH(subscription_date))) * 1.0 
			/ LAG(COUNT(user_id)) OVER (ORDER BY MONTH(subscription_date)) AS FLOAT) * 100,2) AS Growth
FROM
		liocinema_db..subscribers
GROUP BY
		MONTH(subscription_date)
ORDER BY
		Growth DESC

-- Q16

WITH SubscriptionChanges AS 
(
    SELECT 
			user_id,
			subscription_plan AS previous_plan,
			new_subscription_plan AS current_plan
    FROM 
        liocinema_db..subscribers
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
