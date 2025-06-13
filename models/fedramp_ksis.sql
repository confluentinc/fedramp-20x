with
    aggregated as (
        -- KSI-SVC-03: Encrypt all federal and sensitive information at rest
        ({{ ebs_volumes_should_be_encrypted_at_rest('KSI_SC', '1.0') }})
            {{ union() }}
        ({{ rds_clusters_should_be_encrypted_at_rest('KSI_SC', '1.1') }})
            {{ union() }}
        ({{ s3_buckets_should_be_encrypted_at_rest('KSI_SC', '1.2') }})
            {{ union() }}
        ({{ elasticache_clusters_should_be_encrypted_at_rest('KSI_SC', '1.3') }})
            {{ union() }}
        ({{ elasticache_replication_groups_should_be_encrypted_at_rest('KSI_SC', '1.4') }})
    )
select
    {{ gen_timestamp() }},
    aggregated.*
from aggregated