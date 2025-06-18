with
    aggregated as (
    ({{ networks_acls_egress_rules() }})
    )
select * from aggregated
