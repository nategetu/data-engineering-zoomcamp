{{ config(materialized="table") }}

with
    trip_seconds as (
        select
            year,
            month,
            pickup_locationid,
            dropoff_locationid,
            pickup_zone,
            dropoff_zone,
            timestamp_diff(dropoff_datetime, pickup_datetime, second) trip_duration
        from {{ ref("dim_fhv_trips") }}
        where year between 2019 and 2020
    )
select distinct
    year,
    month,
    pickup_locationid,
    dropoff_locationid,
    pickup_zone,
    dropoff_zone,
    percentile_cont(trip_duration, 0.90) over (
        partition by
            year,
            month,
            pickup_locationid,
            dropoff_locationid,
    ) p90
from trip_seconds
order by year, month, p90
