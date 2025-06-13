with
    aggregated as (

        -- KSI-SVC-02: Encrypt or otherwise secure network traffic
        {{ alb_should_have_acceptable_tls_policy('KSI-SVC-02', '1.0')}}
            {{ union() }}
        {{ alb_should_redirect_plaintext_ports('KSI-SVC-02', '1.1')}}
            {{ union() }}
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
            {{ union() }}

        -- KSI-CMT-02: Execute changes though redeployment of version controlled immutable resources rather than direct modification wherever possible
({{ k8s_images_should_use_immutable_registry('KSI-CMT-02', '1.0')}})
{{ union() }}
({{ aws_resources_should_be_managed_by_iac('KSI-CMT-02', '1.1') }})
    )
select
    {{ gen_timestamp() }},
    aggregated.*
from aggregated