with
    aggregated as (
        ({{ full_asset_inventory() }})
    )
select * from aggregated
