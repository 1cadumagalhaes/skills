{{ config(materialized='view') }}

select
    cast(post_id as string) as post_id,
    cast(account_id as string) as account_id,
    cast(published_at as timestamp) as published_at,
    cast(impressions as int64) as impressions,
    cast(likes as int64) as likes,
    cast(shares as int64) as shares,
    ingested_at
from {{ source('raw', 'social_posts') }}
where published_at >= timestamp_sub(current_timestamp(), interval 90 day)
qualify row_number() over (partition by post_id, date(published_at) order by ingested_at desc) = 1
