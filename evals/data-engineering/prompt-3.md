This query runs twice a day and costs about R$4k/month:

```sql
SELECT *
FROM `demo-social-analytics.raw.social_posts`
WHERE published_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
ORDER BY impressions DESC
LIMIT 500
```

A dry run on 2026-11-20 reported 3.1 TB billed per run. Make it cheap and show the arithmetic that gets the monthly bill down.
