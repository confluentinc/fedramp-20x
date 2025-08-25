with aggregated as (
    ({{ security_groups_attached_to_ec2_instances() }})
    {{ union() }}
    ({{ security_groups_attached_to_rds_instances() }})
    {{ union() }}
    ({{ security_groups_attached_to_elbv2_load_balancers() }})
)
select * from aggregated
