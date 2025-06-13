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
        ({{ rds_instances_should_be_encrypted_at_rest('KSI_SC', '1.1') }})
            {{ union() }}
        ({{ s3_buckets_should_be_encrypted_at_rest('KSI_SC', '1.2') }})
            {{ union() }}
        ({{ elasticache_clusters_should_be_encrypted_at_rest('KSI_SC', '1.3') }})
            {{ union() }}
        ({{ elasticache_replication_groups_should_be_encrypted_at_rest('KSI_SC', '1.4') }})
            {{ union() }}

        -- KSI-SVC-05: Enforce system and information resource integrity through cryptographic means
        ({{ k8s_clusters_should_have_image_verifier('KSI-SVC-04', '1.0') }})
            {{ union() }}
        ({{ k8s_gatekeeper_should_be_enforcing('KSI-SVC-04', '1.1') }})
    )
select
    {{ gen_timestamp() }},
    aggregated.*
from aggregated