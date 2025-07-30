with
    aggregated as (
        -- EC2 instances with a public IP
        ({{ instances_reachable_with_public_ip() }})
        -- Lambda functions with public access
            {{ union() }}
        ({{ lambda_functions_with_public_access() }})
        -- RDS instances with public access
            {{ union() }}
        ({{ rds_instances_reachable_with_public_ip() }})
        -- ALBs with public access
            {{ union() }}
        ({{ public_facing_elbv2() }})
        -- Kubernetes services that back public ALBs
            {{ union () }}
        ({{ kubernetes_resources_backing_albs() }})
        -- Kubernetes services reachable from API gateway
            {{ union() }}
        ({{ kubernetes_resources_reachable_from_api_gateway() }})
)
select
    {{ gen_timestamp() }},
    aggregated.*
from aggregated
