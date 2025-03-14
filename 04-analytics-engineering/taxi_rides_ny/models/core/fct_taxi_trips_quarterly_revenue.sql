{{ config(materialized="table") }}

with
    quarter_stats as (
        select
            service_type,
            extract(year from pickup_datetime) as pickup_year,
            extract(quarter from pickup_datetime) as pickup_quarter,
            sum(total_amount) as quarterly_revenue
        from {{ ref("fact_trips") }}
        where extract(year from pickup_datetime) between 2019 and 2020
        group by 1, 2, 3
    )
select
    service_type,
    pickup_year,
    pickup_quarter,
    quarterly_revenue,
    safe_divide(
        quarterly_revenue,
        lag(quarterly_revenue, 1, 0) over (
            partition by pickup_quarter, service_type order by pickup_year
        )
    )
    - 1 as quarterly_yoy_growth
from quarter_stats
order by service_type, pickup_year, pickup_quarter
