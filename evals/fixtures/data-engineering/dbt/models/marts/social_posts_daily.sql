{{ config(materialized='table', partition_by={'field': 'published_date', 'data_type': 'date'}) }}

select
    date(published_at) as published_date,
    account_id,
    count(distinct post_id) as posts,
    sum(impressions) as impressions,
    sum(likes) as likes,
    sum(shares) as shares,
    safe_divide(sum(likes) + sum(shares), nullif(sum(impressions), 0)) as engagement_rate
from {{ ref('stg_social_posts') }}
group by published_date, account_id
