# Q2 2026 Marketing Campaign Effectiveness Analysis

**[View Interactive Dashboard on Tableau Public →](https://public.tableau.com/app/profile/nada.sholihah/viz/Q22026MarketingCampaignEffectiveness/MarketingCampaignAnalysis)**

## Background

The marketing team spent a significant budget on Q2 2026 campaigns across TikTok, Instagram, Google Search, and Email, and needed to know which channels were actually worth the investment ahead of a board presentation. This project cleans and analyzes the raw campaign data to answer that question.

## Key Findings

- **TikTok** has the highest CPA (>2x other channels), but also delivers >2x the reach of other channels at a relatively low CPM — better suited for awareness than direct conversion goals.
- **Funnel drop-off is fairly consistent** across channels, except at the signup→conversion stage — this is where channel performance actually diverges.
- **Email** outperforms on nearly every efficiency metric, but has by far the smallest reach.
- **Takeaway:** channel choice depends on objective — TikTok for awareness, Email for high-efficiency low-volume conversion, and a stronger mid-funnel strategy is needed for high-volume channels to convert their reach more effectively.

## Process

1. **Data cleaning** — Raw CSV loaded into a staging table with loose types to avoid silent data loss, then inspected for inconsistent date formats, channel name variants, and malformed spend values before converting into a clean, typed table.
2. **Anomaly handling** — Rows with all-zero activity and negative spend were separated into an `excluded_campaign_data` table with documented reasons, rather than deleted outright.
3. **Analysis** — Computed CPA, CPM/CPC, and funnel conversion rates per channel using SQL aggregation (ratio-of-sums, not average-of-ratios, to avoid skewed results).
4. **Visualization** — Built an interactive dashboard in Tableau Public with weekly trend lines, funnel breakdown, and channel efficiency comparisons.

## Data Quality Notes

- 3 rows had zero impressions/clicks/signups/conversions paired with negative spend — likely refund/adjustment entries, excluded from all effectiveness calculations.
- 10 rows had missing (`NULL`) conversion data despite healthy impressions/clicks/signups — excluded specifically from CPA and funnel conversion-rate calculations to avoid inflating cost-per-acquisition, but retained for CPM/reach-based metrics where they remain valid.
- Channel names appeared in up to 12 raw text variants (casing, spacing, abbreviations) and were standardized into 4 canonical channels.

## Tools

SQL (MySQL), Tableau Public
