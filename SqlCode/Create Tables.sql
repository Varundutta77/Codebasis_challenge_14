CREATE TABLE content_consumption (
    user_id VARCHAR(30) NOT NULL,
    device_type VARCHAR(20) NULL,
    total_watch_time_mins INT NULL,
    CONSTRAINT PK_content_consumption PRIMARY KEY (user_id),
    CONSTRAINT FK_content_consumption_subscribers FOREIGN KEY (user_id) REFERENCES subscribers (user_id),
    CONSTRAINT CHK_device_type CHECK (device_type IN ('Mobile', 'TV', 'Laptop')),
    CONSTRAINT CHK_total_watch_time_mins CHECK (total_watch_time_mins > 0)
);


CREATE TABLE subscribers (
    user_id VARCHAR(30) NOT NULL,
    age_group VARCHAR(20) NULL,
    city_tier VARCHAR(20) NULL,
    subscription_date DATE NOT NULL,
    subscription_plan VARCHAR(20) NULL,
    last_active_date DATE NULL,
    plan_change_date DATE NULL,
    new_subscription_plan VARCHAR(20) NULL,
    PRIMARY KEY (user_id),
    CONSTRAINT subscribers_chk_1 CHECK (age_group IN ('18-24', '25-34', '35-44', '45+')),
    CONSTRAINT subscribers_chk_2 CHECK (city_tier IN ('Tier 1', 'Tier 2', 'Tier 3')),
    CONSTRAINT subscribers_chk_3 CHECK (subscription_plan IN ('Free', 'VIP', 'Premium')),
    CONSTRAINT subscribers_chk_4 CHECK (new_subscription_plan IN ('VIP', 'Premium', 'Free'))
);

CREATE TABLE contents (
    content_id VARCHAR(30) NOT NULL,
    content_type VARCHAR(20) NULL,
    language VARCHAR(50) NULL,
    genre VARCHAR(50) NULL,
    run_time INT NULL,
    PRIMARY KEY (content_id),
    CONSTRAINT contents_chk_1 CHECK (content_type IN ('Movie', 'Series', 'Sports')),
    CONSTRAINT contents_chk_2 CHECK (run_time > 0)
);

