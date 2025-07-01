with
    aggregated as (
        ({{ aws_inventory_by_vpc() }})
    )
select * from aggregated
