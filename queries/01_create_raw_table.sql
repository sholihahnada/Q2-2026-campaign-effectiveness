CREATE TABLE raw_campaign_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
	date_raw VARCHAR(50),
    channel_raw VARCHAR(50),
    campaign_name_raw VARCHAR(50),
    impressions_raw VARCHAR(50),
    clicks_raw VARCHAR(50),
    signups_raw VARCHAR(50),
    spend_idr_raw VARCHAR(50),
    paid_conversions_raw VARCHAR(50)
);