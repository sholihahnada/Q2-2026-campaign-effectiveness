-- 1. efisiensi konversi per channel (CPA)
-- paid conversion null dikecualikan
select 
    channel,
    COUNT(*) as jumlah_campaign,
    SUM(spend_idr) as total_spend,
    SUM(paid_conversions) as total_conversions,
    ROUND(SUM(spend_idr) / SUM(paid_conversions), 0) as cpa_idr
from clean_campaign_data
where paid_conversions is not null 
group by channel
order by cpa_idr asc;

-- 2. efisiensi reach per channel (CPM, CPC)
-- CPA saja tidak fair untuk channel dengan objective awareness
-- paid conversion null tidak dikecualikan karena tidak menghitung conversions
select 
    channel,
    SUM(spend_idr) as total_spend,
    SUM(impressions) as total_impressions,
    SUM(clicks) as total_clicks,
    ROUND(SUM(spend_idr) / SUM(impressions) * 1000, 0) as cpm_idr,
    ROUND(SUM(spend_idr) / SUM(clicks), 0) as cpc_idr
from clean_campaign_data
group by channel
order by cpm_idr asc;

-- 3. funnel rate per channel (CTR, signup rate, conversion rate)
select 
    channel,
    ROUND(SUM(clicks) / SUM(impressions) * 100, 2) as ctr_percent,
    ROUND(SUM(signups) / SUM(clicks) * 100, 2) as signup_rate_percent,
    ROUND(SUM(paid_conversions) / SUM(signups) * 100, 2) as conversion_rate_percent
from clean_campaign_data
where paid_conversions is not null 
group by channel;

-- 4. data mentah harian untuk visualisasi tren
-- agregasi CPA/CPM dilakukan di Tableau (bukan di sini)
select 
    channel,
    campaign_date,
    impressions,
    clicks,
    signups,
    paid_conversions,
    spend_idr
from clean_campaign_data
order by channel, campaign_date;