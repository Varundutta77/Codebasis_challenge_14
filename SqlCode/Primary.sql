-- Q1 Total Users & Growth Trends
	--- What is the total number of users for LioCinema and Jotstar, and how do they compare in terms of growth trends (January–November 2024)?

SELECT
    jot.jotstar_users,
    jot.current_month AS jotstar_month,
    jot.previous_month_users AS jotstar_previous_month,
    jot.growth AS jotstar_growth,
    lio.liocinema_users,
    lio.current_month AS liocinema_month,
    lio.previous_month_users AS liocinema_previous_month,
    lio.growth AS liocinema_growth
FROM
    (
        SELECT 
            COUNT(DISTINCT user_id) AS jotstar_users,
            MONTH(subscription_date) AS current_month,
            LAG(COUNT(DISTINCT user_id)) OVER (ORDER BY MONTH(subscription_date)) AS previous_month_users,
            ROUND(CAST((COUNT(DISTINCT user_id) - LAG(COUNT(DISTINCT user_id)) OVER (ORDER BY MONTH(subscription_date))) * 1.0 /
                  LAG(COUNT(DISTINCT user_id)) OVER (ORDER BY MONTH(subscription_date)) AS FLOAT) * 100, 2) AS growth
        FROM jotstar_db..subscribers
        GROUP BY MONTH(subscription_date)
    ) AS jot
    LEFT JOIN (
        SELECT 
            COUNT(DISTINCT user_id) AS liocinema_users,
            MONTH(subscription_date) AS current_month,
            LAG(COUNT(DISTINCT user_id)) OVER (ORDER BY MONTH(subscription_date)) AS previous_month_users,
            ROUND(CAST((COUNT(DISTINCT user_id) - LAG(COUNT(DISTINCT user_id)) OVER (ORDER BY MONTH(subscription_date))) * 1.0 /
                   LAG(COUNT(DISTINCT user_id)) OVER (ORDER BY MONTH(subscription_date)) AS FLOAT) * 100, 2) AS growth
        FROM liocinema_db..subscribers
        GROUP BY MONTH(subscription_date)
    ) AS lio ON jot.current_month = lio.current_month

-- Q2 Content Library Comparison
	-- What is the total number of contents available on LioCinema vs. Jotstar? How do they differ in terms of language and content type?

SELECT
    'Total Content' AS metrics,
    (SELECT COUNT(content_id) FROM liocinema_db..contents) AS liocinema_total,
    (SELECT COUNT(content_id) FROM jotstar_db..contents) AS jotstar_total

UNION ALL

SELECT
    'Total Languages' AS metrics,
    (SELECT COUNT(DISTINCT language) FROM liocinema_db..contents) AS liocinema_total,
    (SELECT COUNT(DISTINCT language) FROM jotstar_db..contents) AS jotstar_total

UNION ALL

SELECT
    'Total Content Types' AS metrics,
    (SELECT COUNT(DISTINCT content_type) FROM liocinema_db..contents) AS liocinema_total,
    (SELECT COUNT(DISTINCT content_type) FROM jotstar_db..contents) AS jotstar_total;


-- Q3 User Demographics
--    What is the distribution of users by age group, city tier, and subscription plan for each platform?

SELECT
		age_group,
		city_tier,
		subscription_plan,
		COUNT(DISTINCT CASE WHEN platform = 'LioCinema' THEN user_id END) AS liocinema_users,
		COUNT(DISTINCT CASE WHEN platform = 'Jotstar' THEN user_id END) AS jotstar_users
FROM (
    SELECT
			'LioCinema' AS platform,
			age_group,
			city_tier,
			subscription_plan,
			user_id
    FROM 
			liocinema_db..subscribers

    UNION ALL

    SELECT
			'Jotstar' AS platform,
			age_group,
			city_tier,
			subscription_plan,
			user_id
    FROM 
		jotstar_db..subscribers
) AS combined
GROUP BY
		age_group,
		city_tier,
		subscription_plan
ORDER BY
		age_group, 
		city_tier, 
		subscription_plan;

-- Q4 Active vs. Inactive Users
 -- What percentage of LioCinema and Jotstar users are active vs. inactive? How do these rates vary by age group and subscription plan?
SELECT 
		age_group AS age,
		subscription_plan AS Plans,
		COUNT(CASE WHEN platform = 'Liocinema' AND new_subscription_plan IS NOT NULL THEN user_id END) AS active_users_liocinema,
		COUNT(CASE WHEN platform = 'Liocinema' AND new_subscription_plan IS NULL THEN user_id END) AS Inactive_users_liocinema,
		COUNT(CASE WHEN platform = 'Liocinema' THEN user_id END) AS total_liocinema_users,
		ROUND(CAST(COUNT(CASE WHEN platform = 'Liocinema' AND new_subscription_plan IS NOT NULL THEN user_id END)*1.0 AS FLOAT)/NULLIF(COUNT(CASE WHEN platform = 'Liocinema' THEN user_id END),0)*100,2) AS 'Active users liocinema %' ,
		ROUND(CAST(COUNT(CASE WHEN platform = 'Liocinema' AND new_subscription_plan IS NULL THEN user_id END)*1.0 AS FLOAT)/NULLIF(COUNT(CASE WHEN platform = 'Liocinema' THEN user_id END),0) *100,2) AS 'InActive users liocinema %',
		COUNT(CASE WHEN platform = 'Jotstar' AND new_subscription_plan IS NOT NULL THEN user_id END) AS active_users_jotstar,
		COUNT(CASE WHEN platform = 'Jotstar' AND new_subscription_plan IS NULL THEN user_id END) AS Inactive_users_jotstar,
		COUNT(CASE WHEN platform = 'Jotstar' THEN user_id END) AS jotstar_users,
		ROUND(CAST(COUNT(CASE WHEN platform = 'Jotstar' AND new_subscription_plan IS NOT NULL THEN user_id END)*1.0 AS FLOAT)/NULLIF(COUNT(CASE WHEN platform = 'Jotstar' THEN user_id END),0)*100,2) AS 'Active users jotstar %',
		ROUND(CAST(COUNT(CASE WHEN platform = 'Jotstar'AND new_subscription_plan IS NULL THEN user_id END)*1.0 AS FLOAT)/NULLIF(COUNT(CASE WHEN platform = 'Jotstar' THEN user_id END),0) *100,2) AS 'InActive users jotstar %'

FROM
	(
		SELECT
				'Liocinema' AS platform,
				age_group,
				subscription_plan,
				new_subscription_plan,
				user_id
		FROM
				liocinema_db..subscribers

		UNION ALL

		SELECT
				'Jotstar' AS platform,
				age_group,
				subscription_plan,
				new_subscription_plan,
				user_id
		FROM
				jotstar_db..subscribers
) AS combined
GROUP BY
		age_group,
		subscription_plan
ORDER BY
		Plans,age

-- Q5 Watch Time Analysis
   --What is the average watch time for LioCinema vs. Jotstar during the analysis period? How do these compare by city tier and device type? 
SELECT
	device_type,
	city_tier,
	MAX(CASE WHEN platform = 'liocinema' THEN average_watch_time END) AS average_watch_time_liocinema,
	MAX(CASE WHEN platform = 'jotstar' THEN average_watch_time END) AS average_watch_time_jotstar
FROM
(
	SELECT
			'liocinema' AS platform,
			device_type,
			city_tier,
			AVG(total_watch_time_mins)/60 AS average_watch_time
	FROM	
			liocinema_db..content_consumption c
	JOIN
			liocinema_db..subscribers s ON c.user_id = s.user_id
	GROUP BY
			city_tier,
			device_type
	UNION ALL
	SELECT
			'jotstar' AS platform,
			device_type,
			city_tier,
			AVG(total_watch_time_mins)/60 AS average_watch_time
	FROM	
			jotstar_db..content_consumption c
	JOIN
			jotstar_db..subscribers s ON c.user_id = s.user_id
	GROUP BY
			city_tier,
			device_type
) AS combined

GROUP BY
		device_type,
		city_tier

-- Q6. Inactivity Correlation
	--How do inactivity patterns correlate with total watch time or average watch time? Are less engaged users more likely to become inactive?
SELECT
		user_id,
		SUM(total_watch_time_mins) AS total_watch_time,
		AVG(total_watch_time_mins) AS avg_watch_time,
			CASE 
				WHEN SUM(total_watch_time_mins) = 0 THEN 'Inactive'
				WHEN AVG(total_watch_time_mins) < 5 THEN 'Low Engagement'
				ELSE 'Active'
			END AS user_status
FROM
		jotstar_db..content_consumption
GROUP BY 
		user_id

-- Q7. Downgrade Trends
  -- How do downgrade trends differ between LioCinema and Jotstar? Are downgrades more prevalent on one platform compared to the other?
  SELECT 
		platform,
		MONTH(plan_change_date) AS 'month',
		COUNT(CASE WHEN (subscription_plan = 'Premium' AND new_subscription_plan IN ('Free','Basic')) OR
             (subscription_plan = 'Basic' AND new_subscription_plan IN ('Free')) THEN 1 ELSE NULL END) AS downgrade_users,
		COUNT(user_id) AS total_users,
		ROUND(CAST(COUNT(CASE WHEN (subscription_plan = 'Premium' AND new_subscription_plan IN ('Free','Basic')) OR
             (subscription_plan = 'Basic' AND new_subscription_plan IN ('Free')) THEN 1 ELSE NULL END) AS FLOAT) / COUNT(user_id) * 100,2) AS 'downgrade_rate_%'
FROM 
	(
	SELECT
		'liocinema' AS platform,
		user_id,
		new_subscription_plan,
		subscription_plan,
		plan_change_date
	FROM
	     liocinema_db..subscribers
	WHERE 
		new_subscription_plan IS NOT NULL

	UNION ALL	
	SELECT
		'jotstar' AS platform,
		user_id,
		new_subscription_plan,
		subscription_plan,
		plan_change_date
	FROM
	     jotstar_db..subscribers
	WHERE 
		new_subscription_plan IS NOT NULL
) AS combined_date

GROUP BY
		platform,
		MONTH(plan_change_date)
ORDER BY
		[downgrade_rate_%] DESC

-- Q8 Upgrade Patterns
	-- What are the most common upgrade transitions (e.g., Free to Basic, Free to VIP, Free to Premium) for LioCinema and Jotstar? How do these differ across platforms?
SELECT 
		MONTH(plan_change_date) AS 'month',
		COUNT(CASE WHEN (platform = 'liocinema' AND subscription_plan = 'Free' AND new_subscription_plan ='Basic') THEN 1 ELSE NULL END) AS 'liocinema Free to Basic',
		COUNT(CASE WHEN (platform = 'jotstar' AND subscription_plan = 'Free' AND new_subscription_plan ='Basic') THEN 1 ELSE NULL END) AS 'jotstar Free to Basic',
		COUNT(CASE WHEN (platform = 'liocinema' AND subscription_plan = 'Free' AND new_subscription_plan = 'VIP')THEN 1 ELSE NULL END ) AS 'liocinema Free to Premium',
		COUNT(CASE WHEN (platform ='jotstar' AND subscription_plan = 'Free' AND new_subscription_plan = 'VIP') THEN 1 ELSE NULL END) AS 'jotstar Free to VIP',
		COUNT(CASE WHEN (platform = 'liocinema' AND subscription_plan = 'Free' AND new_subscription_plan ='Premium') THEN 1 ELSE NULL END) AS 'Free to Premium',
		COUNT(CASE WHEN (platform = 'jotstar' AND subscription_plan = 'Free' AND new_subscription_plan ='Premium') THEN 1 ELSE NULL END) AS 'Free to Premium'
FROM 
	(
		SELECT		
				'liocinema' AS platform,
				user_id,
				subscription_plan,
				new_subscription_plan,
				plan_change_date
		FROM
				liocinema_db..subscribers
		WHERE 
				new_subscription_plan IS NOT NULL

		UNION ALL

		SELECT		
				'Jotstar' AS platform,
				user_id,
				subscription_plan,
				new_subscription_plan,
				plan_change_date
		FROM
				jotstar_db..subscribers
		WHERE 
				new_subscription_plan IS NOT NULL
) AS combined_date

GROUP BY
		MONTH(plan_change_date)
ORDER BY
		MONTH(plan_change_date) ASC
		
-- 9. Paid Users Distribution
  -- How does the paid user percentage (e.g., Basic, Premium for LioCinema; VIP, Premium for Jotstar) vary across different platforms? Analyse the proportion of premium users in Tier 1, Tier 2, and Tier 3 cities and identify any notable trends or differences.
SELECT
		city,
		month(plan_change_date) AS 'month',
		COUNT(CASE WHEN platform = 'liocinema' AND new_subscription_plan IN ('Basic','Premium') THEN 1 ELSE NULL END) AS 'liocinema paid users',
		ROUND(CAST(COUNT(CASE WHEN platform = 'liocinema' AND new_subscription_plan IN ('Basic','Premium') THEN 1 ELSE NULL END)AS FLOAT) *1.0/COUNT(user_id)*100,2) AS 'liocinem paid_user %',
		COUNT(CASE WHEN platform = 'jotstar' AND new_subscription_plan IN ('Basic','Premium') THEN 1 ELSE NULL END) AS 'jotstar paid users',
		ROUND(CAST(COUNT(CASE WHEN platform = 'jotstar' AND new_subscription_plan IN ('Basic','Premium') THEN 1 ELSE NULL END)AS FLOAT) *1.0 /COUNT(user_id)*100,2) AS 'jotstar paid_users %'
		
FROM
(
	SELECT		
			'liocinema' AS platform,
			city_tier AS city,
			user_id,
			new_subscription_plan,
			plan_change_date
	FROM
			liocinema_db..subscribers 

	UNION ALL

	SELECT		
			'jotstar' AS platform,
			city_tier AS city,
			user_id,
			new_subscription_plan,
			plan_change_date
	FROM
			jotstar_db..subscribers 
) AS Combined_date

WHERE
		MONTH(plan_change_date) IS NOT NULL
GROUP BY
		city,
		MONTH(plan_change_date)
ORDER BY
		MONTH(plan_change_date)

-- Q10 Revenue Analysis
-- Assume the following monthly subscription prices, calculate the total revenue generated by both platforms (LioCinema and Jotstar) for the analysis period (January to November 2024).
--		The calculation should consider:
--		Subscribers count under each plan.
--		Active duration of subscribers on their respective plans.
--		Upgrades and downgrades during the period, ensuring revenue reflects the time spent under each plan.

SELECT
    MONTH(plan_change_date) AS 'Month',
    platform,
    COUNT(CASE WHEN platform = 'liocinema' AND new_subscription_plan = 'Basic' THEN user_id END) AS basic_subscribers_count_liocinema,
    COUNT(CASE WHEN platform = 'liocinema' AND new_subscription_plan = 'Premium' THEN user_id END) AS premium_subscribers_count_liocinema,
    COUNT(CASE WHEN platform = 'jotstar' AND new_subscription_plan = 'VIP' THEN user_id END) AS VIP_subscribers_count_jotstar,
    COUNT(CASE WHEN platform = 'jotstar' AND new_subscription_plan = 'Premium' THEN user_id END) AS premium_subscribers_count_jotstar,
    SUM(CASE WHEN platform = 'liocinema' AND new_subscription_plan = 'Basic' THEN 69 * DATEDIFF(MONTH, subscription_date, plan_change_date) ELSE 0 END) AS liocinema_basic_revenue,
    SUM(CASE WHEN platform = 'liocinema' AND new_subscription_plan = 'Premium' THEN 129 * DATEDIFF(MONTH, subscription_date, plan_change_date) ELSE 0 END) AS liocinema_premium_revenue,
	SUM(CASE WHEN platform = 'jotstar' AND new_subscription_plan = 'VIP' THEN 159 * DATEDIFF(MONTH, subscription_date, last_active_date) ELSE 0 END) AS jotstar_vip_revenue,
	SUM(CASE WHEN platform = 'jotstar' AND new_subscription_plan = 'Premium' THEN 359 * DATEDIFF(MONTH, subscription_date, last_active_date) ELSE 0 END) AS jotstar_premium_revenue

FROM (
    
    SELECT
        'liocinema' AS platform,
        user_id,
        new_subscription_plan,
        plan_change_date,
        subscription_date,
        last_active_date,
        DATEDIFF(MONTH, subscription_date, last_active_date) AS active_months
    FROM liocinema_db..subscribers
    
    UNION ALL
    
    SELECT
        'jotstar' AS platform,
        user_id,
        new_subscription_plan,
        plan_change_date,
        subscription_date,
        last_active_date,
        DATEDIFF(MONTH, subscription_date, last_active_date) AS active_months
    FROM jotstar_db..subscribers
) AS combined_data
WHERE MONTH(plan_change_date) BETWEEN 1 AND 11
GROUP BY
    MONTH(plan_change_date), platform
ORDER BY
    MONTH(plan_change_date);
