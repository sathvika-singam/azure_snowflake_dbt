{{ config(materialized='table') }}

select * from AIRBNB.staging.listings
