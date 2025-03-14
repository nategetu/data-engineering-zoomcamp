{{ config(materialized="table") }}

with
    monthly_stats as (
        select
            service_type,
            extract(year from pickup_datetime) as pickup_year,
            extract(month from pickup_datetime) as pickup_month,
            fare_amount
        from {{ ref("fact_trips") }}
        where
            extract(year from pickup_datetime) between 2019 and 2020
            and fare_amount > 0
            and trip_distance > 0
            and payment_type_description in ('Cash', 'Credit card')
    )
select distinct
    service_type,
    pickup_year,
    pickup_month,
    percentile_cont(fare_amount, 0.97) over (
        partition by service_type, pickup_year, pickup_month
    ) p97,
    percentile_cont(fare_amount, 0.95) over (
        partition by service_type, pickup_year, pickup_month
    ) p95,
    percentile_cont(fare_amount, 0.90) over (
        partition by service_type, pickup_year, pickup_month
    ) p90,

from monthly_stats
order by service_type, pickup_year, pickup_month
