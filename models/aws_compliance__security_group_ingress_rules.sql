with
    aggregated as (
        ({{ security_group_ingress_rules() }})
    )
select * from aggregated
