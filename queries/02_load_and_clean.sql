-- hitung jumlah baris pada raw data
select COUNT(*) from raw_campaign_data rcd ;

-- preview data
select * from raw_campaign_data rcd limit 20;

-- inspeksi variasi input date
select 
    case	
        when date_raw regexp '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' then 'DD/MM/YYYY'
        when date_raw regexp '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' then 'YYYY-MM-DD'
        when date_raw regexp '^[A-Za-z]{3} [0-9]{1,2}, [0-9]{4}$' then 'Mon DD, YYYY'
        else 'UNKNOWN'
    end as date_format,
    COUNT(*) as jumlah
from raw_campaign_data
group by date_format;

-- inspeksi variasi input bulan pada format Mon DD, YYYY
select distinct LEFT(date_raw, 3) as month_abbr
from raw_campaign_data
where date_raw regexp '^[A-Za-z]{3} [0-9]{1,2}, [0-9]{4}$'
order by month_abbr;

-- inspeksi variasi input channel
select CAST(channel_raw as binary) as channel_raw, COUNT(*) as jumlah
from raw_campaign_data
group by CAST(channel_raw as binary)
order by channel_raw;

-- inspeksi variasi input campaign_name
select campaign_name_raw, COUNT(*) AS jumlah
from raw_campaign_data
group by campaign_name_raw
order by campaign_name_raw;

-- inspeksi asosiasi campaign_name dengan channel
select 
    campaign_name_raw,
    case
        when channel_raw in ('TikTok', 'tiktok ads') then 'TikTok'
        when channel_raw in ('Email', 'E-mail') then 'Email'
        when channel_raw in ('Google  Search', 'google search') then 'Google Search'
        when channel_raw in ('IG', 'Instagram', 'instagram ') then 'Instagram'
    end as channel_clean,
    COUNT(*) AS jumlah
from raw_campaign_data
group by campaign_name_raw, channel_clean
order by campaign_name_raw;

-- inspeksi kolom numerik selain spend_idr
select 
    SUM(impressions_raw is null or impressions_raw = '') as impressions_null,
    SUM(impressions_raw regexp '[^0-9-]') as impressions_non_digit,
    SUM(impressions_raw like '-%') as impressions_negatif,
    SUM(impressions_raw = '0') as impressions_nol,
    SUM(clicks_raw is null or clicks_raw = '') as clicks_null,
    SUM(clicks_raw regexp '[^0-9-]') as clicks_non_digit,
    SUM(clicks_raw like '-%') as clicks_negatif,
    SUM(clicks_raw = '0') as clicks_nol,
    SUM(signups_raw is null or signups_raw = '') as signups_null,
    SUM(signups_raw regexp '[^0-9-]') as signups_non_digit,
    SUM(signups_raw like '-%') as signups_negatif,
    SUM(signups_raw = '0') as signups_nol,
    SUM(paid_conversions_raw is null or paid_conversions_raw = '') as conversions_null,
    SUM(paid_conversions_raw regexp '[^0-9-]') as conversions_non_digit,
    SUM(paid_conversions_raw like '-%') as conversions_negatif,
    SUM(paid_conversions_raw = '0') as conversions_nol
from raw_campaign_data;

-- inspeksi nilai 0 di empat kolom
select *
from raw_campaign_data
where impressions_raw = '0' 
	or clicks_raw = '0' 
	or signups_raw = '0'
	or paid_conversions_raw = '0';

-- inspeksi nilai null di paid_conversions
select *
from raw_campaign_data
where paid_conversions_raw is null or paid_conversions_raw = '';

-- inspeksi variasi input di spend_idr
select 
    case 
        when spend_idr_raw regexp '^-?[0-9]+$' then 'angka_polos'
        when spend_idr_raw regexp '^-?[0-9]+\\.0$' then 'angka_titik_nol'
        when spend_idr_raw regexp '^Rp[0-9]{1,3}(\\.[0-9]{3})+$' then 'format_Rp_titik_ribuan'
        else 'UNKNOWN'
    end as spend_format,
    COUNT(*) as jumlah
from raw_campaign_data
group by spend_format;

-- siapkan tabel clean
CREATE TABLE clean_campaign_data (
    id INT PRIMARY KEY,
    campaign_date DATE,
    channel VARCHAR(50),
    campaign_name VARCHAR(50),
    impressions INT,
    clicks INT,
    signups INT,
    spend_idr INT,
    paid_conversions INT NULL
);

-- siapkan tabel excluded
CREATE TABLE excluded_campaign_data (
    id INT PRIMARY KEY,
    campaign_date DATE,
    channel VARCHAR(50),
    campaign_name VARCHAR(50),
    impressions INT,
    clicks INT,
    signups INT,
    spend_idr INT,
    paid_conversions INT NULL,
    exclusion_reason VARCHAR(255)
);

-- isi tabel clean
insert into clean_campaign_data 
(id, campaign_date, channel, campaign_name, impressions, clicks, signups, spend_idr, paid_conversions)
select 
    id,
    case 
        when date_raw regexp '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' then STR_TO_DATE(date_raw, '%d/%m/%Y')
        when date_raw regexp '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' then STR_TO_DATE(date_raw, '%Y-%m-%d')
        when date_raw regexp '^[A-Za-z]{3} [0-9]{1,2}, [0-9]{4}$' then STR_TO_DATE(date_raw, '%b %d, %Y')
    end,
    case
        when TRIM(LOWER(channel_raw)) in ('e-mail', 'email') then 'Email'
        when TRIM(LOWER(channel_raw)) in ('google  search', 'google search') then 'Google Search'
        when TRIM(LOWER(channel_raw)) in ('ig', 'instagram') then 'Instagram'
        when TRIM(LOWER(channel_raw)) in ('tiktok', 'tiktok ads') then 'TikTok'
    end,
    campaign_name_raw,
    CAST(impressions_raw as unsigned),
    CAST(clicks_raw as unsigned),
    CAST(signups_raw as unsigned),
    CAST(
        case
            when spend_idr_raw regexp '^-?[0-9]+$' then spend_idr_raw
            when spend_idr_raw regexp '^-?[0-9]+\\.0$' then SUBSTRING_INDEX(spend_idr_raw, '.', 1)
            when spend_idr_raw regexp '^Rp[0-9]{1,3}(\\.[0-9]{3})+$' then REPLACE(REPLACE(spend_idr_raw, 'Rp', ''), '.', '')
        end as signed
    ),
    case when paid_conversions_raw = '' then null else CAST(paid_conversions_raw as unsigned) end
from raw_campaign_data
where impressions_raw != '0';

-- isi tabel excluded
insert into excluded_campaign_data 
(id, campaign_date, channel, campaign_name, impressions, clicks, signups, spend_idr, paid_conversions, exclusion_reason)
select 
    id,
    case 
        when date_raw regexp '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' then STR_TO_DATE(date_raw, '%d/%m/%Y')
        when date_raw regexp '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' then STR_TO_DATE(date_raw, '%Y-%m-%d')
        when date_raw regexp '^[A-Za-z]{3} [0-9]{1,2}, [0-9]{4}$' then STR_TO_DATE(date_raw, '%b %d, %Y')
    end,
    case 
        when TRIM(LOWER(channel_raw)) in ('e-mail', 'email') then 'Email'
        when TRIM(LOWER(channel_raw)) in ('google  search', 'google search') then 'Google Search'
        when TRIM(LOWER(channel_raw)) in ('ig', 'instagram') then 'Instagram'
        when TRIM(LOWER(channel_raw)) in ('tiktok', 'tiktok ads') then 'TikTok'
    end,
    campaign_name_raw,
    CAST(impressions_raw as unsigned),
    CAST(clicks_raw as unsigned),
    CAST(signups_raw as unsigned),
    CAST(
        case 
            when spend_idr_raw regexp '^-?[0-9]+$' then spend_idr_raw
            when spend_idr_raw regexp '^-?[0-9]+\\.0$' then SUBSTRING_INDEX(spend_idr_raw, '.', 1)
            when spend_idr_raw regexp '^Rp[0-9]{1,3}(\\.[0-9]{3})+$' then REPLACE(REPLACE(spend_idr_raw, 'Rp', ''), '.', '')
        end as signed
    ),
    case when paid_conversions_raw = '' then null else CAST(paid_conversions_raw as unsigned) end,
    'Zero activity across all metrics with negative spend — likely refund/adjustment row'
from raw_campaign_data
where impressions_raw = '0';